import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_client/core/ble_devices_service.dart';
import 'package:mobile_client/core/message_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plugin/plugin.dart';

class PermissionService {
  Future<PermissionStatus> requestLocation() => Permission.location.request();
  Future<bool> isNotificationDenied() => Permission.notification.isDenied;
  Future<PermissionStatus> requestNotification() =>
      Permission.notification.request();
}

class SettingsViewModel extends ChangeNotifier {
  static final SettingsViewModel _instance = SettingsViewModel._internal();
  factory SettingsViewModel() => _instance;
  SettingsViewModel._internal()
    : _plugin = Plugin(),
      _permissionService = PermissionService(),
      _messageService = MessageService(),
      _bleDevicesService = BleDevicesService() {
    _checkMobileHubStatus();
  }

  String ipAddress = '';
  String port = '';

  final Plugin _plugin;
  final PermissionService _permissionService;
  final MessageService _messageService;
  final BleDevicesService _bleDevicesService;

  bool _isMobileHubStarted = false;
  bool get isMobileHubStarted => _isMobileHubStarted;

  @visibleForTesting
  SettingsViewModel.setMock(
    this._plugin,
    this._permissionService,
    this._messageService,
    this._bleDevicesService,
  );

  Future<void> _checkMobileHubStatus() async {
    _isMobileHubStarted = await _plugin.isMobileHubStarted() ?? false;
    notifyListeners();
  }

  Future<({bool success, String message})> startMobileHub(
    String ipAddress,
    String port,
  ) async {
    try {
      var status = await _permissionService.requestLocation();
      if (!status.isGranted) {
        return (success: false, message: "Permissão de localização negada");
      }

      if (await _permissionService.isNotificationDenied()) {
        await _permissionService.requestNotification();
      }

      RegExp exp = RegExp(
        r'\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b',
      );
      if (!exp.hasMatch(ipAddress)) {
        return (success: false, message: "Endereço de IP inválido");
      }

      var intPort = int.tryParse(port);
      if (intPort == null || intPort <= 0 || intPort >= 65535) {
        return (success: false, message: "Porta inválida");
      }

      await _plugin.startMobileHub(ipAddress: ipAddress, port: intPort);
      await _checkMobileHubStatus();
      _bleDevicesService.start();
      _messageService.startListening();
      return (success: true, message: "Mobile Hub iniciado com sucesso");
    } catch (e) {
      log("$e");
      return (success: false, message: "Falha ao iniciar o Mobile Hub: $e");
    }
  }

  Future<({bool success, String message})> stopMobileHub() async {
    try {
      _messageService.stopListening();
      _bleDevicesService.stop();
      await _plugin.stopMobileHub();
      await _checkMobileHubStatus();
      return (success: true, message: "Mobile Hub interrompido");
    } catch (e) {
      log("$e");
      return (success: false, message: "Falha ao interromper o Mobile Hub: $e");
    }
  }
}
