import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:plugin/plugin.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal() : _plugin = Plugin();

  final Plugin _plugin;
  StreamSubscription? _streamSubscription;

  final List<Map<dynamic, dynamic>> _mensagens = [];
  List<Map<dynamic, dynamic>> get mensagens => List.unmodifiable(_mensagens);

  final _streamController =
      StreamController<List<Map<dynamic, dynamic>>>.broadcast();
  Stream<List<Map<dynamic, dynamic>>> get stream => _streamController.stream;

  @visibleForTesting
  MessageService.setMock(this._plugin);

  void startListening() {
    _streamSubscription = _plugin.onMessageReceived.listen((novaMensagem) {
      Map<String, dynamic>? json;

      try {
        json = jsonDecode(novaMensagem);
      } catch (_) {
        return;
      }

      if (json == null) return;

      _mensagens.insert(0, json);
      _streamController.add(_mensagens);
    });
  }

  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }
}
