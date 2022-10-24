package com.vasugajjar.music_player

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.StrictMode
import android.widget.RemoteViews
import com.ryanheise.audioservice.AudioServiceActivity
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File
import java.io.FileInputStream

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

                setTextViewText(
                    R.id.player_widget_song_name,
                    widgetData.getString("title", "NA")
                )

                setTextViewText(
                    R.id.player_widget_song_artist,
                    widgetData.getString("artist", "NA")
                )

//                try {
//                val imgPath = widgetData.getString("image", null);
//                if (imgPath != null) {
//                    setImageViewUri(
//                        R.id.player_widget_image,
//                        Uri.fromFile(File(imgPath))
//                    )
//                } else {
//                    setImageViewResource(
//                        R.id.player_widget_image,
//                        R.mipmap.ic_launcher
//                    )
//                }
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

    fun getBitmap(filePath: String): Bitmap? {
        var bitmap: Bitmap? = null
        try {
            var f: File = File(filePath)
            var options = BitmapFactory.Options()
            options.inPreferredConfig = Bitmap.Config.ARGB_8888
            bitmap = BitmapFactory.decodeStream(FileInputStream(f), null, options)
        } catch (e: Exception) {

        }
        return bitmap
    }


}