import 'package:blue_stream/constants/page_route.dart' as route;
import 'package:blue_stream/di/app_injection.dart';
import 'package:blue_stream/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppInjection.setup();
    return GetMaterialApp(
      title: 'Blue Stream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      initialRoute: route.PageRoute.home,
      getPages: AppRoute.route,
    );
  }
}
