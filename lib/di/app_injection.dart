import 'package:blue_stream/controllers/bluetooth_controller.dart';
import 'package:get/get.dart';

class AppInjection {
  static void setup() {
    Get.lazyPut(() => BluetoothController());
  }
}
