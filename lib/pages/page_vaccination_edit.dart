import 'dart:io';
import 'package:artrit/api/api_vaccination.dart';
import 'package:artrit/data/data_spr_item.dart';
import 'package:artrit/data/data_vaccination.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../data/data_spr_vaccination.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_file.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/input_text.dart';

class PageVaccinationEdit extends StatefulWidget {
  final String title;
  final DataVaccination? thisData;
  final bool isEditForm;

  const PageVaccinationEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageVaccinationEdit> createState() => _PageVaccinationEditState();
}

class _PageVaccinationEditState extends State<PageVaccinationEdit> {
  late Future<void> _future;

  /// API
  final ApiVaccination _api = ApiVaccination();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprVaccination> _thisSprDataVaccination;

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String? _vaccinationId;
  String? _executeDate;
  String? _comment;
  String? _fileId;
  String _fileName = '';
  late File _file;

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
    if (widget.isEditForm) {
      _recordId = widget.thisData!.id != null ? widget.thisData!.id! : '';
      _executeDate = widget.thisData!.executeDate != null
          ? dateFormat(widget.thisData!.executeDate!)
          : null;
      _vaccinationId = widget.thisData!.vaccinationId;
      _comment = widget.thisData!.comment;
      _fileId = widget.thisData!.fileId;
      _fileName = widget.thisData!.fileName ?? '';
    }

    _thisSprDataVaccination = await _apiSpr.getVaccination();
  }

  void _changeData() async {
    if (!_formKey.currentState!.validate()) {
      showTopBanner(context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await _request();

    setState(() {
      _isLoading = false;
    });

    if (mounted) Navigator.pop(context);
  }


  Future<void> _request() async {
    DataVaccination thisData = DataVaccination(
        vaccinationId: _vaccinationId,
        executeDate: convertStrToDate(_executeDate!),
        comment: _comment);

    widget.isEditForm
        ? await _api.put(
        patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.postWithFile(
        requestType: 'POST',
        patientsId: _patientsId,
        filePath: _file.path,
        fileName: _fileName,
        vaccinationId: _vaccinationId ?? '',
        comment: _comment ?? '',
        executeDate: convertStrToDate(_executeDate!).toString());
  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _vaccinationId != null ||
          _comment != null ||
          _fileId != null ||
          _fileName.isNotEmpty;
    }

    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _vaccinationId != w.vaccinationId ||
        _executeDate != dateFormat(w.executeDate) ||
        _comment != w.comment ||
        _fileId != w.fileId ||
        _fileName != w.fileName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: getFormTitle(widget.isEditForm),
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () {
          onBack(context, (_areDifferent()));
        },
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          FormHeaderWidget(title: widget.title),
                          buildForm(),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: ButtonWidget(
                        labelText: 'Сохранить',
                        showProgressIndicator: _isLoading,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () {
                          _changeData();
                        },
                      ),
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
        WidgetInputSelectDateTime(
          labelText: 'Дата',
          fieldKey: _keys[Enum.createdOn]!,
          value: _executeDate,
          lastDateTime: getMoscowDateTime(),
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _executeDate = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Вакцинация',
          fieldKey: _keys[Enum.name]!,
          allValues: _thisSprDataVaccination.map((e) => SprItem(id: e.id ?? '', name: e.name ?? '')).toList(),
          selectedValue: _vaccinationId,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _vaccinationId = value;
            });
          },
        ),
        InputFile(
          labelText: 'Файл',
          fieldKey: _keys[Enum.filename]!,
          required: true,
          fileName: _fileName,
          fileId: _fileId,
          showUploadIcon: widget.isEditForm ? false : true,
          listRoles: Roles.asPatient,
          role: _role,
          onFileUploaded: (fileItems) {
            if (fileItems != null) {
              _fileName = fileItems.fileName;
              _file = fileItems.file;
            }
          },
        ),
        InputText(
          labelText: 'Комментарий',
          fieldKey: _keys[Enum.comment]!,
          value: _comment,
          maxLength: 200,
          required: false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _comment = value;
            });
          },
        ),
      ],
    );
  }
}
