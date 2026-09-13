import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_client/ui/ble_devices/widgets/ble_devices_page_view.dart';
import 'package:mobile_client/ui/settings/widgets/settings_page_view.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_client/ui/home/view_models/home_page_view_model.dart';
import 'package:mobile_client/ui/home/widgets/home_page_view.dart';
import 'package:provider/provider.dart';

class MockHomePageViewModel extends Mock implements HomePageViewModel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockHomePageViewModel mockHomePageViewModel;

  setUp(() {
    mockHomePageViewModel = MockHomePageViewModel();
    when(() => mockHomePageViewModel.mensagens).thenReturn([]);
    when(() => mockHomePageViewModel.isMobileHubStarted).thenReturn(false);
  });

  testWidgets('inicializa sem conexão', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sem conexão com o ContextNet'), findsOne);
  });

  testWidgets('inicializa com conexão', (tester) async {
    when(() => mockHomePageViewModel.isMobileHubStarted).thenReturn(true);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Não há alertas no momento'), findsOne);
  });

  testWidgets('abre o menu anchor', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);
  });

  testWidgets('vai para a tela de configurações', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPageView), findsOneWidget);
  });

  testWidgets('vai para a tela de dispositivos ble', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispositivos BLE'));
    await tester.pumpAndSettle();

    expect(find.byType(BleDevicesPageView), findsOneWidget);
  });

  testWidgets('lista as mensagens', (tester) async {
    const Map<dynamic, dynamic> mensagem = {
      "alert_id": "alert_1706798417002",
      "timestamp": "2025-10-01T22:40:17.002-03:00",
      "sensores": [
        {
          "sensor_id": "IAQ_6227821",
          "poluentes": [
            {
              "poluente": "pm25",
              "risk_level": "moderate",
              "affected_diseases": {
                "disease": ["asma", "bronquite", "irritação respiratória"],
              },
            },
            {
              "poluente": "pm4",
              "risk_level": "high",
              "affected_diseases": {
                "disease": [
                  "irritação respiratória",
                  "inflamação sistêmica leve",
                ],
              },
            },
          ],
        },
      ],
    };
    when(() => mockHomePageViewModel.mensagens).thenReturn([mensagem]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<HomePageViewModel>.value(
          value: mockHomePageViewModel,
          child: HomePageView(homePageViewModel: mockHomePageViewModel),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
  });
}
