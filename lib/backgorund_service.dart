import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:http/http.dart' as http;

import 'local_notifications.dart';

class BackgorundService{


  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'MY FOREGROUND SERVICE', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: _onStart,

        // auto start service
        autoStart: false,
        isForegroundMode: true, // servis bildirimi gözükmesi
        autoStartOnBoot: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'AWESOME SERVICE',
        initialNotificationContent: 'Initializing',//
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,//

        // this will be executed when app is in foreground in separated isolate
        onForeground: _onStart,//

        // you have to enable background fetch capability on xcode project
        onBackground: _onIosBackground,//
      ),
    );

    if(!await service.isRunning()){
      await service.startService();
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("hello", "world");


    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // bring to foreground
    //int counter = 0;
    int lastID = 0;
    bool firstTimer = true;
    Timer.periodic(const Duration(seconds: 5), (timer) async {

      if (service is AndroidServiceInstance) {

        if (await service.isForegroundService()) {
          //counter++;
          //
          // if you don't using custom notification, uncomment this
          String dataApiUrl ='http://10.150.3.192/api/resource/Arac%20Talep%20Formu?fields=["name", "employee_name","request_date","delivery_date","car_type","request_reason","mail","designation","phone_number","plate"]&limit_page_length=none&filters=[["plate","=",""]]';
          final String apiKey = '85a59e5b34ea388';
          final String apiSecret = '1adb799b673b287';

          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}',
          };
          final response = await http.get(Uri.parse(dataApiUrl), headers: headers);

          if (response.statusCode == 200) {

            final jsonData = json.decode(response.body)['data'] as List<dynamic>;
            final dataListFromAPI =
            jsonData.map((json) => FrappeData.fromJson(json)).toList();
            var ids = dataListFromAPI.map((e) =>int.parse(e.name.split("-").last));
            var lastid = ids.last;

            if(firstTimer == false){
              if(lastid != lastID){
                LocalNotifications.showNotificationSimple(title: "CW ENERJİ", body: "Yeni Araç Talebi", payload: "payload");
                lastID = lastid;
              }
            }else{
              lastID = lastid;
              firstTimer = false;
            }
          }




          service.setForegroundNotificationInfo(
            title: "My App Service",
            content: "Updated at ${DateTime.now()}",
          );
        }
      }

      /// you can see this log in logcat
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      // test using external plugin
      final deviceInfo = DeviceInfoPlugin();
      String? device;
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.model;
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "device": device,
        },
      );
    });
  }
}