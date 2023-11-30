import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  var isBluetoothOn = false.obs;
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult>? discoverySubscription;
  var bluetoothState = BluetoothState.UNKNOWN.obs;
  late BluetoothConnection connection;
  final foundDevice = false.obs;
  var devicesList = <BluetoothDevice>[].obs;
  var device = const BluetoothDevice(address: '', name: '').obs;
  var isConnected = false.obs;

  final loading = ValueNotifier(false);

  @override
  void onInit() {
    super.onInit();
    initializeBluetooth();
  }

  Future<void> scanDevices() async {
    loading.value = true;

    print('Start scanning...');
    try {
      devicesList.clear();

      discoverySubscription = bluetooth.startDiscovery().listen(
        (event) => devicesList.add(event.device),
        onDone: () {
          // This callback is triggered when the discovery is completed.
          discoverySubscription?.cancel();
          bluetooth.cancelDiscovery();
        },
        onError: (dynamic error) {
          print('Error during scan: $error');
          discoverySubscription?.cancel();
        },
        cancelOnError: true,
      );

      await Future.delayed(const Duration(seconds: 10));
    } catch (e) {
      print('Error during scan: $e');
    } finally {
      loading.value = false;
    }

    foundDevice.value = devicesList.isNotEmpty;
    print('Scanning finished');
  }

  Future<void> getPairedDevices() async {
    try {
      devicesList.value = await bluetooth.getBondedDevices();
    } on Exception {
      print('Error');
    } catch (e) {
      print('Error getting paired devices: $e');
    }

    update();
  }

  Future<void> enableBluetooth() async {
    if (!isBluetoothOn.value) {
      try {
        await bluetooth.requestEnable();
        getBluetoothState();
      } catch (error) {
        print('Error enabling Bluetooth: $error');
      }
    }
  }

  Future<void> disableBluetooth() async {
    print('Current Bluetooth state: ${bluetoothState.value}');

    try {
      if (isBluetoothOn.value) {
        print('Disabling Bluetooth...');
        await bluetooth.requestDisable();

        devicesList.clear();

        update();

        print('Bluetooth disabled');
      }
    } on Exception catch (e) {
      print('Error disabling Bluetooth: $e');
    }

    await Future.delayed(const Duration(seconds: 1));
    getBluetoothState();
    print('Bluetooth state after disabling: ${bluetoothState.value}');
  }

  Future<void> connectDevice(BluetoothDevice selectedDevice) async {
    try {
      connection = await BluetoothConnection.toAddress(selectedDevice.address);
      if (connection.isConnected) {
        device.value = selectedDevice;
        isConnected.value = true;
        update();
      }
    } on Exception {
      print('Error');
    }
  }

  Stream<Uint8List> read() {
    return connection.input!;
  }

  Future<void> disconnectDevice() async {
    try {
      await connection.close();
      device.value = const BluetoothDevice(address: '', name: '');
      isConnected.value = false;
      update();
    } on Exception {
      print('Error');
    }
  }

  Future<void> getBluetoothState() async {
    bluetoothState.value = await bluetooth.state;
    isBluetoothOn.value = bluetoothState.value.isEnabled;
    update();
  }

  Future<void> listenToBluetoothStateChanges() async {
    final Completer<void> completer = Completer<void>();

    StreamSubscription<BluetoothState> subscription;
    subscription = bluetooth.onStateChanged().listen((state) {
      isBluetoothOn.value = state.isEnabled;
      bluetoothState.value = state;
      update();
    }, onDone: () {
      completer.complete();
    }, onError: (dynamic error) {
      completer.completeError(error);
    }, cancelOnError: true);

    try {
      await completer.future;
    } finally {
      subscription.cancel();
    }
  }

  Future<void> initializeBluetooth() async {
    await getBluetoothState();
    listenToBluetoothStateChanges();
    getPairedDevices();
  }
}
