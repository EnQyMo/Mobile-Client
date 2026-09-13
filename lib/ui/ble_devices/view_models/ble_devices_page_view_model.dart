import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_client/core/ble_devices_service.dart';
import 'package:mobile_client/ui/settings/view_models/settings_view_model.dart';

class BleDevicesPageViewModel extends ChangeNotifier {
  final BleDevicesService _bleDevicesService;
  StreamSubscription? _streamSubscription;
  List<Map<dynamic, dynamic>> _devicesList = [];
  List<Map<dynamic, dynamic>> get devices => _devicesList;

  BleDevicesPageViewModel() : _bleDevicesService = BleDevicesService() {
    _listenToBLEStreams();
  }

  @visibleForTesting
  BleDevicesPageViewModel.setMock(this._bleDevicesService) {
    _listenToBLEStreams();
  }

  void _listenToBLEStreams() {
    _devicesList = _bleDevicesService.devices;

    _streamSubscription = _bleDevicesService.stream.listen((device) {
      _devicesList = device;
      notifyListeners();
    });
  }

  bool getMobileHubState() {
    return SettingsViewModel().isMobileHubStarted;
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
