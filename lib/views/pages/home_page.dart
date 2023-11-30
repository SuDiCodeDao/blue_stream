import 'package:blue_stream/controllers/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final BluetoothController bluetoothController =
        Get.find<BluetoothController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blue Stream',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        elevation: 10,
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Bluetooth State'),
              subtitle: Text(bluetoothController.bluetoothState.toString()),
              value: bluetoothController.isBluetoothOn.value,
              onChanged: (bool value) {
                if (value) {
                  bluetoothController.enableBluetooth();
                } else {
                  bluetoothController.disableBluetooth();
                }
              },
            ),
            ListTile(
              title: const Text("Scan Devices"),
              trailing: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  bluetoothController.scanDevices();
                },
              ),
            ),
            Expanded(child: Obx(() {
              if (bluetoothController.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (bluetoothController.foundDevice.value == false) {
                return const Center(
                  child: Text('No device found'),
                );
              }

              return ListView.builder(
                itemCount: bluetoothController.devicesList.length,
                itemBuilder: (context, index) {
                  var device = bluetoothController.devicesList[index];
                  return ListTile(
                    title: Text(device.name!),
                    subtitle: Text(device.address),
                    onTap: () {
                      bluetoothController.connectDevice(device);
                    },
                  );
                },
              );
            }))
          ],
        ),
      ),
    );
  }
}
