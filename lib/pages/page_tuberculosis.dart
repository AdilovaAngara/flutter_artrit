import 'package:artrit/pages/page_tuberculosis_edit.dart';
import 'package:flutter/material.dart';
import '../api/api_tuberculosis.dart';
import '../data/data_tuberculosis.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/tuberculosis_view_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/list_tile_expand_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/show_dialog_delete.dart';
import 'menu.dart';

class PageTuberculosis extends StatefulWidget {
  final String title;

  const PageTuberculosis({
    super.key,
    required this.title,
  });

  @override
  State<PageTuberculosis> createState() => PageTuberculosisState();
}

class PageTuberculosisState extends State<PageTuberculosis> {
  late Future<void> _future;

  /// API
  final ApiTuberculosis _api = ApiTuberculosis();

  /// Данные
  List<DataTuberculosis>? _thisData;

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
      {int? index}) {navigateToPage(context,
    PageTuberculosisEdit(
      title: widget.title,
      isEditForm: isEditForm,
      thisData: (isEditForm) ? _thisData![index!] : null,
      onDataUpdated: () => _refreshData(),
    ),
  );}


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

  bool _delBtnShow(List<DataTuberculosis> thisData, int index) {
    String? date = dateTimeFormat(getMoscowDateTime());
    if (thisData[index].createdOn != null) {
      date = dateTimeFormat(thisData[index].createdOn!);
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
                            title: widget.title,
                            subtitle: _thisData![index].treatmentBeginDate != null &&
                                _thisData![index].treatmentEndDate!= null ?
                            '${dateFormat(_thisData![index].treatmentBeginDate!)} - ${dateFormat(
                                _thisData![index].treatmentEndDate!)}' : 'Период не указан',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TuberculosisViewWidget(
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
                                        iconAlignment: IconAlignment.start,
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
