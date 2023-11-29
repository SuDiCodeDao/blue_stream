import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var isBluetoothOn = false.obs;
  var bluetoothState = BluetoothState.UNKNOWN.obs;
  late BluetoothConnection connection;

  var devicesList = <BluetoothDevice>[].obs;
  var device = const BluetoothDevice(address: '', name: '').obs;
  var isConnected = false.obs;
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  @override
  void onInit() {
    super.onInit();
    getBluetoothState();
    listenToBluetoothStateChanges();
    getPairedDevices();
  }

  void scanDevices() async {
    devicesList.clear();
    bluetooth.startDiscovery().listen((event) {
      devicesList.add(event.device);
      update();
    });
  }

  void getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on Exception {
      print('Error');
    }
    devicesList.value = devices;
    update();
  }

  void enableBluetooth() async {
    if (!isBluetoothOn.value) {
      try {
        await bluetooth.requestEnable();
        getPairedDevices();
      } catch (error) {
        print('Error enabling Bluetooth: $error');
      }
    }
  }

  void disableBluetooth() async {
    if (isBluetoothOn.value) {
      try {
        await bluetooth.requestDisable();
        devicesList.clear();
        update();
      } catch (error) {
        print('Error disabling Bluetooth: $error');
      }
    }
  }

  void connectDevice(BluetoothDevice selectedDevice) async {
    try {
      connection = await BluetoothConnection.toAddress(selectedDevice.address);
      device.value = selectedDevice;
      isConnected.value = true;
      update();
    } on Exception {
      print('Error');
    }
  }

  void disconnectDevice() async {
    try {
      await connection.close();
      device.value = const BluetoothDevice(address: '', name: '');
      isConnected.value = false;
      update();
    } on Exception {
      print('Error');
    }
  }

  void getBluetoothState() async {
    BluetoothState state = await bluetooth.state;
    isBluetoothOn.value = state.isEnabled;
    bluetoothState.value = state;
    update();
  }

  void listenToBluetoothStateChanges() {
    bluetooth.onStateChanged().listen((state) {
      isBluetoothOn.value = state.isEnabled;
      bluetoothState.value = state;
      update();
    });
  }
}
