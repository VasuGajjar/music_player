package com.vasugajjar.storage_helper

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import android.view.KeyEvent

/**
 * Android 16 "Live Update" for the current song: the status-bar chip that OEMs also feed
 * into their island UIs (e.g. OnePlus Fluid Cloud).
 *
 * The media notification itself can never be promoted (MediaStyle is excluded), so this is
 * a separate, silent ongoing notification. Its buttons send media keys to the existing
 * audio_service session instead of needing a receiver of their own.
 */
object LiveUpdate {
    private const val CHANNEL_ID = "com.vasugajjar.music_player.live_update"
    private const val NOTIFICATION_ID = 2001
    // Public as Notification.EXTRA_REQUEST_PROMOTED_ONGOING from API 36.1; the key is honoured on 36.0.
    private const val EXTRA_REQUEST_PROMOTED_ONGOING = "android.requestPromotedOngoing"
    private const val PAUSED_TIMEOUT_MS = 30 * 60 * 1000L

    fun isSupported(context: Context): Boolean =
        Build.VERSION.SDK_INT >= 36 && manager(context).canPostPromotedNotifications()

    fun post(context: Context, args: Map<*, *>) {
        val manager = manager(context)
        if (Build.VERSION.SDK_INT < 36 || !manager.canPostPromotedNotifications()) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "Now playing in status bar", NotificationManager.IMPORTANCE_DEFAULT).apply {
                description = "Shows the current song as a Live Update"
                setSound(null, null)
                enableVibration(false)
                setShowBadge(false)
            }
        )

        val playing = args["playing"] as Boolean
        val position = (args["position"] as Number).toLong()
        val duration = (args["duration"] as Number?)?.toLong()
        val now = System.currentTimeMillis()

        val builder = Notification.Builder(context, CHANNEL_ID)
            .setSmallIcon(drawable(context, "ic_stat_music"))
            .setContentTitle(args["title"] as String)
            .setContentText(args["artist"] as String)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(openApp(context))
            // The chip shows the song's elapsed time, ticking on its own between updates.
            .setWhen(if (playing) now - position else now)
            .setShowWhen(playing)
            .setUsesChronometer(playing)
            .addAction(action(context, "ic_previous", "Previous", KeyEvent.KEYCODE_MEDIA_PREVIOUS))
            .addAction(
                if (playing) action(context, "ic_pause", "Pause", KeyEvent.KEYCODE_MEDIA_PAUSE)
                else action(context, "ic_play", "Play", KeyEvent.KEYCODE_MEDIA_PLAY)
            )
            .addAction(action(context, "ic_next", "Next", KeyEvent.KEYCODE_MEDIA_NEXT))
            .addExtras(Bundle().apply { putBoolean(EXTRA_REQUEST_PROMOTED_ONGOING, true) })
            // Ongoing notifications outlive a killed process; make sure a stale one goes away.
            .setTimeoutAfter(if (playing && duration != null) duration - position + 60_000 else PAUSED_TIMEOUT_MS)

        if (!playing) builder.setShortCriticalText("Paused")
        (args["art"] as String?)?.let { path -> decodeArt(path)?.let { builder.setLargeIcon(Icon.createWithBitmap(it)) } }

        manager.notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) = manager(context).cancel(NOTIFICATION_ID)

    private fun manager(context: Context) = context.getSystemService(NotificationManager::class.java)

    private fun openApp(context: Context): PendingIntent = PendingIntent.getActivity(
        context, 0,
        context.packageManager.getLaunchIntentForPackage(context.packageName),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    /** Icons live in the app module (see res/raw/keep.xml), so look them up by name. */
    private fun drawable(context: Context, name: String) =
        context.resources.getIdentifier(name, "drawable", context.packageName)

    private fun action(context: Context, icon: String, label: String, keyCode: Int): Notification.Action {
        val intent = Intent(Intent.ACTION_MEDIA_BUTTON)
            // audio_service's receiver forwards media keys to its session.
            .setComponent(ComponentName(context.packageName, "com.ryanheise.audioservice.MediaButtonReceiver"))
            .putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        val pending = PendingIntent.getBroadcast(context, keyCode, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        return Notification.Action.Builder(Icon.createWithResource(context, drawable(context, icon)), label, pending).build()
    }

    /** SystemUI can't read our cache dir, so hand it a small bitmap instead of a file path. */
    private fun decodeArt(path: String) = try {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= 256) sample *= 2
        BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample })
    } catch (e: Exception) {
        null
    }
}
