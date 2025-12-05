import 'package:artrit/api/api_scale_doctor.dart';
import 'package:artrit/data/data_scale_doctor.dart';
import 'package:artrit/pages/page_scale_doctor_edit.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/list_tile_widget.dart';
import '../widgets/show_dialog_delete.dart';
import 'menu.dart';

class PageScaleDoctor extends StatefulWidget {
  final String title;

  const PageScaleDoctor({
    super.key,
    required this.title,
  });

  @override
  State<PageScaleDoctor> createState() => _PageScaleDoctorState();
}

class _PageScaleDoctorState extends State<PageScaleDoctor> {
  late Future<void> _future;

  /// API
  final ApiScaleDoctor _api = ApiScaleDoctor();

  /// Данные
  List<DataScaleDoctor>? _thisData;

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
    setState(() {});
  }

  Future<void> _refreshData() async {
    await _loadData();
  }


  void _navigateAndRefresh(BuildContext context, bool isEditForm,
      {int? index}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageScaleDoctorEdit(
            title: widget.title,
            isEditForm: isEditForm,
            thisData: isEditForm ? _thisData![index!] : null),
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

  bool _delBtnShow(List<DataScaleDoctor> thisData, int index) {
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
                      itemCount: _thisData!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: paddingListTile(index),
                          child: ListTileWidget(
                            title: _thisData![index].creationDate != null
                                ? convertTimestampToDateTime(_thisData![index].creationDate) ?? ''
                                : '',
                            subtitle: '${_thisData![index].scale ?? ''}',
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
                                  listRoles: Roles.asDoctor,
                                  role: _role,
                                  onPressed: () {
                                    _showDeleteDialog(index);
                                  },
                                ),
                                ButtonWidget(
                                  labelText: '',
                                  icon: Icons.edit,
                                  iconSize: 25,
                                  onlyText: true,
                                  listRoles: Roles.asDoctor,
                                  role: _role,
                                  onPressed: () {
                                    _navigateAndRefresh(context, true, index: index);
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
}