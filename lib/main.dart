import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ten channel phai trung voi ten o trong file MainActiviti.java
  static const batteryPlatform =
      MethodChannel('com.example.method_channel/battery');
  static const cameraPlatform =
      MethodChannel('com.example.method_channel/camera');

  // default MethodChannel su dung StandardMethodCodec
  static const defaultPlatform =
      MethodChannel('com.example.method_channel/standard_codec');
  static const jsonMethodCodecPlatform =
      MethodChannel('com.example.method_channel/json_codec', JSONMethodCodec());
  static const listPlatform = MethodChannel("com.example.method_channel/list");

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';
  String _batteryLevelLoss = "Unknown";
  String _deviceStandardInfo1 = 'empty';
  String _deviceJsonInfo2 = 'empty';
  List<String> lists = [];

  // tra ve kieu int
  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      // ket qua tra ve cua invokeMethod la Future<dynamic> nen phai await
      final int result = await batteryPlatform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    // setState de hien thi len giao dien
    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // co the truyen argument trong ham invokeMethod
  Future<void> _getBatteryLevelWithArgument() async {
    String batteryLevel;
    try {
      // ket qua tra ve cua invokeMethod la Future<dynamic> nen phai await
      final int result =
          await batteryPlatform.invokeMethod('getBatteryLevelLoss', {
        "loss": 5,
      });
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    // setState de hien thi len giao dien
    setState(() {
      _batteryLevelLoss = batteryLevel;
    });
  }

  Future<void> _openCamera() async {
    try {
      await cameraPlatform.invokeMethod('openCamera');
    } on PlatformException catch (e) {
      print("Fail to open camera, error: ${e.message}");
    }
  }

  // tra ve kieu String
  Future<void> _standardMethodCodec() async {
    String deviceInfo;
    try {
      final String result = await defaultPlatform.invokeMethod('getDefault');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed: '${e.message}'.";
    }

    setState(() {
      _deviceStandardInfo1 = deviceInfo;
    });
  }

  // tra ve kieu Json
  Future<void> _jsonMethodCodec() async {
    String deviceInfo = "empty";
    try {
      final result = await jsonMethodCodecPlatform.invokeMethod('getJson');
      if (result != null) {
        deviceInfo = result["result"];
      }
    } on PlatformException catch (e) {
      deviceInfo = "Failed: '${e.message}'.";
    }

    setState(() {
      _deviceJsonInfo2 = deviceInfo;
    });
  }

  // tra ve kieu List
  Future<void> _getList() async {
    try {
      List<Object?> result = await listPlatform.invokeMethod('getList');
      if (result != null) {
        for (var item in result) {
          setState(() {
            lists.add(item.toString());
          });
        }
        print(lists.length);
      }
    } on PlatformException catch (e) {
      // deviceInfo = "Failed: '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_batteryLevel),
            ElevatedButton(
              child: const Text('Get Battery Level'),
              onPressed: _getBatteryLevel,
            ),
            Text(_batteryLevelLoss),
            ElevatedButton(
              child: const Text('Get Battery Level Loss'),
              onPressed: _getBatteryLevelWithArgument,
            ),
            ElevatedButton(
              child: const Text('Open Camera'),
              onPressed: _openCamera,
            ),
            Text("DeviceInfo -> String:  $_deviceStandardInfo1"),
            ElevatedButton(
              child: const Text('String'),
              onPressed: _standardMethodCodec,
            ),
            Text("DeviceInfo -> Json: $_deviceJsonInfo2"),
            ElevatedButton(
              child: const Text('JsonObject'),
              onPressed: _jsonMethodCodec,
            ),
            Text("List: $lists"),
            ElevatedButton(
              child: const Text('JsonObject'),
              onPressed: _getList,
            ),
          ],
        ),
      ),
    );
  }
}
