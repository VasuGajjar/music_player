package com.vasugajjar.music_player

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.StrictMode
import android.widget.RemoteViews
import com.ryanheise.audioservice.AudioServiceActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetPlayerProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val builder: StrictMode.VmPolicy.Builder = StrictMode.VmPolicy.Builder()
        StrictMode.setVmPolicy(builder.build())
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.player_widget_layout).apply {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    AudioServiceActivity::class.java
                )
                setOnClickPendingIntent(R.id.player_widget_bg, pendingIntent)

                val playing = widgetData.getString("play", null)
                if (playing != null) {
                    if (playing == true.toString()) {
                        setImageViewResource(R.id.btn_play_pause, R.drawable.ic_pause)
                    } else {
                        setImageViewResource(R.id.btn_play_pause, R.drawable.ic_play)
                    }
                }

                val title = widgetData.getString("title", null)
                if (title != null) {
                    setTextViewText(R.id.player_widget_song_name, title)
                }

                val artist = widgetData.getString("artist", null)
                if (artist != null) {
                    setTextViewText(R.id.player_widget_song_artist, artist)
                }

//                val playPauseIntent = HomeWidgetBackgroundIntent.getBroadcast(
//                    context,
//                    Uri.parse("homeWidgetPlayer://playPause")
//                )
//                setOnClickPendingIntent(R.id.btn_play_pause, playPauseIntent)
//
//                val previousIntent = HomeWidgetBackgroundIntent.getBroadcast(
//                    context,
//                    Uri.parse("homeWidgetPlayer://previous")
//                )
//                setOnClickPendingIntent(R.id.btn_previous, previousIntent)
//
//                val nextIntent = HomeWidgetBackgroundIntent.getBroadcast(
//                    context,
//                    Uri.parse("homeWidgetPlayer://next")
//                )
//                setOnClickPendingIntent(R.id.btn_next, nextIntent)

//                try {
//                    val imgPath = widgetData.getString("image", null);
//                    if (imgPath != null) {
//                        setImageViewUri(
//                            R.id.player_widget_image,
//                            Uri.fromFile(File(imgPath))
//                        )
//                    } else {
//                        setImageViewResource(
//                            R.id.player_widget_image,
//                            R.mipmap.ic_launcher
//                        )
//                    }
//                } catch (_: Exception) {
//                    setImageViewResource(
//                        R.id.player_widget_image,
//                        R.mipmap.ic_launcher
//                    )
//                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}