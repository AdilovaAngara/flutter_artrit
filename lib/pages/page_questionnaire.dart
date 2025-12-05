import 'package:artrit/pages/page_questionnaire_edit.dart';
import 'package:flutter/material.dart';

import '../api/api_questionnaire.dart';
import '../data/data_questionnaire.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/show_dialog_delete.dart';
import 'menu.dart';

class PageQuestionnaire extends StatefulWidget {
  final String title;

  const PageQuestionnaire({
    super.key,
    required this.title,
  });

  @override
  State<PageQuestionnaire> createState() => PageQuestionnaireState();
}

class PageQuestionnaireState extends State<PageQuestionnaire> {
  late Future<void> _future;

  /// API
  final ApiQuestionnaire _api = ApiQuestionnaire();

  /// Данные
  List<DataQuestionnaire>? _thisData;

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
    _thisData = await _api.get(patientsId: _patientsId);

    setState(() {
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Future<void> _navigateAndRefresh(BuildContext context, bool isEditForm,
      {int? index}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageQuestionnaireEdit(
          title: widget.title,
          isEditForm: isEditForm,
          isAnonymous: false,
          thisData: (isEditForm) ? _thisData![index!] : null,
        ),
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
            // Сделать асинхронным
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

  bool _delBtnShow(List<DataQuestionnaire> thisData, int index) {
    String? date = dateTimeFormat(getMoscowDateTime());
    if (thisData[index].creationDate != null) {
      date = convertTimestampToDateTime(thisData[index].creationDate!);
    }
    return delBtnShowCalculate(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
      ),
      endDrawer: const MenuDrawer(),
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
                      itemCount: _thisData!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: paddingListTile(index),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            title: Text(
                              'Опросник качества жизни',
                              style: captionMenuTextStyle,
                            ),
                            subtitle: Column(
                              children: [
                                SizedBox(height: 3.0,),
                                Row(
                                  children: [
                                    Text('Дата:', style: labelStyle),
                                    SizedBox(
                                      width: 10),
                                    Text(dateTimeFormat(_thisData?[index].questdate) ?? '',
                                        style: inputTextStyle)],
                                ),
                                Row(
                                  children: [
                                    Text('Результат:', style: labelStyle),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('${_thisData?[index].result}',
                                        style: inputTextStyle),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_delBtnShow(_thisData!, index))
                                  ButtonWidget(
                                    labelText: '',
                                    icon: Icons.delete,
                                    iconColor: redBtnColor,
                                    iconSize: 25,
                                    onlyText: true,
                                    listRoles: Roles.asPatient,
                                    role: _role,
                                    onPressed: () {
                                      _showDeleteDialog(index);
                                    },
                                  ),
                                ButtonWidget(
                                  labelText: '',
                                  icon: Roles.asPatient.contains(_role) ? Icons.edit : Icons.visibility,
                                  iconSize: 25,
                                  onlyText: true,
                                  listRoles: Roles.all,
                                  onPressed: () {
                                    _navigateAndRefresh(context, true, index: index);
                                  },
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
