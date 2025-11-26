import 'package:artrit/api/api_treatment_side_effects.dart';
import 'package:artrit/data/data_treatment_side_effects.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../data/data_spr_side_effects.dart';
import '../data/data_spr_treatment_results.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/input_select.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_text.dart';

class PageTreatmentSideEffectsEdit extends StatefulWidget {
  final String title;
  final DataTreatmentSideEffects? thisData;
  final bool isEditForm;

  const PageTreatmentSideEffectsEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTreatmentSideEffectsEdit> createState() => _PageTreatmentSideEffectsEditState();
}

class _PageTreatmentSideEffectsEditState extends State<PageTreatmentSideEffectsEdit> {
  late Future<void> _future;
  /// API
  final ApiTreatmentSideEffects _api = ApiTreatmentSideEffects();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprSideEffects> _thisSprDataSideEffects;
  late List<DataSprTreatmentResults> _thisSprDataTreatmentResults;
  List<String> _listSprSideEffects = [];
  List<String> _listSprTreatmentResults = [];


  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  int? _creationDate = convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _date;
  String? _dateEnd;
  bool? _toThisTime;
  String? _ny;
  String? _treatAdvEv;
  String? _treatOut;
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
    _thisSprDataSideEffects = await _apiSpr.getSideEffects();
    _thisSprDataTreatmentResults = await _apiSpr.getTreatmentResults();

    _listSprSideEffects = _thisSprDataSideEffects
        .map((e) => e.name)
        .toList()
      ..sort();

    _listSprTreatmentResults = _thisSprDataTreatmentResults
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id!;
      _date = widget.thisData!.date != null ? convertTimestampToDate(widget.thisData!.date!) : null;
      _dateEnd = widget.thisData!.dateEnd != null && widget.thisData!.dateEnd!.date != null && widget.thisData!.dateEnd!.date.toString().isNotEmpty ? convertTimestampToDate(widget.thisData!.dateEnd!.date!) : null;
      _toThisTime = widget.thisData!.dateEnd != null && widget.thisData!.dateEnd!.checkbox != null ? widget.thisData!.dateEnd!.checkbox : null;
      _ny = widget.thisData!.ny;
      _treatAdvEv = widget.thisData!.treatAdvEv;
      _treatOut = widget.thisData!.treatOut;
      _comment = widget.thisData!.comment;
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
    DataTreatmentSideEffects thisData = DataTreatmentSideEffects(
        date: convertToTimestamp(_date!),
        ny: _ny,
        comment: _comment,
        treatOut: _treatOut,
        creationDate: _creationDate,
        treatAdvEv: _treatAdvEv,
        dateEnd: DateEnd(date: _dateEnd != null ? convertToTimestamp(_dateEnd!) : null, checkbox: _toThisTime));

    widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }



  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _date != null ||
          _dateEnd != null ||
          _toThisTime != null ||
          _ny != null ||
          _toThisTime != null ||
          _treatOut != null ||
          _comment != null;
    }
    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _date != convertTimestampToDate(w.date) ||
        _dateEnd != (w.dateEnd?.date != null ? convertTimestampToDate(w.dateEnd!.date!) : null) ||
        _toThisTime != w.dateEnd?.checkbox ||
        _ny != w.ny ||
        _treatAdvEv != w.treatAdvEv ||
        _treatOut != w.treatOut ||
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
        onPressed: () { onBack(context, (_areDifferent())); },
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
        InputSelect(
          labelText: 'Нежелательное явление',
          fieldKey: _keys[Enum.ny]!,
          value: _ny,
          required: true,
          listValues: _listSprSideEffects,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _ny = value;
            });
          },
        ),
        InputSelectDate(
          labelText: 'Дата начала нежелательного явления',
          fieldKey: _keys[Enum.date]!,
          value: _date,
          initialDate: _date != null
              ? convertStrToDate(_date!)
              : _dateEnd != null
              ? convertStrToDate(_dateEnd!)
              : null,
          lastDate: _dateEnd != null
              ? convertStrToDate(_dateEnd!)
              : null,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _date = value;
            });
          },
        ),
        if (_toThisTime == null || !_toThisTime!)
          InputSelectDate(
            labelText: 'Дата окончания нежелательного явления',
            fieldKey: _keys[Enum.dateEnd]!,
            value: _dateEnd,
            firstDate: _date != null
                ? convertStrToDate(_date!)
                : null,
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
          labelText: 'Лечение нежелательного явления',
          fieldKey: _keys[Enum.treatAdvEv]!,
          value: _treatAdvEv,
          maxLength: 200,
          required: false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _treatAdvEv = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Исход лечения',
          fieldKey: _keys[Enum.treatOut]!,
          value: _treatOut,
          required: true,
          listValues: _listSprTreatmentResults,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _treatOut = value;
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
