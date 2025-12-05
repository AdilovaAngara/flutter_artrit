import 'package:artrit/api/api_notifications_settings.dart';
import 'package:artrit/data/data_spr_frequency.dart';
import 'package:artrit/data/data_spr_sections.dart';
import 'package:artrit/pages/page_notifications_settings_edit.dart';
import 'package:flutter/material.dart';
import '../api/api_patients.dart';
import '../api/api_spr.dart';
import '../data/data_notifications_settings.dart';
import '../data/data_patients.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/notifications_settings_view_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/list_tile_expand_widget.dart';
import '../widgets/show_dialog_delete.dart';
import 'menu.dart';

class PageNotificationsSettings extends StatefulWidget {
  final String title;
  final bool forPatient;

  const PageNotificationsSettings({
    super.key,
    required this.title,
    this.forPatient = false
  });

  @override
  State<PageNotificationsSettings> createState() => PageNotificationsSettingsState();
}

class PageNotificationsSettingsState extends State<PageNotificationsSettings> {
  late Future<void> _future;

  /// API
  final ApiNotificationsSettings _api = ApiNotificationsSettings();
  final ApiPatients _apiPatients = ApiPatients();
  final ApiSpr _apiSpr = ApiSpr();

  /// Данные
  late List<DataNotificationsSettings>? _thisData;
  late List<DataPatients> _thisDataPatients = [];

  /// Справочники
  late List<DataSprFrequency> _thisSprDataFrequency;
  late List<DataSprSections> _thisSprDataSections;

  /// Параметры
  late int _role;
  late String _doctorsId;
  late String _patientsId;
  final ScrollController _scrollController = ScrollController();
  int _currentExpandedIndex = -1;

  /// Ключи
  late List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _doctorsId = await readSecureData(SecureKey.doctorsId);
    _patientsId = await readSecureData(SecureKey.patientsId);
    if (_patientsId.isNotEmpty && widget.forPatient) {
      _thisData = await _api.getForPatient(patientsId: _patientsId);
    } else {
      _thisData = await _api.getAll();
    }

    _thisDataPatients = await _apiPatients.get(doctorsId: _doctorsId);
    _thisSprDataFrequency = await _apiSpr.getFrequency();
    _thisSprDataSections = await _apiSpr.getSections();
    setState(() {
      _itemKeys = List.generate(_thisData?.length ?? 0, (_) => GlobalKey());
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
  }


  void _navigateAndRefresh(BuildContext context, bool isEditForm,
      {int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          PageNotificationsSettingsEdit(
              title: widget.title,
              isEditForm: isEditForm,
              forPatient: widget.forPatient,
              thisData: isEditForm ? _thisData![index!] : null),),
    ).then((_) async {
      await _refreshData();
    });
  }




  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext context) {
        return ShowDialogDelete(
          onConfirm: () async {
            String recordId = _thisData![index].id;
            await _api.delete(recordId: recordId);
            await _refreshData();
          },
        );
      },
    );
  }



  void _scrollToIndex(int index) {
    if (_thisData == null || index < 0 || index >= _thisData!.length) return;

    setState(() {
      _currentExpandedIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemKeys[index].currentContext != null) {
        scrollToContext(_itemKeys[index].currentContext!);
      } else {
        debugPrint('Context for index $index is null');
      }
    });
  }

  void _navigateToPrevious() {
    if (_currentExpandedIndex > 0) {
      _scrollToIndex(_currentExpandedIndex - 1);
    }
  }

  void _navigateToNext() {
    if (_thisData != null && _currentExpandedIndex < _thisData!.length - 1) {
      _scrollToIndex(_currentExpandedIndex + 1);
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
              padding: paddingForm,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.topRight,
                          color: Colors.grey.shade100,
                          child: ButtonWidget(
                            labelText: 'Добавить',
                            icon: Icons.add_circle_rounded,
                            onlyText: true,
                            listRoles: Roles.asDoctor,
                            role: _role,
                            onPressed: () {
                              _navigateAndRefresh(context, false);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: (_thisData == null || _thisData!.isEmpty)
                        ? notDataWidget
                        : ListView.builder(
                      controller: _scrollController,
                      itemCount: _thisData!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          key: _itemKeys[index],
                          padding: paddingListTile(index),
                          child: ListTileExpandWidget(
                            title: _thisData![index].name != null
                                ? _thisData![index].name ?? ''
                                : 'Название не указано',
                            subtitle: _thisSprDataFrequency
                                        .firstWhere((e) =>
                                            e.id ==
                                            _thisData![index].frequencyId)
                                        .name,
                            currentIndex: _currentExpandedIndex,
                            itemCount: _thisData!.length,
                            onPrevious: _navigateToPrevious,
                            onNext: _navigateToNext,
                            isExpanded: index == _currentExpandedIndex,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _currentExpandedIndex = expanded ? index : -1;
                              });
                            },
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                NotificationsSettingsViewWidget(
                                  thisData: _thisData![index],
                                  thisSprDataSections: _thisSprDataSections,
                                  thisDataPatients: _thisDataPatients,
                                ),
                                Row(
                                  children: [
                                    ButtonWidget(
                                      labelText: 'Изменить',
                                      icon: Icons.edit_note,
                                      iconAlignment: IconAlignment.start,
                                      onlyText: true,
                                      listRoles: Roles.asDoctor,
                                      role: _role,
                                      onPressed: () {
                                        _navigateAndRefresh(context, true,
                                            index: index);
                                      },
                                    ),
                                    SizedBox(width: 40.0),
                                      ButtonWidget(
                                        labelText: 'Удалить',
                                        icon: Icons.delete_sweep,
                                        iconColor: redBtnColor,
                                        iconAlignment:
                                        IconAlignment.start,
                                        onlyText: true,
                                        listRoles: Roles.asDoctor,
                                        role: _role,
                                        onPressed: () {
                                          _showDeleteDialog(index);
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
