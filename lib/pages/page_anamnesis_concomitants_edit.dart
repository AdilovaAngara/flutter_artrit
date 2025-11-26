import 'package:artrit/api/api_anamnesis_concomitants.dart';
import 'package:artrit/data/data_anamnesis_concomitants.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_text.dart';

class PageAnamnesisConcomitantsEdit extends StatefulWidget {
  final String title;
  final DataAnamnesisConcomitants? thisData;
  final bool isEditForm;

  const PageAnamnesisConcomitantsEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm
  });

  @override
  State<PageAnamnesisConcomitantsEdit> createState() =>
      _PageAnamnesisConcomitantsEditState();
}

class _PageAnamnesisConcomitantsEditState
    extends State<PageAnamnesisConcomitantsEdit> {
  late Future<void> _future;

  /// API
  final ApiAnamnesisConcomitants _api = ApiAnamnesisConcomitants();

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  int? _creationDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _diagnosis;
  String? _dateStart;
  String? _dateEnd;
  bool? _toThisTime;
  String? _comment;

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
      _recordId = widget.thisData!.id!;
      _dateStart = widget.thisData!.dateStart != null
          ? convertTimestampToDate(widget.thisData!.dateStart!)
          : null;
      _dateEnd = widget.thisData!.endDate != null &&
              widget.thisData!.endDate!.date != null &&
              widget.thisData!.endDate!.date.toString().isNotEmpty
          ? convertTimestampToDate(widget.thisData!.endDate!.date!)
          : null;
      _toThisTime = widget.thisData!.endDate != null &&
              widget.thisData!.endDate!.checkbox != null
          ? widget.thisData!.endDate!.checkbox
          : null;
      _diagnosis = widget.thisData!.diagnosis ?? '';
      _comment = widget.thisData!.comment ?? '';
      _creationDate = widget.thisData!.creationDate!;
    }
    setState(() {});
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
    DataAnamnesisConcomitants thisData = DataAnamnesisConcomitants(
        diagnosis: _diagnosis,
        creationDate: _creationDate,
        dateStart: convertToTimestamp(_dateStart!),
        endDate: EndDate(
            date: _dateEnd != null ? convertToTimestamp(_dateEnd!) : null,
            checkbox: _toThisTime),
        comment: _comment);

    widget.isEditForm
        ? await _api.put(
        patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }



  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _dateStart != null ||
          _dateEnd != null ||
          _toThisTime != null ||
          _diagnosis != null ||
          _comment != null;
    }
    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _dateStart != convertTimestampToDate(w.dateStart) ||
        _dateEnd !=
            (w.endDate?.date != null
                ? convertTimestampToDate(w.endDate!.date!)
                : null) ||
        _toThisTime != w.endDate?.checkbox ||
        _diagnosis != w.diagnosis ||
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
        InputText(
          labelText: 'Название заболевания',
          fieldKey: _keys[Enum.diagnosis]!,
          value: _diagnosis,
          maxLength: 200,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _diagnosis = value;
            });
          },
        ),
        InputSelectDate(
          labelText: 'Дата начала',
          fieldKey: _keys[Enum.dateStart]!,
          value: _dateStart,
          initialDate: _dateStart != null
              ? convertStrToDate(_dateStart!)
              : _dateEnd != null
                  ? convertStrToDate(_dateEnd!)
                  : null,
          lastDate: _dateEnd != null ? convertStrToDate(_dateEnd!) : null,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dateStart = value;
            });
          },
        ),
        if (_toThisTime == null || !_toThisTime!)
          InputSelectDate(
            labelText: 'Дата окончания',
            fieldKey: _keys[Enum.endDate]!,
            value: _dateEnd,
            firstDate: _dateStart != null ? convertStrToDate(_dateStart!) : null,
            required: true,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _dateEnd = value;
              });
            },
          ),
        InputCheckbox(
          fieldKey: _keys[Enum.toThisTime]!,
          labelText: 'По настоящее время',
          value: _toThisTime ?? false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dateEnd = null;
              _toThisTime = value;
            });
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
