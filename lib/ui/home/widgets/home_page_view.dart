import 'package:flutter/material.dart';
import 'package:mobile_client/ui/ble_devices/widgets/ble_devices_page_view.dart';
import 'package:mobile_client/ui/home/widgets/group_message_topic_component.dart';
import 'package:mobile_client/ui/home/view_models/home_page_view_model.dart';
import 'package:mobile_client/ui/settings/widgets/settings_page_view.dart';
import 'package:provider/provider.dart';

class HomePageView extends StatefulWidget {
  @visibleForTesting
  final HomePageViewModel? homePageViewModel;

  const HomePageView({super.key, this.homePageViewModel});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with WidgetsBindingObserver {
  late HomePageViewModel homePageViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HomePageViewModel>();
      viewModel.refreshMobileHubState();
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        homePageViewModel.refreshMobileHubState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    homePageViewModel =
        widget.homePageViewModel ??
        Provider.of<HomePageViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Alertas de Qualidade do Ar",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsPageView(),
                      ),
                    ).then((_) {
                      homePageViewModel.refreshMobileHubState();
                    });
                  },
                  child: Row(
                    children: [Icon(Icons.settings), Text('Configurações')],
                  ),
                ),
                MenuItemButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BleDevicesPageView(),
                      ),
                    );
                  },
                  child: Row(
                    children: [Icon(Icons.bluetooth), Text('Dispositivos BLE')],
                  ),
                ),
              ],
              builder: (_, MenuController controller, _) {
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    controller.isOpen ? controller.close() : controller.open();
                  },
                  child: const Icon(Icons.menu, color: Colors.white),
                );
              },
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Color(0xFF29345E),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        spacing: 10,
        children: [
          Consumer<HomePageViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.mensagens.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      viewModel.isMobileHubStarted
                          ? 'Não há alertas no momento'
                          : 'Sem conexão com o ContextNet',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: viewModel.mensagens.length,
                    itemBuilder: (context, index) {
                      return GroupMessageTopicComponent(
                        mensagem: viewModel.mensagens[index]['analisys'],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
