import 'dart:io';
import 'package:artrit/data/data_researches_other.dart';
import 'package:flutter/material.dart';
import '../api/api_researches_other.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_text.dart';
import '../widgets/input_file.dart';

class PageResearchesOtherEdit extends StatefulWidget {
  final String title;
  final DataResearchesOther? thisData;
  final bool isEditForm;
  final VoidCallback? onDataUpdated;

  const PageResearchesOtherEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
    required this.onDataUpdated,
  });

  @override
  State<PageResearchesOtherEdit> createState() => PageResearchesOtherEditState();
}

class PageResearchesOtherEditState extends State<PageResearchesOtherEdit> {
  late Future<void> _future;

  /// API
  final ApiResearchesOther _api = ApiResearchesOther();

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String _name = '';
  String? _executeDate;
  late DateTime? _createdOn = getMoscowDateTime();
  String? _comment;
  late List<FileElement>? _files;
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
      _createdOn = widget.thisData!.createdOn;
      _name = widget.thisData!.name!;
      _comment = widget.thisData!.comment;
      _files = widget.thisData!.files;

      _files != null && _files!.isNotEmpty
          ? _fileId = _files![0].id : _fileId = null;

      _files != null && _files!.isNotEmpty && _files![0].fileName != null
          ? _fileName = _files![0].fileName! : _fileName;
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

    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    if (mounted) Navigator.pop(context);
  }


  Future<void> _request() async {
    DataResearchesOther thisData = DataResearchesOther(
        name: _name,
        executeDate: converStrToDate(_executeDate!),
        comment: _comment,
        createdOn: _createdOn);

    widget.isEditForm
        ? await _api.put(
        patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.postWithFile(
        requestType: 'POST',
        patientsId: _patientsId,
        filePath: _file.path,
        fileName: _fileName,
        name: _name,
        comment: _comment ?? '',
        executeDate: _executeDate!);
  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _name.isNotEmpty ||
          _executeDate != null ||
          _comment != null ||
          _fileName.isNotEmpty ||
          _fileId != null;
    }

    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _executeDate != dateFormat(w.executeDate) ||
        _name != w.name ||
        _comment != w.comment;
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
        InputSelectDate(
          labelText: 'Дата',
          fieldKey: _keys[Enum.executeDate]!,
          value: _executeDate,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _executeDate = value;
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
          fieldKey: _keys[Enum.files]!,
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
