import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import '../api/api_doctor.dart';
import '../data/data_doctor.dart';
import '../my_functions.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';

class PageDoctorMain extends StatefulWidget {
  const PageDoctorMain({super.key});

  @override
  State<PageDoctorMain> createState() => _PageDoctorMainState();
}

class _PageDoctorMainState extends State<PageDoctorMain> {
  late Future<void> _future;
  /// API
  final ApiDoctor _api = ApiDoctor();
  /// Данные
  late DataDoctor _thisData;
  /// Параметры
  late String _doctorsId;
  /// Ключи
  final GlobalKey<AppBarWidgetState> _appBarKey = GlobalKey<AppBarWidgetState>();

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _doctorsId = await readSecureData(SecureKey.doctorsId);
    _thisData = await _api.get(doctorsId: _doctorsId);
    setState(() {});
  }

  Future<void> _refreshData() async {
    await _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        key: _appBarKey,
        title: EnumMenu.homeDoctor.displayName,
        automaticallyImplyLeading: false,
        showChat: true,
        showNotifications: true,
      ),
      endDrawer: MenuDrawer(),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return errorDataWidget(snapshot.error);
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: Padding(
                padding: paddingFormAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ListTileWidget(
                      title:
                      "${_thisData.lastName} ${_thisData.firstName} ${_thisData.patronymic}",
                      subtitle:
                      "${_thisData.regionName}\n${_thisData.hospitalName}",
                      iconTrailing: EnumMenu.profileDoctor.icon,
                      colorIconTrailing: EnumMenu.profileDoctor.iconColor,
                      onTap: () => navigateToPageMenu(
                        context,
                        EnumMenu.profileDoctor,
                      ),
                    ),
                    ListTileWidget(
                      title: EnumMenu.patients.displayName,
                      iconTrailing: EnumMenu.patients.icon,
                      colorIconTrailing: EnumMenu.patients.iconColor,
                      onTap: () => navigateToPageMenu(
                        context,
                        EnumMenu.patients,
                      ),
                    ),
                    ListTileWidget(
                      title: EnumMenu.notificationsSettings.displayName,
                      iconTrailing: EnumMenu.notificationsSettings.icon,
                      colorIconTrailing: EnumMenu.notificationsSettings.iconColor,
                      onTap: () async {
                        await deleteSecureData(SecureKey.patientsId);
                        navigateToPageMenu(
                          context,
                          EnumMenu.notificationsSettings,
                        );
                      }
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
