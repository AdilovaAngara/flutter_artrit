import 'package:artrit/api/api_treatment_rehabilitations.dart';
import 'package:artrit/data/data_treatment_rehabilitations.dart';
import 'package:artrit/pages/page_treatment_medicaments.dart';
import 'package:artrit/pages/page_treatment_rehabilitation.dart';
import 'package:artrit/pages/page_treatment_side_effects.dart';
import 'package:flutter/material.dart';
import '../api/api_treatment_medicaments.dart';
import '../api/api_treatment_side_effects.dart';
import '../data/data_treatment_medicaments.dart';
import '../data/data_treatment_side_effects.dart';
import '../my_functions.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';


class PageTreatment extends StatefulWidget {
  final String title;

  const PageTreatment({
    super.key,
    required this.title,
  });

  @override
  State<PageTreatment> createState() => _PageTreatmentState();
}

class _PageTreatmentState extends State<PageTreatment> {
  late Future<void> _future;

  /// API
  final ApiTreatmentMedicaments _apiMedicaments = ApiTreatmentMedicaments();
  final ApiTreatmentSideEffects _apiSideEffects = ApiTreatmentSideEffects();
  final ApiTreatmentRehabilitations _apiRehabilitations  = ApiTreatmentRehabilitations();

  /// Данные
  List<DataTreatmentMedicaments>? _thisDataMedicaments;
  List<DataTreatmentSideEffects>? _thisDataSideEffects;
  List<DataTreatmentRehabilitations>? _thisDataRehabilitations;

  /// Параметры
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _patientsId = (await readSecureData(SecureKey.patientsId));
    _thisDataMedicaments = await _apiMedicaments.get(patientsId: _patientsId);
    _thisDataSideEffects = await _apiSideEffects.get(patientsId: _patientsId);
    _thisDataRehabilitations = await _apiRehabilitations.get(patientsId: _patientsId);
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
                    title: 'Лекарственные препараты',
                    subtitle: (_thisDataMedicaments == null || _thisDataMedicaments!.isEmpty) ? 'Нет данных' : _thisDataMedicaments![0].tnp != null ? _thisDataMedicaments![0].tnp! : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                          context,
                            MaterialPageRoute(
                              builder: (context) => PageTreatmentMedicaments(
                                title: 'Лекарственные препараты',
                              ),
                            ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'Нежелательные явления терапии',
                    subtitle: (_thisDataSideEffects == null || _thisDataSideEffects!.isEmpty) ? 'Нет данных' : _thisDataSideEffects![0].ny != null ? _thisDataSideEffects![0].ny! : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageTreatmentSideEffects(
                              title: 'Нежелательные явления терапии',
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'Реабилитация',
                    subtitle: (_thisDataRehabilitations == null || _thisDataRehabilitations!.isEmpty) ? 'Нет данных' : _thisDataRehabilitations![0].typeRehabil != null ? _thisDataRehabilitations![0].typeRehabil!.type ?? '' : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageTreatmentRehabilitation(
                              title: 'Реабилитация',
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
