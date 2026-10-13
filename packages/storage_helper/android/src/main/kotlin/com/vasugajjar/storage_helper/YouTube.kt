package com.vasugajjar.storage_helper

import android.content.ContentValues
import android.content.Context
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaMuxer
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.schabi.newpipe.extractor.MediaFormat
import org.schabi.newpipe.extractor.NewPipe
import org.schabi.newpipe.extractor.ServiceList
import org.schabi.newpipe.extractor.downloader.Downloader
import org.schabi.newpipe.extractor.downloader.Request
import org.schabi.newpipe.extractor.downloader.Response
import org.schabi.newpipe.extractor.exceptions.ReCaptchaException
import org.schabi.newpipe.extractor.localization.ContentCountry
import org.schabi.newpipe.extractor.localization.Localization
import org.schabi.newpipe.extractor.search.SearchInfo
import org.schabi.newpipe.extractor.services.youtube.YoutubeParsingHelper
import org.schabi.newpipe.extractor.services.youtube.linkHandler.YoutubeSearchQueryHandlerFactory
import org.schabi.newpipe.extractor.stream.AudioStream
import org.schabi.newpipe.extractor.stream.AudioTrackType
import org.schabi.newpipe.extractor.stream.DeliveryMethod
import org.schabi.newpipe.extractor.stream.StreamInfo
import org.schabi.newpipe.extractor.stream.StreamInfoItem
import java.io.File
import java.io.FileDescriptor
import java.io.FileOutputStream
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.nio.ByteBuffer
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.Future

/**
 * YouTube search, stream resolution and audio downloads, the way NewPipe does them:
 * NewPipeExtractor talks to YouTube's internal API, we only supply the HTTP client.
 */
