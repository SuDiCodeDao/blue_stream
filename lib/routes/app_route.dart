import 'package:blue_stream/constants/page_route.dart';
import 'package:blue_stream/views/pages/data_page.dart';
import 'package:blue_stream/views/pages/home_page.dart';
import 'package:get/get.dart';

class AppRoute {
  static final route = [
    GetPage(name: PageRoute.home, page: () => const HomePage()),
    GetPage(name: PageRoute.data, page: () => const DataPage())
  ];
}
