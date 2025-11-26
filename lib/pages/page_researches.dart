import 'package:artrit/api/api_researches.dart';
import 'package:artrit/api/api_researches_other.dart';
import 'package:artrit/data/data_researches.dart';
import 'package:artrit/pages/page_researches_epicrisis.dart';
import 'package:artrit/pages/page_researches_list.dart';
import 'package:artrit/pages/page_researches_other.dart';
import 'package:artrit/pages/page_researches_tuberculin.dart';
import 'package:flutter/material.dart';
import '../api/api_researches_epicrisis.dart';
import '../api/api_researches_tuberculin.dart';
import '../data/data_researches_epicrisis.dart';
import '../data/data_researches_other.dart';
import '../data/data_researches_tuberculin.dart';
import '../my_functions.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'menu.dart';

class PageResearches extends StatefulWidget {
  final String title;

  const PageResearches({
    super.key,
    required this.title,
  });

  @override
  State<PageResearches> createState() => PageResearchesState();
}

class PageResearchesState extends State<PageResearches> {
  late Future<void> _future;

  /// API
  final ApiResearches _api = ApiResearches();
  final ApiResearchesEpicrisis _apiEpicrisis = ApiResearchesEpicrisis();
  final ApiResearchesOther _apiOther = ApiResearchesOther();
  final ApiResearchesTuberculin _apiTuberculin = ApiResearchesTuberculin();


  /// Данные
  List<DataResearches>? _thisDataAll;
  List<DataResearches>? _thisDataUzi;
  List<DataResearches>? _thisDataRentgen;
  List<DataResearches>? _thisDataKt;
  List<DataResearches>? _thisDataMrt;
  List<DataResearchesEpicrisis>? _thisDataEpicrisis;
  List<DataResearchesOther>? _thisDataOther;
  List<DataResearchesTuberculin>? _thisDataTuberculin;

  /// Параметры
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisDataAll = await _api.get(patientsId: _patientsId);
    _thisDataUzi = _filterResearchesByTypeId(_thisDataAll, 1);
    _thisDataRentgen = _filterResearchesByTypeId(_thisDataAll, 2);
    _thisDataKt = _filterResearchesByTypeId(_thisDataAll, 3);
    _thisDataMrt = _filterResearchesByTypeId(_thisDataAll, 4);
    _thisDataEpicrisis = await _apiEpicrisis.get(patientsId: _patientsId);
    _thisDataOther = await _apiOther.get(patientsId: _patientsId);
    _thisDataTuberculin = await _apiTuberculin.get(patientsId: _patientsId);
  }



  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
  }


  void _navigateAndRefresh(BuildContext context, String title, int typeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageResearchesList(
          title: title,
          typeId: typeId,
        ),
      ),
    ).then((_) async {
      await _refreshData();
    });
  }


  // Функция для фильтрации данных
  List<DataResearches>? _filterResearchesByTypeId(List<DataResearches>? researches, int typeId) {
    return researches?.where((research) => research.typeId == typeId).toList();
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
                      title: 'УЗИ',
                      subtitle: (_thisDataUzi == null || _thisDataUzi!.isEmpty) ? 'Нет данных' : _thisDataUzi![0].date != null ? convertTimestampToDateTime(_thisDataUzi![0].date) : '',
                      iconTrailing: Icons.arrow_forward_ios,
                      iconSize: 15,
                      onTap: () => _navigateAndRefresh(context, 'УЗИ', 1),
                    ),
                    ListTileWidget(
                      title: 'Рентген',
                      subtitle: (_thisDataRentgen == null || _thisDataRentgen!.isEmpty) ? 'Нет данных' : _thisDataRentgen![0].date != null ? convertTimestampToDateTime(_thisDataRentgen![0].date) : '',
                      iconTrailing: Icons.arrow_forward_ios,
                      iconSize: 15,
                      onTap: () => _navigateAndRefresh(context, 'Рентген', 2),
                    ),
                    ListTileWidget(
                      title: 'КТ',
                      subtitle: (_thisDataKt == null || _thisDataKt!.isEmpty) ? 'Нет данных' : _thisDataKt![0].date != null ? convertTimestampToDateTime(_thisDataKt![0].date) : '',
                      iconTrailing: Icons.arrow_forward_ios,
                      iconSize: 15,
                      onTap: () => _navigateAndRefresh(context, 'КТ', 3),
                    ),
                    ListTileWidget(
                      title: 'МРТ',
                      subtitle: (_thisDataMrt == null || _thisDataMrt!.isEmpty) ? 'Нет данных' : _thisDataMrt![0].date != null ? convertTimestampToDateTime(_thisDataMrt![0].date) : '',
                      iconTrailing: Icons.arrow_forward_ios,
                      iconSize: 15,
                      onTap: () => _navigateAndRefresh(context, 'МРТ', 4),
                    ),
                  ListTileWidget(
                    title: 'Иные исследования',
                    subtitle: (_thisDataOther == null || _thisDataOther!.isEmpty) ? 'Нет данных' : _thisDataOther![0].executeDate != null ? dateFormat(_thisDataOther![0].executeDate) : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageResearchesOther(
                              title: 'Иные исследования',
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'Выписки из других медицинских учреждений',
                    subtitle: (_thisDataEpicrisis == null || _thisDataEpicrisis!.isEmpty) ? 'Нет данных' : _thisDataEpicrisis![0].date != null ? convertTimestampToDate(_thisDataEpicrisis![0].date) : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageResearchesEpicrisis(
                              title: 'Выписки из других медицинских учреждений',
                            ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: 'Туберкулиновые пробы',
                    subtitle: (_thisDataTuberculin == null || _thisDataTuberculin!.isEmpty) ? 'Нет данных' : _thisDataTuberculin![0].date != null ? dateFormat(_thisDataTuberculin![0].date) : '',
                    iconTrailing: Icons.arrow_forward_ios,
                    iconSize: 15,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageResearchesTuberculin(
                              title: 'Туберкулиновые пробы',
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
