import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'feature/friends/controller/chat_controller.dart';
import 'feature/raider/chat/controller/chat_controller.dart';
import 'feature/raider/chat/service/chat_service.dart';
import 'feature/splash_screen/screen/splash_screen.dart';
import 'feature/web socket/map_web_socket.dart' as raiderWebSocket;
import 'feature/friends/service/chat_service.dart'; // WebSocketService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLoading
  configEasyLoading();

  // 1. WebSocketService first
  print("main.dart: Putting WebSocketService");
  Get.put(WebSocketService());

  // 2 than ChatController
  print("main.dart: Putting ChatController");
  Get.put(ChatController());

  // 3. other serves
  Get.put<raiderWebSocket.MapWebSocketService>(
    raiderWebSocket.MapWebSocketService(),
    tag: 'raiderMapWebSocket',
  );

  // Initialize ScreenUtil
  await ScreenUtil.ensureScreenSize();

  runApp(const MyApp());
}

void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.grey
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = Colors.green
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'NaderHosn',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home:  SplashScreen(),
          builder: EasyLoading.init(),
        );
      },
    );
  }
}