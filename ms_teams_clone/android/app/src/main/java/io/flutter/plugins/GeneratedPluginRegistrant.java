package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
    flutterEngine.getPlugins().add(new io.agora.agora_rtc_engine.AgoraRtcEnginePlugin());
      io.agora.agorartm.AgoraRtmPlugin.registerWith(shimPluginRegistry.registrarFor("io.agora.agorartm.AgoraRtmPlugin"));
    flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
  }
}
