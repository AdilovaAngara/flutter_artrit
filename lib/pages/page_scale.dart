import 'package:artrit/api/api_scale_das28.dart';
import 'package:artrit/api/api_scale_doctor.dart';
import 'package:artrit/api/api_scale_jadas71.dart';
import 'package:artrit/api/api_scale_main_patient.dart';
import 'package:artrit/data/data_scale_das28.dart';
import 'package:artrit/data/data_scale_doctor.dart';
import 'package:artrit/data/data_scale_jadas71.dart';
import 'package:artrit/data/data_scale_main_patient.dart';
import 'package:artrit/pages/page_scale_das28.dart';
import 'package:artrit/pages/page_scale_doctor.dart';
import 'package:artrit/pages/page_scale_jadas71.dart';
import 'package:artrit/pages/page_scale_main_patient.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';

class PageScale extends StatefulWidget {
  final String title;

  const PageScale({
    super.key,
    required this.title,
  });

  @override
  State<PageScale> createState() => _PageScaleState();
}

class _PageScaleState extends State<PageScale> {
  late Future<void> _future;

  /// API
  final ApiScaleDoctor _apiDoctor = ApiScaleDoctor();
  final ApiScaleMainPatient _apiMainPatient = ApiScaleMainPatient();
  final ApiScaleJadas71 _apiJadas71 = ApiScaleJadas71();
  final ApiScaleDas28 _apiDas28  = ApiScaleDas28();

  /// Данные
  late List<DataScaleDoctor>? _thisDataDoctor;
  late List<DataScaleMainPatient>? _thisDataMainPatient;
  late List<DataScaleJadas71>? _thisDataJadas71;
  late List<DataScaleDas28>? _thisDataDas28;

  /// Параметры
  late int _role;
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisDataDoctor = await _apiDoctor.get(patientsId: _patientsId);
    _thisDataMainPatient = await _apiMainPatient.get(patientsId: _patientsId);
    _thisDataJadas71 = await _apiJadas71.get(patientsId: _patientsId);
    _thisDataDas28 = await _apiDas28.get(patientsId: _patientsId);
    setState(() {
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
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
                  if (_role == Roles.doctor)
                  ListTileWidget(
                    title: 'Глобальная оценка активности болезни врачом',
                    subtitle: (_thisDataDoctor == null || _thisDataDoctor!.isEmpty) ? 'Нет данных' : '${_thisDataDoctor![0].scale  ?? ''}',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageScaleDoctor(
                              title: 'Глобальная оценка активности болезни врачом',
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'Общая оценка состояния здоровья пациента',
                    subtitle: (_thisDataMainPatient == null || _thisDataMainPatient!.isEmpty) ? 'Нет данных' : '${_thisDataMainPatient![0].scale  ?? ''}',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageScaleMainPatient(
                              title: 'Общая оценка состояния здоровья пациента',
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'JADAS-71',
                    subtitle: (_thisDataJadas71 == null || _thisDataJadas71!.isEmpty) ? 'Нет данных' : '${_thisDataJadas71![0].indexResult ?? ''}',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageScaleJadas71(
                                title: 'JADAS-71'),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'DAS-28',
                    subtitle: (_thisDataDas28 == null || _thisDataDas28!.isEmpty) ? 'Нет данных' : '${_thisDataDas28![0].indexResult ?? ''}',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageScaleDas28(
                                title: 'DAS-28'
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
