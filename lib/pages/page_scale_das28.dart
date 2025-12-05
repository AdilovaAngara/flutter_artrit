import 'package:artrit/api/api_scale_das28.dart';
import 'package:flutter/material.dart';
import '../data/data_scale_das28.dart';
import '../data/data_scale_result.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/label_join_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/list_tile_widget.dart';
import '../widgets/show_dialog_delete.dart';
import '../widgets/show_message.dart';
import 'menu.dart';

class PageScaleDas28 extends StatefulWidget {
  final String title;

  const PageScaleDas28({
    super.key,
    required this.title,
  });

  @override
  State<PageScaleDas28> createState() => _PageScaleDas28State();
}

class _PageScaleDas28State extends State<PageScaleDas28> {
  late Future<void> _future;

  /// API
  final ApiScaleDas28 _api = ApiScaleDas28();

  /// Данные
  List<DataScaleDas28>? _thisData;

  /// Параметры
  bool _isLoading = false;
  late String _patientsId;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisData = await _api.get(patientsId: _patientsId);
    setState(() {});
  }

  Future<void> _refreshData() async {
    await _loadData();
  }


  void _changeData(bool hasEmptyInputs) async {
    if (hasEmptyInputs) {
      showTopBanner(context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    DataScaleResult dataScaleResult = await _request();

    setState(() {
      _isLoading = false;
    });

    if (dataScaleResult.success ?? false)
    {
      _showResultDialog(dataScaleResult);
      await _refreshData();
    }
    else {
      ShowMessage.show(context: context, message: dataScaleResult.userMessage?.toString() ?? 'Неизвестная ошибка');
    }
  }


  Future<DataScaleResult> _request() async {
    DataScaleDas28 thisData = DataScaleDas28(
    );
    return await _api.post(patientsId: _patientsId, thisData: thisData);
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

  bool _delBtnShow(List<DataScaleDas28> thisData, int index) {
    String? date = dateTimeFormat(getMoscowDateTime());
    if (thisData[index].createdOn != null) {
      date = dateTimeFormat(thisData[index].createdOn!);
    }
    return delBtnShowCalculate(date);
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
                            labelText: 'Рассчитать',
                            icon: Icons.add_circle_rounded,
                            onlyText: true,
                            showProgressIndicator: _isLoading,
                            listRoles: Roles.all,
                            onPressed: () {
                              bool hasEmptyInputs = false;
                              _changeData(hasEmptyInputs);
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
                      itemCount: _thisData!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: paddingListTile(index),
                          child: ListTileWidget(
                            title: _thisData![index].createdOn != null
                                ? dateTimeFormat(_thisData![index].createdOn) ?? ''
                                : '',
                            subtitle: '${_thisData![index].indexResult ?? ''}',
                            padding: 0.0,
                            widgetTrailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_delBtnShow(_thisData!, index))
                                  ButtonWidget(
                                    labelText: '',
                                    icon: Icons.delete,
                                    iconColor: redBtnColor,
                                    iconSize: 25,
                                    onlyText: true,
                                    listRoles: Roles.all,
                                    onPressed: () {
                                      _showDeleteDialog(index);
                                    },
                                  ),
                              ],
                            ),
                            onTap: () {},
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





  void _showResultDialog(DataScaleResult dataScaleResult) {
    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext dialogContext, StateSetter dialogSetState) {
                return AlertDialog(
                  title: Text('Расчет индекса',
                    style: formHeaderStyle,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LabelJoinWidget(
                          labelText: 'Дата',
                          value: dataScaleResult.result?.createdOn != null
                              ? dateTimeFormat(dataScaleResult.result!.createdOn!) ?? ''
                              : 'Нет данных',
                          isColumn: false,
                        ),
                        LabelJoinWidget(
                          labelText: 'Ваш индекс',
                          value: dataScaleResult.result?.indexResult?.toString() ?? 'Нет данных',
                          isColumn: false,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ButtonWidget(
                      labelText: 'ОК',
                      onlyText: true,
                      dialogForm: true,
                      listRoles: Roles.all,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                  ],
                );
              }
          );
        });
  }


}