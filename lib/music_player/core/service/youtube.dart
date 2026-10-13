import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../music_player.dart';

/// A YouTube search result.
class OnlineVideo {
  final String url, title, uploader;
  final String? thumbnail;

  /// Seconds; -1 when unknown (e.g. live).
  final int duration;

  /// -1 when hidden.
  final int views;

  const OnlineVideo({
    required this.url,
    required this.title,
    required this.uploader,
    required this.thumbnail,
    required this.duration,
    required this.views,
  });

  factory OnlineVideo.fromMap(Map map) => OnlineVideo(
        url: map['url'],
        title: map['title'] ?? '',
        uploader: map['uploader'] ?? '',
        thumbnail: map['thumbnail'],
        duration: map['duration'] ?? -1,
        views: map['views'] ?? -1,
      );

  String? get durationText {
    if (duration < 0) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    final d = Duration(seconds: duration);
    final seconds = two(d.inSeconds % 60);
    return d.inHours > 0 ? '${d.inHours}:${two(d.inMinutes % 60)}:$seconds' : '${d.inMinutes}:$seconds';
  }

  String get subtitle => views < 0 ? uploader : '$uploader · ${_compact(views)} views';

  static String _compact(int n) {
    String fixed(double v) => v.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '');
    if (n >= 1e9) return '${fixed(n / 1e9)}B';
    if (n >= 1e6) return '${fixed(n / 1e6)}M';
    if (n >= 1e3) return '${fixed(n / 1e3)}K';
    return '$n';
  }
}

/// One playable audio stream of a video, with the headers googlevideo expects for it.
class OnlineAudio {
  final String url, format;
  final int itag, bitrate, size;
  final bool downloadable;
  final Map<String, String> headers;

  const OnlineAudio({
    required this.url,
    required this.itag,
    required this.format,
    required this.bitrate,
    required this.size,
    required this.downloadable,
    required this.headers,
  });

  factory OnlineAudio.fromMap(Map map) => OnlineAudio(
        url: map['url'],
        itag: map['itag'] ?? -1,
        format: map['format'] ?? '',
        bitrate: map['bitrate'] ?? -1,
        size: map['size'] ?? -1,
        downloadable: map['downloadable'] ?? false,
        headers: Map<String, String>.from(map['headers'] ?? const {}),
      );

  bool get isM4a => format == 'M4A';

  String get label => '${isM4a ? 'M4A' : 'WebM'}${bitrate > 0 ? ' · $bitrate kbps' : ''}';

  /// Exact when YouTube reports a content length, otherwise estimated from bitrate.
  String sizeText(int durationSeconds) {
    final bytes = size > 0 ? size : bitrate * 1000 / 8 * durationSeconds;
    return bytes > 0 ? '${(bytes / 1e6).toStringAsFixed(1)} MB' : '';
  }
}

/// YouTube search, streaming and downloads through NewPipeExtractor on the Android side
/// (see `YouTube.kt` in storage_helper).
class YouTube {
  static const _channel = MethodChannel('com.vasugajjar.music_player/youtube');

  /// Video url → download progress (0..1). Lives as long as the app, so downloads
  /// survive leaving the search screen.
  static final downloads = ValueNotifier<Map<String, double>>({});

  /// Download failures, for snackbars.
  static final errors = StreamController<String>.broadcast();

  /// Headers per stream url, looked up by the player when it opens one.
  static final _headers = <String, Map<String, String>>{};
  static final _videos = <String, OnlineVideo>{};
  static bool _listening = false;

  static Future<List<OnlineVideo>> search(String query) async {
    final items = await _channel.invokeListMethod<Map>('search', {'query': query}) ?? [];
    return items.map(OnlineVideo.fromMap).toList();
  }

  static Future<List<String>> suggestions(String query) async =>
      await _channel.invokeListMethod<String>('suggestions', {'query': query}) ?? [];

  /// Audio streams of [url], best first: M4A, then bitrate, like NewPipe's default audio format.
  static Future<List<OnlineAudio>> audioStreams(String url) async {
    final items = await _channel.invokeListMethod<Map>('stream', {'url': url}) ?? [];
    final streams = items.map(OnlineAudio.fromMap).toList()
      ..sort((a, b) => a.isM4a == b.isM4a ? b.bitrate.compareTo(a.bitrate) : (a.isM4a ? -1 : 1));
    for (final s in streams) {
      _headers[s.url] = s.headers;
    }
    return streams;
  }

  static Map<String, String>? headersFor(String url) => _headers[url];

  /// The video behind a [downloads] entry.
  static OnlineVideo? videoFor(String id) => _videos[id];

  /// A [Song] the player can stream; its [Song.filePath] is the stream url.
  static Song songFor(OnlineVideo video, OnlineAudio audio) {
    _streamVideos[audio.url] = video;
    return Song(
      title: video.title,
      artist: video.uploader,
      album: 'YouTube',
      albumArtUrl: video.thumbnail,
      filePath: audio.url,
      isFavorite: false,
      dominantColor: AppColor.darkBlue.toARGB32(),
      textColor: AppColor.offWhite.toARGB32(),
    );
  }

  static final _streamVideos = <String, OnlineVideo>{};

  /// Re-extracts a streamed [song] whose url YouTube revoked; null if it can't.
  static Future<Song?> refresh(Song song) async {
    final video = _streamVideos[song.filePath];
    if (video == null) return null;
    try {
      final streams = await audioStreams(video.url);
      return streams.isEmpty ? null : songFor(video, streams.first);
    } on PlatformException {
      return null;
    }
  }

  static Future<void> download(OnlineVideo video, OnlineAudio audio) async {
    _listen();
    _videos[video.url] = video;
    _setProgress(video.url, 0);
    try {
      await _channel.invokeMethod('download', {
        'id': video.url,
        'url': audio.url,
        'itag': audio.itag,
        'headers': audio.headers,
        'size': audio.size,
        'title': video.title,
        'artist': video.uploader,
        'thumbnail': video.thumbnail,
      });
    } on PlatformException catch (e) {
      _fail(video.url, e.message);
    }
  }

  static Future<void> cancel(String id) async {
    await _channel.invokeMethod('cancelDownload', {'id': id});
    _remove(id);
  }

  /// Forgets a finished download in the list; the file stays in the library.
  static void dismiss(String id) => _remove(id);

  static void _listen() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      final args = call.arguments as Map;
      final String id = args['id'];
      switch (call.method) {
        case 'downloadProgress':
          if (downloads.value.containsKey(id)) _setProgress(id, (args['progress'] as num).toDouble());
        case 'downloadDone':
          final video = _videos[id];
          _setProgress(id, 1);
          if (video != null) {
            await MusicRepository().addSong(args['path'], title: video.title, artist: video.uploader, cover: args['cover']);
          }
        case 'downloadError':
          _fail(id, args['message']);
      }
    });
  }

  static void _fail(String id, String? message) {
    _remove(id);
    errors.add(message ?? 'Download failed');
  }

  static void _remove(String id) {
    _videos.remove(id);
    downloads.value = {...downloads.value}..remove(id);
  }

  static void _setProgress(String id, double progress) => downloads.value = {...downloads.value, id: progress};
}

extension SongSource on Song {
  /// Streamed from YouTube rather than a file in the library.
  bool get isRemote => filePath.startsWith('http');
}
