import 'package:artrit/api/api_tests_biochemical.dart';
import 'package:artrit/api/api_tests_clinical.dart';
import 'package:artrit/api/api_tests_other.dart';
import 'package:artrit/pages/page_tests_biochemical.dart';
import 'package:artrit/pages/page_tests_clinical.dart';
import 'package:artrit/pages/page_tests_immunology.dart';
import 'package:artrit/pages/page_tests_other.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_tests_immunology.dart';
import '../data/data_tests_biochemical_list.dart';
import '../data/data_tests_clinical_list.dart';
import '../data/data_tests_immunology_list.dart';
import '../data/data_tests_other.dart';
import '../my_functions.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';

class PageTests extends StatefulWidget {
  final String title;

  const PageTests({
    super.key,
    required this.title,
  });

  @override
  State<PageTests> createState() => _PageTestsState();
}

class _PageTestsState extends State<PageTests> {
  late Future<void> _future;

  /// API
  final ApiTestsClinical _apiTestsClinical = ApiTestsClinical();
  final ApiTestsBiochemical _apiTestsBiochemical = ApiTestsBiochemical();
  final ApiTestsImmunology _apiTestsImmunology = ApiTestsImmunology();
  final ApiTestsOther _apiTestsOther = ApiTestsOther();
  final ApiSpr _apiSpr = ApiSpr();

  /// Данные
  List<DataTestsClinicalList>? _thisDataTestsClinical;
  List<DataTestsBiochemicalList>? _thisDataTestsBiochemical;
  List<DataTestsImmunologyList>? _thisDataTestsImmunology;
  List<DataTestsOther>? _thisDataTestsOther;

  // Справочники
  List<String> _listSprTestsGroup = [];

  /// Параметры
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisDataTestsClinical = await _apiTestsClinical.getList(patientsId: _patientsId);
    _thisDataTestsBiochemical = await _apiTestsBiochemical.getList(patientsId: _patientsId);
    _thisDataTestsImmunology = await _apiTestsImmunology.getList(patientsId: _patientsId);
    _thisDataTestsOther = await _apiTestsOther.get(patientsId: _patientsId);
    _listSprTestsGroup = await _apiSpr.getTestsGroup();
    setState(() { });
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
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
                  if (_listSprTestsGroup.contains('Клинический анализ крови'))
                    ListTileWidget(
                    title: 'Клинический анализ крови',
                    subtitle: (_thisDataTestsClinical == null || _thisDataTestsClinical!.isEmpty) ? 'Нет данных' : convertTimestampToDateTime(_thisDataTestsClinical![0].dateNew),
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                      onTap: () =>
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => PageTestsClinical(
                                title: 'Клинический анализ крови',
                              ),
                            ),
                          ).then((_) async {
                            await _refreshData();
                          }),
                  ),
                  if (_listSprTestsGroup.contains('Биохимический анализ крови'))
                    ListTileWidget(
                    title: 'Биохимический анализ крови',
                    subtitle: (_thisDataTestsBiochemical == null || _thisDataTestsBiochemical!.isEmpty) ? 'Нет данных' : convertTimestampToDateTime(_thisDataTestsBiochemical![0].dateNew),
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                      onTap: () =>
                          Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => PageTestsBiochemical(
                            title: 'Биохимический анализ крови',
                          ),
                        ),
                      ).then((_) async {
                        await _refreshData();
                      }),
                  ),
                  if (_listSprTestsGroup.contains('Иные анализы'))
                    ListTileWidget(
                    title: 'Иные анализы',
                    subtitle: (_thisDataTestsOther == null || _thisDataTestsOther!.isEmpty) ? 'Нет данных' : convertTimestampToDateTime(_thisDataTestsOther![0].date),
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                      onTap: () =>
                          Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => PageTestsOther(
                                title: 'Иные анализы'
                              ),
                            ),
                          ).then((_) async {
                            await _refreshData();
                          }),
                  ),
                  if (_listSprTestsGroup.contains('Иммунология'))
                  ListTileWidget(
                    title: 'Иммунология',
                    subtitle: (_thisDataTestsImmunology == null || _thisDataTestsImmunology!.isEmpty) ? 'Нет данных' : convertTimestampToDateTime(_thisDataTestsImmunology![0].dateNew),
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(context,
                          MaterialPageRoute(
                            builder: (context) => PageTestsImmunology(
                              title: 'Иммунология',
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
