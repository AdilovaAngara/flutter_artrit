import 'package:artrit/api/api_anamnesis_concomitants.dart';
import 'package:artrit/api/api_anamnesis_disease_anamnesis.dart';
import 'package:artrit/api/api_anamnesis_family_history.dart';
import 'package:artrit/data/data_anamnesis_concomitants.dart';
import 'package:artrit/data/data_anamnesis_disease_anamnesis.dart';
import 'package:artrit/data/data_anamnesis_family_history.dart';
import 'package:artrit/my_functions.dart';
import 'package:artrit/pages/page_anamnesis_concomitants.dart';
import 'package:artrit/pages/page_anamnesis_disease_anamnesis_edit.dart';
import 'package:artrit/pages/page_anamnesis_family_history_edit.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';


class PageAnamnesis extends StatefulWidget {
  final String title;

  const PageAnamnesis({
    super.key,
    required this.title,
  });

  @override
  State<PageAnamnesis> createState() => _PageAnamnesisState();
}

class _PageAnamnesisState extends State<PageAnamnesis> {
  late Future<void> _future;

  /// API
  final ApiAnamnesisFamilyHistory _apiFamilyHistory = ApiAnamnesisFamilyHistory();
  final ApiAnamnesisDiseaseAnamnesis _apiDiseaseAnamnesis = ApiAnamnesisDiseaseAnamnesis();
  final ApiAnamnesisConcomitants _apiConcomitants  = ApiAnamnesisConcomitants();

  /// Данные
  late DataAnamnesisFamilyHistory _thisDataFamilyHistory;
  late DataAnamnesisDiseaseAnamnesis? _thisDataDiseaseAnamnesis;
  late List<DataAnamnesisConcomitants>? _thisDataConcomitants;

  /// Параметры
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisDataFamilyHistory = await _apiFamilyHistory.get(patientsId: _patientsId);
    _thisDataDiseaseAnamnesis = await _apiDiseaseAnamnesis.get(patientsId: _patientsId);
    _thisDataConcomitants = await _apiConcomitants.get(patientsId: _patientsId);
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
                  ListTileWidget(
                    title: 'Семейный анамнез',
                    subtitle: getSubtitleFamilyHistory(_thisDataFamilyHistory),
                    maxLines: 5,
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageAnamnesisFamilyHistoryEdit(
                          title: 'Семейный анамнез',
                        ),
                      ),
                    ).then((_) async {
                      await _refreshData();
                    }),
                  ),
                  ListTileWidget(
                    title: 'Анамнез заболевания',
                    subtitle: getSubtitleDiseaseAnamnesis(_thisDataDiseaseAnamnesis),
                    maxLines: 5,
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageAnamnesisDiseaseAnamnesisEdit(
                          title: 'Анамнез заболевания',
                        ),
                      ),
                    ).then((_) async {
                      await _refreshData();
                    }),
                  ),
                  ListTileWidget(
                    title: 'Сопутствующие заболевания',
                    subtitle: (_thisDataConcomitants == null || _thisDataConcomitants!.isEmpty) ? 'Нет данных' : _thisDataConcomitants![0].diagnosis ?? '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PageAnamnesisConcomitants(
                          title: 'Сопутствующие заболевания',
                        ),
                      ),
                    ).then((_) async {
                      await _refreshData();
                    }),
                  ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