class YouTube(private val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "com.vasugajjar.music_player/youtube")
    private val executor = Executors.newCachedThreadPool()
    private val main = Handler(Looper.getMainLooper())
    private val downloads = ConcurrentHashMap<String, Future<*>>()

    init {
        val locale = Locale.getDefault()
        NewPipe.init(
            Http,
            Localization.fromLocale(locale),
            if (locale.country.isEmpty()) ContentCountry.DEFAULT else ContentCountry(locale.country),
        )
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        executor.shutdownNow()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "search" -> background(result) { search(call.argument<String>("query")!!) }
            "suggestions" -> background(result) { ServiceList.YouTube.suggestionExtractor.suggestionList(call.argument<String>("query")!!) }
            "stream" -> background(result) { audioStreams(call.argument<String>("url")!!).map(::toMap) }
            "download" -> {
                startDownload(call)
                result.success(null)
            }
            "cancelDownload" -> {
                downloads.remove(call.argument<String>("id"))?.cancel(true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Extractor calls block on the network; run them off the platform thread. */
    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        executor.execute {
            try {
                val value = work()
                main.post { result.success(value) }
            } catch (e: Exception) {
                main.post { result.error("youtube", message(e), null) }
            }
        }
    }

    private fun message(e: Exception) = when (e) {
        is ReCaptchaException -> "YouTube asked for a captcha. Try again later."
        is IOException -> e.message?.takeIf { it.startsWith("Download") } ?: "Network error. Check your connection."
        else -> e.message ?: e.javaClass.simpleName
    }

    private fun search(query: String): List<Map<String, Any?>> {
        val youtube = ServiceList.YouTube
        val handler = youtube.searchQHFactory.fromQuery(query, listOf(YoutubeSearchQueryHandlerFactory.VIDEOS), "")
        // ponytail: first page only (~20 results); SearchInfo.getMoreItems(youtube, handler, info.nextPage) pages further.
        return SearchInfo.getInfo(youtube, handler).relatedItems.filterIsInstance<StreamInfoItem>().map { item ->
            mapOf(
                "url" to item.url,
                "title" to item.name,
                "uploader" to item.uploaderName,
                "duration" to item.duration,
                "views" to item.viewCount,
                "thumbnail" to item.thumbnails.maxByOrNull { it.height }?.url,
            )
        }
    }

    /** Plain progressive files only (no DASH/HLS manifests), and the original track, not dubs. */
    private fun audioStreams(videoUrl: String): List<AudioStream> =
        StreamInfo.getInfo(ServiceList.YouTube, videoUrl).audioStreams
            .filter { it.isUrl && it.deliveryMethod == DeliveryMethod.PROGRESSIVE_HTTP }
            .filter { it.audioTrackType == null || it.audioTrackType == AudioTrackType.ORIGINAL }

    private fun toMap(stream: AudioStream) = mapOf(
        "url" to stream.content,
        "itag" to stream.itag,
        "format" to stream.format?.name,
        "bitrate" to stream.averageBitrate,
        "size" to (stream.itagItem?.contentLength ?: -1L),
        // NewPipe's default download format; other formats are stream-only here.
        "downloadable" to (stream.format == MediaFormat.M4A),
        "headers" to Http.streamHeaders(stream.content),
    )

    private fun startDownload(call: MethodCall) {
        val id = call.argument<String>("id")!!
        downloads[id] = executor.submit {
            try {
                val (path, cover) = download(id, call)
                main.post { channel.invokeMethod("downloadDone", mapOf("id" to id, "path" to path, "cover" to cover)) }
            } catch (_: InterruptedException) {
                // Cancelled from Dart, which already dropped it from the list.
            } catch (e: Exception) {
                main.post { channel.invokeMethod("downloadError", mapOf("id" to id, "message" to message(e))) }
            } finally {
                downloads.remove(id)
            }
        }
    }

    /**
     * Fetches into a temp file, then remuxes into Music/YouTube through MediaStore so the
     * library scan picks it up. Returns (file path, cover path).
     */
    private fun download(id: String, call: MethodCall): Pair<String, String?> {
        // ponytail: MediaStore RELATIVE_PATH needs Android 10; older devices would need WRITE_EXTERNAL_STORAGE + a File path.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) throw IOException("Downloads need Android 10 or newer")

        val title = call.argument<String>("title")!!
        val temp = File(context.cacheDir, "downloads/${id.hashCode()}.part").apply { parentFile?.mkdirs(); delete() }
        try {
            fetch(id, call, temp) { progress ->
                main.post { channel.invokeMethod("downloadProgress", mapOf("id" to id, "progress" to progress)) }
            }

            val resolver = context.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.Audio.Media.DISPLAY_NAME, "${title.replace(Regex("[\\\\/:*?\"<>|]"), "_").take(120)}.m4a")
                put(MediaStore.Audio.Media.MIME_TYPE, "audio/mp4")
                put(MediaStore.Audio.Media.TITLE, title)
                put(MediaStore.Audio.Media.ARTIST, call.argument<String>("artist"))
                put(MediaStore.Audio.Media.ALBUM, "YouTube")
                put(MediaStore.Audio.Media.RELATIVE_PATH, "${Environment.DIRECTORY_MUSIC}/YouTube")
                put(MediaStore.Audio.Media.IS_PENDING, 1)
            }
            val uri = resolver.insert(MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY), values)
                ?: throw IOException("Download failed: could not create the file")
            try {
                resolver.openFileDescriptor(uri, "rw")!!.use { remux(temp, it.fileDescriptor) }
                resolver.update(uri, ContentValues().apply { put(MediaStore.Audio.Media.IS_PENDING, 0) }, null, null)
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
            return pathOf(uri) to saveCover(call.argument<String>("thumbnail"), uri)
        } finally {
            temp.delete()
        }
    }

    /**
     * Range-chunked GETs like NewPipe's downloader (googlevideo throttles one long request).
     * On 403 it re-extracts the stream and resumes from the same byte, like NewPipe's
     * `DownloadMissionRecover`: YouTube currently revokes VISIONOS urls mid-download (NewPipe #13824).
     */
    private fun fetch(videoUrl: String, call: MethodCall, file: File, onProgress: (Double) -> Unit) {
        val itag = call.argument<Int>("itag")!!
        var url = call.argument<String>("url")!!
        var headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
        var total = call.argument<Number>("size")?.toLong() ?: -1
        var done = 0L
        var lastReport = 0L
        var retries = 0
        val buffer = ByteArray(64 * 1024)

        FileOutputStream(file).use { out ->
            while (total < 0 || done < total) {
                val end = done + CHUNK_SIZE - 1
                val connection = (URL(url).openConnection() as HttpURLConnection).apply {
                    connectTimeout = TIMEOUT
                    readTimeout = TIMEOUT
                    headers.forEach { (name, value) -> setRequestProperty(name, value) }
                    setRequestProperty("Range", "bytes=$done-${if (total > 0) minOf(end, total - 1) else end}")
                }
                try {
                    val code = connection.responseCode
                    if (code == 403 && retries++ < MAX_RETRIES) {
                        val fresh = audioStreams(videoUrl).firstOrNull { it.itag == itag } ?: throw IOException("Download failed: stream gone")
                        url = fresh.content
                        headers = Http.streamHeaders(url)
                        continue
                    }
                    if (code !in 200..299) throw IOException("Download failed (HTTP $code)")
                    if (total < 0) {
                        // "bytes 0-10485759/3407256" → 3407256; a 200 means the whole file came at once.
                        total = connection.getHeaderField("Content-Range")?.substringAfter('/')?.toLongOrNull()
                            ?: connection.contentLengthLong.takeIf { code == 200 } ?: -1
                    }
                    connection.inputStream.use { input ->
                        while (true) {
                            if (Thread.currentThread().isInterrupted) throw InterruptedException()
                            val read = input.read(buffer)
                            if (read < 0) break
                            out.write(buffer, 0, read)
                            done += read
                            val now = System.currentTimeMillis()
                            if (total > 0 && now - lastReport > 250) {
                                lastReport = now
                                onProgress(done.toDouble() / total)
                            }
                        }
                    }
                    if (code == 200 || total < 0) break
                } finally {
                    connection.disconnect()
                }
            }
        }
    }

    /**
     * YouTube's M4A is DASH-fragmented MP4; rewrite it as a plain MP4 so other players and
     * MediaStore read its duration, like NewPipe's `M4aNoDash`, using the platform muxer.
     */
    private fun remux(input: File, output: FileDescriptor) {
        val extractor = MediaExtractor().apply { setDataSource(input.path) }
        val muxer = MediaMuxer(output, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        try {
            extractor.selectTrack(0)
            val track = muxer.addTrack(extractor.getTrackFormat(0))
            muxer.start()
            val buffer = ByteBuffer.allocate(1 shl 20)
            val info = MediaCodec.BufferInfo()
            while (true) {
                info.size = extractor.readSampleData(buffer, 0)
                if (info.size < 0) break
                info.offset = 0
                info.presentationTimeUs = extractor.sampleTime
                info.flags = if (extractor.sampleFlags and MediaExtractor.SAMPLE_FLAG_SYNC != 0) MediaCodec.BUFFER_FLAG_KEY_FRAME else 0
                muxer.writeSampleData(track, buffer, info)
                extractor.advance()
            }
            muxer.stop()
        } finally {
            muxer.release()
            extractor.release()
        }
    }

    @Suppress("DEPRECATION") // The app's library is keyed by file path.
    private fun pathOf(uri: Uri): String =
        context.contentResolver.query(uri, arrayOf(MediaStore.Audio.Media.DATA), null, null, null)?.use {
            if (it.moveToFirst()) it.getString(0) else null
        } ?: throw IOException("Download failed: saved file not found")

    /** Thumbnail as cover art, kept with the app's data so it survives cache clears. */
    private fun saveCover(thumbnail: String?, uri: Uri): String? = try {
        thumbnail?.let {
            val file = File(context.filesDir, "covers/${uri.lastPathSegment}.jpg").apply { parentFile?.mkdirs() }
            URL(it).openStream().use { input -> file.outputStream().use { output -> input.copyTo(output) } }
            file.path
        }
    } catch (_: IOException) {
        null
    }

    /** NewPipeExtractor's HTTP client, the counterpart of NewPipe's OkHttp `DownloaderImpl`. */
    private object Http : Downloader() {
        // Same as NewPipe's DownloaderImpl.USER_AGENT.
        private const val USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:153.0) Gecko/20100101 Firefox/153.0"

        override fun execute(request: Request): Response {
            val connection = (URL(request.url()).openConnection() as HttpURLConnection).apply {
                requestMethod = request.httpMethod()
                connectTimeout = TIMEOUT
                readTimeout = TIMEOUT
                setRequestProperty("User-Agent", USER_AGENT)
                // Extractor headers replace ours (its consent cookie, client-specific user agents).
                request.headers().forEach { (name, values) ->
                    values.forEachIndexed { i, value -> if (i == 0) setRequestProperty(name, value) else addRequestProperty(name, value) }
                }
            }
            try {
                request.dataToSend()?.let { body ->
                    connection.doOutput = true
                    connection.outputStream.use { it.write(body) }
                }
                val code = connection.responseCode
                if (code == 429) throw ReCaptchaException("reCaptcha Challenge requested", request.url())
                val body = (if (code >= 400) connection.errorStream else connection.inputStream)?.use { it.readBytes().decodeToString() }
                return Response(code, connection.responseMessage, connection.headerFields.filterKeys { it != null }, body, connection.url.toString())
            } finally {
                connection.disconnect()
            }
        }

        /**
         * Headers googlevideo expects for [url], per the `c=` client param, as NewPipe's
         * `YoutubeHttpDataSource` sends them (minus its POST body, which ExoPlayer's GET can't send).
         */
        fun streamHeaders(url: String): Map<String, String> = when (Uri.parse(url).getQueryParameter("c")) {
            "VISIONOS" -> mapOf("User-Agent" to YoutubeParsingHelper.getVisionOsUserAgent(null))
            "WEB" -> mapOf("User-Agent" to USER_AGENT, "Origin" to "https://www.youtube.com", "Referer" to "https://www.youtube.com/")
            else -> mapOf("User-Agent" to USER_AGENT)
        }
    }

    private companion object {
        const val CHUNK_SIZE = 10L * 1024 * 1024
        const val TIMEOUT = 30_000
        const val MAX_RETRIES = 5
    }
}
