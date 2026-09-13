import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_client/core/message_service.dart';
import 'package:mobile_client/ui/settings/view_models/settings_view_model.dart';

class HomePageViewModel extends ChangeNotifier {
  final MessageService _messageService;
  final SettingsViewModel _settingsViewModel;
  StreamSubscription? _streamSubscription;
  List<Map<dynamic, dynamic>> _mensagens = [];
  List<Map<dynamic, dynamic>> get mensagens => List.unmodifiable(_mensagens);
  bool _isMobileHubStarted = false;
  bool get isMobileHubStarted => _isMobileHubStarted;

  HomePageViewModel()
    : _messageService = MessageService(),
      _settingsViewModel = SettingsViewModel() {
    _setUpMessages();
  }

  @visibleForTesting
  HomePageViewModel.setMock(this._messageService, this._settingsViewModel) {
    _setUpMessages();
  }

  void _setUpMessages() {
    _mensagens = _messageService.mensagens;

    _streamSubscription = _messageService.stream.listen((mensagem) {
      _mensagens = mensagem;
      notifyListeners();
    });

    refreshMobileHubState();
  }

  void refreshMobileHubState() {
    final started = _settingsViewModel.isMobileHubStarted;
    _isMobileHubStarted = started;

    if (started) {
      _messageService.startListening();
    } else {
      _messageService.stopListening();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
