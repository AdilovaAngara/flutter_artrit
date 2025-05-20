import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../api/api_patient.dart';
import '../data/data_patient.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../api/api_report.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/file_utils.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/input_select_date.dart';
import '../widgets/show_message.dart';
import 'menu.dart';

class PageReport extends StatefulWidget {
  final String title;

  const PageReport({
    super.key,
    required this.title,
  });

  @override
  State<PageReport> createState() => _PageReportState();
}

class _PageReportState extends State<PageReport> {
  late Future<void> _future;

  /// API
  final ApiReport _api = ApiReport();
  final ApiPatient _apiPatient = ApiPatient();

  /// Данные
  late DataPatient _dataPatient;

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _patientsId;
  late String? _birthDate;
  String? _startDate;
  String? _endDate;
  bool _allTime = false;
  bool _isDoctor = false;
  bool _isPatient = false;
  bool _download = false;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }


  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _dataPatient = await _apiPatient.get(patientsId: _patientsId);
    _birthDate = convertTimestampToDate(_dataPatient.birthDate);
    setState(() {});
  }


  void _changeData() async {
    if (!_formKey.currentState!.validate()) {
      showBottomBanner(context: context, message: 'Выберите хотя бы одно значение');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    dynamic response = await _request();

    if (response != null) {
      String fileName = 'report $_startDate - $_endDate.pdf';

      if (_download) {
        Uint8List fileData = response.bodyBytes;
        final filePath = await FileUtils.saveFile(
          fileData: fileData,
          fileName: fileName,
          context: context,
        );
        if (filePath == null && mounted) {
          ShowMessage.show(context: context, message: 'Не удалось сохранить отчёт');
        }
      } else {
        if (mounted) {
          ShowMessage.show(
          context: context,
          message: (response.body ?? 'Неизвестная ошибка')
              .replaceAll('File has been Sent To Patient', 'Файл успешно отправлен')
              .replaceAll('File has been Sent To Doctor', 'Файл успешно отправлен')
              .replaceAll('File has been Sent', 'Файл успешно отправлен')
              .replaceAll('Not Found Doctor Email', 'Не удалось отправить файл. У доктора не указан e-mail')
              .replaceAll('Not Found', 'Ошибка! Файл не найден')
              .replaceAll('"', '')
              .replaceAll("'", ''),
        );
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }




  Future<dynamic> _request() async {
    if (Roles.asDoctor.contains(_role)) _download = true;

    return await _api.post(
      patientsId: _patientsId,
      startDate: convertToTimestamp(_startDate)!,
      endDate: convertToTimestamp(_endDate)!,
      isDoctor: _isDoctor,
      isPatient: _isPatient,
      download: _download,
    );
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

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      //padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          buildForm(),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                  Text('Пожалуйста, ожидайте! Процесс формирования отчета длится около минуты'),
                  Center(
                    child: ButtonWidget(
                      labelText: 'Сформировать',
                      showProgressIndicator: _isLoading,
                      listRoles: Roles.all,
                      onPressed: () async {
                        _changeData();
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

  Widget buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputCheckbox(
          labelText: 'За весь период',
          fieldKey: _keys[Enum.allTime]!,
          value: _allTime,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _allTime = value;
              if (_allTime) {
                _startDate = _birthDate;
                _endDate = dateFormat(getMoscowDateTime());
              }
              else {
                _startDate = null;
                _endDate = null;
              }
            });
          },
        ),
        if (!_allTime)
          ...[
            InputSelectDate(
              labelText: 'Начало периода',
              fieldKey: _keys[Enum.startDate]!,
              value: _startDate,
              initialDate: _startDate != null
                  ? converStrToDate(_startDate!)
                  : _endDate != null
                  ? converStrToDate(_endDate!)
                  : null,
              lastDate:
              _endDate != null ? converStrToDate(_endDate!) : null,
              required: true,
              listRoles: Roles.all,
              onChanged: (value) {
                setState(() {
                  _startDate = value;
                });
              },
            ),
            InputSelectDate(
              labelText: 'Конец периода',
              fieldKey: _keys[Enum.endDate]!,
              value: _endDate,
              firstDate:
              _startDate != null ? converStrToDate(_startDate!) : null,
              required: true,
              listRoles: Roles.all,
              onChanged: (value) {
                setState(() {
                  _endDate = value;
                });
              },
            ),
          ],
        if (Roles.asPatient.contains(_role)) ...[
          InputCheckbox(
            labelText: 'Скачать отчет',
            fieldKey: _keys[Enum.download]!,
            value: _download,
            requiredTrue: _isPatient ||_isDoctor ? false : true,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _download = value;
              });
            },
          ),
          InputCheckbox(
            labelText: 'Отправить отчет себе',
            fieldKey: _keys[Enum.isPatient]!,
            value: _isPatient,
            requiredTrue: _download ||_isDoctor ? false : true,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _isPatient = value;
              });
            },
          ),
          InputCheckbox(
            labelText: 'Отправить отчет врачу',
            fieldKey: _keys[Enum.isDoctor]!,
            value: _isDoctor,
            requiredTrue: _download ||_isPatient ? false : true,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _isDoctor = value;
              });
            },
          ),
        ],
      ],
    );
  }

}