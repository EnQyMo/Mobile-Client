import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_client/ui/settings/view_models/settings_view_model.dart';
import 'package:mobile_client/ui/settings/widgets/settings_page_view.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsViewModel extends Mock implements SettingsViewModel {}

void main() {
  late MockSettingsViewModel mockSettingsViewModel;

  setUp(() {
    mockSettingsViewModel = MockSettingsViewModel();
  });

  testWidgets('renderiza corretamente', (tester) async {
    when(() => mockSettingsViewModel.isMobileHubStarted).thenReturn(false);

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPageView(settingsViewModel: mockSettingsViewModel),
      ),
    );

    expect(find.byKey(const Key('input ip address')), findsOneWidget);
    expect(find.byKey(const Key('input port')), findsOneWidget);
    expect(find.text('Iniciar Mobile Hub'), findsOneWidget);
  });

  testWidgets('clica iniciar mobile hub sucesso', (tester) async {
    when(() => mockSettingsViewModel.isMobileHubStarted).thenReturn(false);
    when(
      () => mockSettingsViewModel.startMobileHub(any(), any()),
    ).thenAnswer((_) async => (message: "ok", success: true));

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPageView(settingsViewModel: mockSettingsViewModel),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('input ip address')),
      '1.1.1.1',
    );
    await tester.enterText(find.byKey(const Key('input port')), '1');
    await tester.tap(find.text('Iniciar Mobile Hub'));
    await tester.pumpAndSettle();

    verify(
      () => mockSettingsViewModel.startMobileHub('1.1.1.1', '1'),
    ).called(1);
  });

  testWidgets('clica parar mobile hub sucesso', (tester) async {
    when(() => mockSettingsViewModel.isMobileHubStarted).thenReturn(true);
    when(() => mockSettingsViewModel.ipAddress).thenReturn('');
    when(() => mockSettingsViewModel.port).thenReturn('');
    when(
      () => mockSettingsViewModel.stopMobileHub(),
    ).thenAnswer((_) async => (message: "ok", success: true));

    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPageView(settingsViewModel: mockSettingsViewModel),
      ),
    );

    await tester.tap(find.text('Parar Mobile Hub'));
    await tester.pumpAndSettle();

    verify(() => mockSettingsViewModel.stopMobileHub()).called(1);
  });
}
