import 'dart:async';

import 'package:plugin/plugin.dart';

class BleDevicesService {
  static final BleDevicesService _instance = BleDevicesService._internal();
  factory BleDevicesService() => _instance;
  BleDevicesService._internal() : _plugin = Plugin();

  final Plugin _plugin;

  List<Map<dynamic, dynamic>> _devicesList = [];
  final List<String> _uuidList = [];

  List<Map<dynamic, dynamic>> get devices => _devicesList;

  final _streamController =
      StreamController<List<Map<dynamic, dynamic>>>.broadcast();
  Stream<List<Map<dynamic, dynamic>>> get stream => _streamController.stream;

  StreamSubscription? _streamSubscription;

  Timer? _timer;

  Future<void> start() async {
    await _plugin.startListening();
    _listenToBLEStreams();
    _startPeriodicUpdateContext();
  }

  Future<void> stop() async {
    _stopPeriodicUpdateContext();
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _devicesList = List.empty();
    await _plugin.stopListening();
  }

  Future<void> _listenToBLEStreams() async {
    _streamSubscription = _plugin.onBleDataReceived.listen((device) {
      var uuid = device['uuid'];

      if (uuid != null && !_uuidList.contains(uuid)) {
        _devicesList.add(device);
        _uuidList.add(uuid);
      }
    });
  }

  void _startPeriodicUpdateContext() {
    _timer = Timer.periodic(Duration(seconds: 3), (_) {
      _updateContext();
    });
  }

  void _stopPeriodicUpdateContext() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _updateContext() async {
    try {
      // final List<String> uuidList = _devicesList
      //     .map((device) => device['uuid'] as String)
      //     .toList();
      final List<String> uuidList = ['ea02d05b-179b-46a9-9137-103b06028fb7'];
      await _plugin.updateContext(devices: uuidList);

      print('Context updated');
    } catch (e) {
      print('Fail in updating context: $e');
    }
  }
}
