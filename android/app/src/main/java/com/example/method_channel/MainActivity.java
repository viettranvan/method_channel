package com.example.method_channel;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.JSONMethodCodec;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


public class MainActivity extends FlutterActivity {
    // ten channel -> giong voi ten cac method channel o file main
    private static final String BATTERY_CHANNEL = "com.example.method_channel/battery";
    private static final String CAMERA_CHANNEL = "com.example.method_channel/camera";
    private static final String STANDARD_METHOD_CODEC_METHOD_CHANNEL = "com.example.method_channel/standard_codec";
    private static final String JSON_METHOD_CODEC_METHOD_CHANNEL = "com.example.method_channel/json_codec";
    private static final String LIST_CHANNEL = "com.example.method_channel/list";



    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), BATTERY_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // ten mothod giong voi ten mothod trong ham invokeMethod trong file main
                            if (call.method.equals("getBatteryLevel")) {
                                int batteryLevel = getBatteryLevel(0);

                                if (batteryLevel != -1) {
                                    // tra ve success voi data la batteryLevel
                                    result.success(batteryLevel);
                                } else {
                                    // tra ve error
                                    result.error("UNAVAILABLE", "Battery level not available.", null);
                                }
                            }else if(call.method.equals("getBatteryLevelLoss")){
                                // Lay argument ra, key -> loss, value -> int (trong java la java.lang.Integer)
                                Integer loss = call.argument("loss");
                                if(loss == null){
                                    result.error("ERROR", "type can not null", null);
                                }else{
                                    result.success(getBatteryLevel(loss));
                                }

                            }else {
                                result.notImplemented();
                            }
                        }

                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CAMERA_CHANNEL).
                setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("openCamera")) {
                                Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
                                startActivity(intent);
                            } else {
                                result.notImplemented();
                            }
                        }
                );


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), STANDARD_METHOD_CODEC_METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getDefault")) {
                                String myDeviceModel = Build.MODEL;

                                result.success(myDeviceModel);
                            } else {
                                result.notImplemented();
                            }
                        }

                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), JSON_METHOD_CODEC_METHOD_CHANNEL, JSONMethodCodec.INSTANCE).
                setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getJson")) {

                                JSONObject json = new JSONObject();
                                try {
                                    json.put("result", Build.MODEL);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }


                                result.success(json);
                            } else {
                                result.notImplemented();
                            }
                        }
                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), LIST_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getList")) {
                        ArrayList<String> list = new ArrayList<>();
                        list.add("Item1");
                        list.add("Item2");
                        list.add("Item3");

                        result.success(list);
                    } else {
                        result.notImplemented();
                    }
                }
        );

    }


    private int getBatteryLevel(int loss) {
        int batteryLevel = -1;
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
        } else {
            Intent intent = new ContextWrapper(getApplicationContext()).
                    registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
            batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
                    intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
        }

        return (batteryLevel - loss);
    }


}
