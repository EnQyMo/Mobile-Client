import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_client/core/message_service.dart';
import 'package:mobile_client/ui/settings/view_models/settings_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plugin/plugin.dart';

class MockPlugin extends Mock implements Plugin {}

class MockPermissionService extends Mock implements PermissionService {}

class MockMessageService extends Mock implements MessageService {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late MockPlugin mockPlugin;
  late MockPermissionService mockPermissionService;
  late MockMessageService mockMessageService;
  late SettingsViewModel settingsViewModel;

  setUp(() {
    mockPlugin = MockPlugin();
    mockPermissionService = MockPermissionService();
    mockMessageService = MockMessageService();

    when(() => mockPlugin.isMobileHubStarted()).thenAnswer((_) async => false);
    when(
      () => mockPlugin.updateContext(devices: any(named: 'devices')),
    ).thenAnswer((_) async {});
    when(() => mockPlugin.startListening()).thenAnswer((_) async => false);

    settingsViewModel = SettingsViewModel.setMock(
      mockPlugin,
      mockPermissionService,
      mockMessageService,
    );
  });

  group('permissões', () {
    test('negada para localização', () async {
      when(
        () => mockPermissionService.requestLocation(),
      ).thenAnswer((_) async => PermissionStatus.denied);

      final result = await settingsViewModel.startMobileHub('1', '1');

      expect(result.success, false);
      expect(result.message, 'Permissão de localização negada');
      verifyNever(
        () => mockPlugin.startMobileHub(
          ipAddress: any(named: 'ipAddress'),
          port: any(named: 'port'),
        ),
      );
    });

    test('pede permissão para notificação se negada', () async {
      when(
        () => mockPermissionService.requestLocation(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockPermissionService.isNotificationDenied(),
      ).thenAnswer((_) async => true);
      when(
        () => mockPermissionService.requestNotification(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockPlugin.startMobileHub(
          ipAddress: any(named: 'ipAddress'),
          port: any(named: 'port'),
        ),
      ).thenAnswer((_) async {});

      final result = await settingsViewModel.startMobileHub('1.1.1.1', '1');

      expect(result.success, true);
      verify(() => mockPermissionService.requestLocation()).called(1);
    });
  });

  group('mobile hub', () {
    setUp(() {
      when(
        () => mockPermissionService.requestLocation(),
      ).thenAnswer((_) async => PermissionStatus.granted);
      when(
        () => mockPermissionService.isNotificationDenied(),
      ).thenAnswer((_) async => true);
      when(
        () => mockPermissionService.requestNotification(),
      ).thenAnswer((_) async => PermissionStatus.granted);
    });

    test('inicia mobile hub sucesso', () async {
      when(() => mockMessageService.startListening()).thenReturn(null);
      when(() => mockPlugin.isMobileHubStarted()).thenAnswer((_) async => true);
      when(
        () => mockPlugin.startMobileHub(
          ipAddress: any(named: 'ipAddress'),
          port: any(named: 'port'),
        ),
      ).thenAnswer((_) async {});
      var ipAddress = "123.123.123.0";
      var port = "8096";

      var result = await settingsViewModel.startMobileHub(ipAddress, port);

      expect(result.success, true);
      expect(result.message, "Mobile Hub iniciado com sucesso");
      verify(
        () => mockPlugin.startMobileHub(ipAddress: ipAddress, port: 8096),
      ).called(1);
      verify(() => mockMessageService.startListening()).called(1);
    });

    test('inicia mobile hub falha exceção', () async {
      when(
        () => mockPlugin.startMobileHub(
          ipAddress: any(named: 'ipAddress'),
          port: any(named: 'port'),
        ),
      ).thenThrow(Exception('teste'));
      var ipAddress = "123.123.123.0";
      var port = "8096";

      var result = await settingsViewModel.startMobileHub(ipAddress, port);

      expect(result.success, false);
      expect(result.message, "Falha ao iniciar o Mobile Hub: Exception: teste");
      verify(
        () => mockPlugin.startMobileHub(ipAddress: ipAddress, port: 8096),
      ).called(1);
    });

    group('ip errado', () {
      test('999.999.999.999', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "999.999.999.999";
        var port = "aaa";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Endereço de IP inválido");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
      test('a', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "a";
        var port = "aaa";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Endereço de IP inválido");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
      test('123', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "123";
        var port = "aaa";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Endereço de IP inválido");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
    });

    group('port errado', () {
      test('aaa', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "123.123.123.0";
        var port = "aaa";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Porta inválida");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
      test('-1', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "123.123.123.0";
        var port = "-1";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Porta inválida");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
      test('999999999', () async {
        when(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        ).thenAnswer((_) async {});
        var ipAddress = "123.123.123.0";
        var port = "999999999";

        var result = await settingsViewModel.startMobileHub(ipAddress, port);

        expect(result.success, false);
        expect(result.message, "Porta inválida");
        verifyNever(
          () => mockPlugin.startMobileHub(
            ipAddress: any(named: 'ipAddress'),
            port: any(named: 'port'),
          ),
        );
      });
    });

    test('para o mobile hub sucesso', () async {
      when(() => mockPlugin.stopListening()).thenAnswer((_) async {});
      when(() => mockMessageService.stopListening()).thenReturn(null);
      when(
        () => mockPlugin.isMobileHubStarted(),
      ).thenAnswer((_) async => false);
      when(() => mockPlugin.stopMobileHub()).thenAnswer((_) async {});

      await settingsViewModel.stopMobileHub();

      verify(() => mockPlugin.stopMobileHub()).called(1);
      verify(() => mockMessageService.stopListening()).called(1);
    });

    test('para o mobile hub falha exceção', () async {
      when(() => mockPlugin.stopMobileHub()).thenThrow(Exception('teste'));
      var result = await settingsViewModel.stopMobileHub();

      expect(result.success, false);
      expect(
        result.message,
        "Falha ao interromper o Mobile Hub: Exception: teste",
      );
      verify(() => mockPlugin.stopMobileHub()).called(1);
    });
  });
}
