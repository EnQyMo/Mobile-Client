import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_client/core/message_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin/plugin.dart';

class MockPlugin extends Mock implements Plugin {}

void main() {
  late MockPlugin mockPlugin;
  late MessageService messageService;
  late StreamController<String> streamController;

  setUp(() {
    mockPlugin = MockPlugin();
    streamController = StreamController<String>();

    when(
      () => mockPlugin.onMessageReceived,
    ).thenAnswer((_) => streamController.stream);

    messageService = MessageService.setMock(mockPlugin);
  });

  test('começa a ouvir', () async {
    const mensagem = "{\"texto\": \"teste\"}";

    messageService.startListening();
    streamController.add(mensagem);
    await Future(() {});

    expect(messageService.mensagens, hasLength(1));
    expect(messageService.mensagens.first, jsonDecode(mensagem));
  });

  test('para de ouvir', () async {
    const mensagem = "{\"texto\": \"teste\"}";
    messageService.startListening();
    streamController.add(mensagem);
    await Future(() {});

    messageService.stopListening();
    const mensagem2 = "{\"texto2\": \"teste\"}";
    streamController.add(mensagem2);
    await Future(() {});

    expect(messageService.mensagens, hasLength(1));
    expect(messageService.mensagens.first['texto'], 'teste');
  });
}
