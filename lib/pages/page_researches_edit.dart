import 'dart:io';
import 'package:artrit/api/api_researches.dart';
import 'package:artrit/data/data_researches.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_send_file.dart';
import '../data/data_send_file.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';
import '../widgets/input_file.dart';
import '../widgets/widget_input_select_date_time.dart';

class PageResearchesEdit extends StatefulWidget {
  final String title;
  final DataResearches? thisData;
  final int typeId;
  final bool isEditForm;

  const PageResearchesEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.typeId,
    required this.isEditForm,
  });

  @override
  State<PageResearchesEdit> createState() => PageResearchesEditState();
}

class PageResearchesEditState extends State<PageResearchesEdit> {
  late Future<void> _future;

  /// API
  final ApiResearches _api = ApiResearches();
  final ApiSendFile _apiSendFile = ApiSendFile();

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String _name = '';
  String? _date;
  int? _creationDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _comment;
  String? _fileId;
  String _fileName = '';
  File? _file;

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
      _date = widget.thisData!.date != null
          ? convertTimestampToDateTime(widget.thisData!.date!)
          : null;
      _creationDate = widget.thisData!.creationDate;
      _name = widget.thisData!.name ?? '';
      _comment = widget.thisData!.comment;
      widget.thisData!.fileIds != null && widget.thisData!.fileIds!.isNotEmpty
          ? _fileId = widget.thisData!.fileIds![0]
          : _fileId = null;
      if (widget.thisData!.filename != null) {
        _fileName = widget.thisData!.filename!.join(', ');
      }
    }
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
    if (_file != null) {
      DataSendFile dataSendFile = await _apiSendFile.sendFile(path: _file!.path);
      _fileId = dataSendFile.id;
    }

    DataResearches thisData = DataResearches(
        typeId: widget.typeId,
        name: _name,
        date: convertToTimestamp(_date!),
        comment: _comment,
        fileIds: _fileId != null ? [_fileId!] : null,
        creationDate: _creationDate);

    widget.isEditForm
        ? await _api.put(
        patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _name.isNotEmpty ||
          _date != null ||
          _comment != null ||
          _fileName.isNotEmpty ||
          _fileId != null;
    }

    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return convertToTimestamp(_date ?? '') != w.date ||
        _name != w.name ||
        _comment != w.comment ||
        !listEquals([_fileName], w.filename) ||
        !listEquals([_fileId], w.fileIds);
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
          fieldKey: _keys[Enum.date]!,
          value: _date,
          lastDateTime: getMoscowDateTime(),
          showTime: true,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _date = value;
            });
          },
        ),
        InputText(
          labelText: 'Название',
          fieldKey: _keys[Enum.name]!,
          value: _name,
          maxLength: 100,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        InputFile(
          labelText: 'Файл',
          fieldKey: _keys[Enum.filename]!,
          required: true,
          fileName: _fileName,
          fileId: _fileId,
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
          maxLength: 2000,
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
