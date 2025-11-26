import 'package:artrit/api/api_treatment_rehabilitations.dart';
import 'package:artrit/data/data_treatment_rehabilitations.dart';
import 'package:artrit/pages/page_treatment_rehabilitation_edit.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/treatment_rehabilitations_view_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/list_tile_expand_widget.dart';
import '../widgets/show_dialog_delete.dart';
import 'menu.dart';

class PageTreatmentRehabilitation extends StatefulWidget {
  final String title;

  const PageTreatmentRehabilitation({
    super.key,
    required this.title
  });

  @override
  State<PageTreatmentRehabilitation> createState() => PageTreatmentRehabilitationState();
}

class PageTreatmentRehabilitationState extends State<PageTreatmentRehabilitation> {
  late Future<void> _future;

  /// API
  final ApiTreatmentRehabilitations _api = ApiTreatmentRehabilitations();

  /// Данные
  List<DataTreatmentRehabilitations>? _thisData;

  /// Параметры
  late int _role;
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
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisData = await _api.get(patientsId: _patientsId);
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
      MaterialPageRoute(
        builder: (context) => PageTreatmentRehabilitationEdit(
          title: widget.title,
          isEditForm: isEditForm,
          thisData: isEditForm ? _thisData![index!] : null,),
      ),
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
            String recordId = _thisData![index].id!;
            await _api.delete(
                patientsId: _patientsId,
                recordId: recordId);
            await _refreshData();
          },
        );
      },
    );
  }

  bool _delBtnShow(List<DataTreatmentRehabilitations> thisData, int index) {
    String? date = dateTimeFormat(getMoscowDateTime());
    if (thisData[index].creationDate != null) {
      date = convertTimestampToDateTime(thisData[index].creationDate!);
    }
    return delBtnShowCalculate(date);
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
                            listRoles: Roles.asPatient,
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
                            title: _thisData![index].typeRehabil != null
                                ? _thisData![index].typeRehabil!.type ?? ''
                                : 'Название не указано',
                            subtitle: getSubtitleTreatmentRehabilitations(_thisData![index]),
                            currentIndex: _currentExpandedIndex,
                            itemCount: _thisData!.length,
                            onPrevious: _navigateToPrevious,
                            onNext: _navigateToNext,
                            showNavigateIcons: Roles.asPatient.contains(_role) ? true : false,
                            isExpanded: index == _currentExpandedIndex,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _currentExpandedIndex = expanded ? index : -1;
                              });
                            },
                            child: (_thisData![index].typeRehabil!.type == 'Физиотерапия' || Roles.asPatient.contains(_role))
                            ? Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                TreatmentRehabilitationsViewWidget(
                                  thisData: _thisData![index],
                                ),
                                Row(
                                  children: [
                                    ButtonWidget(
                                      labelText: 'Изменить',
                                      icon: Icons.edit_note,
                                      iconAlignment: IconAlignment.start,
                                      onlyText: true,
                                      listRoles: Roles.asPatient,
                                      role: _role,
                                      onPressed: () {
                                        _navigateAndRefresh(context, true,
                                            index: index);
                                      },
                                    ),
                                    SizedBox(width: 40.0),
                                    if (_delBtnShow(_thisData!, index))
                                      ButtonWidget(
                                        labelText: 'Удалить',
                                        icon: Icons.delete_sweep,
                                        iconColor: redBtnColor,
                                        iconAlignment:
                                        IconAlignment.start,
                                        onlyText: true,
                                        listRoles: Roles.asPatient,
                                        role: _role,
                                        onPressed: () {
                                          _showDeleteDialog(index);
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ) : null,
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
