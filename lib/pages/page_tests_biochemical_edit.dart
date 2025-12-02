import 'package:artrit/data/data_tests_biochemical.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_tests_biochemical.dart';
import '../data/data_tests_options.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text_with_select.dart';
import '../widgets/widget_input_select_date_time.dart';

class PageTestsBiochemicalEdit extends StatefulWidget {
  final String title;
  final DataTestsBiochemical? thisData;
  final bool isEditForm;

  const PageTestsBiochemicalEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTestsBiochemicalEdit> createState() => _PageTestsBiochemicalEditState();
}

class _PageTestsBiochemicalEditState extends State<PageTestsBiochemicalEdit> {
  late Future<void> _future;
  /// API
  final ApiTestsBiochemical _api = ApiTestsBiochemical();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataTestsOptions> _dataSprTestsOptions;

  /// Параметры
  late int _role;
  late String _patientsId;
  String? _date = dateTimeFormat(getMoscowDateTime());
  int? _creationDate = convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  bool _required = true;
  bool _isLoading = false; // Флаг загрузки
  late int _fullAge;

  dynamic _ast;
  dynamic _astUnitId;

  dynamic _alt;
  dynamic _altUnitId;

  dynamic _bilirubinTotal;
  dynamic _bilirubinTotalUnitId;

  dynamic _mochevina;
  dynamic _mochevinaUnitId;

  dynamic _creatinine;
  dynamic _creatinineUnitId;

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
    _fullAge = int.parse(await readSecureData(SecureKey.fullAge));
    _dataSprTestsOptions = await _apiSpr.getTestsOptions(_fullAge);

    if (widget.isEditForm) {
      _date = convertTimestampToDateTime(widget.thisData!.date!);
      _creationDate = widget.thisData!.items.ast.creationDate;

      _ast = widget.thisData!.items.ast.analysisPatientValue;
      _astUnitId = widget.thisData!.items.ast.analysisPatientUnitId;

      _alt = widget.thisData!.items.alt.analysisPatientValue;
      _altUnitId = widget.thisData!.items.alt.analysisPatientUnitId;

      _bilirubinTotal = widget.thisData!.items.bilirubinTotal.analysisPatientValue;
      _bilirubinTotalUnitId = widget.thisData!.items.bilirubinTotal.analysisPatientUnitId;

      _mochevina = widget.thisData!.items.mochevina.analysisPatientValue;
      _mochevinaUnitId = widget.thisData!.items.mochevina.analysisPatientUnitId;

      _creatinine = widget.thisData!.items.creatinine.analysisPatientValue;
      _creatinineUnitId = widget.thisData!.items.creatinine.analysisPatientUnitId;

      _required = _getRequired();
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
    DataTestsBiochemical thisData = DataTestsBiochemical(
      isCreate: !widget.isEditForm,
      date: convertToTimestamp(_date),
      patientId: _patientsId,
      items: Items(
        alt: ItemsChild(
            analysisPatientId: widget.thisData!.items.alt.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.alt.analysisPatientDate,
            analysisPatientValue: _alt,
            analysisPatientUnitId: _altUnitId,
            analysisId: widget.thisData!.items.alt.analysisId,
            analysisName: widget.thisData!.items.alt.analysisName,
            analysisKeyName: widget.thisData!.items.alt.analysisKeyName,
            norma: _getNorma(_alt, _altUnitId),
            minmax: _getMinMax(_alt, _altUnitId),
            creationDate: _creationDate),
        ast: ItemsChild(
            analysisPatientId: widget.thisData!.items.ast.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.ast.analysisPatientDate,
            analysisPatientValue: _ast,
            analysisPatientUnitId: _astUnitId,
            analysisId: widget.thisData!.items.ast.analysisId,
            analysisName: widget.thisData!.items.ast.analysisName,
            analysisKeyName: widget.thisData!.items.ast.analysisKeyName,
            norma: _getNorma(_ast, _astUnitId),
            minmax: _getMinMax(_ast, _astUnitId),
            creationDate: _creationDate),
        bilirubinTotal: ItemsChild(
            analysisPatientId: widget.thisData!.items.bilirubinTotal.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.bilirubinTotal.analysisPatientDate,
            analysisPatientValue: _bilirubinTotal,
            analysisPatientUnitId: _bilirubinTotalUnitId,
            analysisId: widget.thisData!.items.bilirubinTotal.analysisId,
            analysisName: widget.thisData!.items.bilirubinTotal.analysisName,
            analysisKeyName: widget.thisData!.items.bilirubinTotal.analysisKeyName,
            norma: _getNorma(_bilirubinTotal, _bilirubinTotalUnitId),
            minmax: _getMinMax(_bilirubinTotal, _bilirubinTotalUnitId),
            creationDate: _creationDate),
        mochevina: ItemsChild(
            analysisPatientId: widget.thisData!.items.mochevina.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.mochevina.analysisPatientDate,
            analysisPatientValue: _mochevina,
            analysisPatientUnitId: _mochevinaUnitId,
            analysisId: widget.thisData!.items.mochevina.analysisId,
            analysisName: widget.thisData!.items.mochevina.analysisName,
            analysisKeyName: widget.thisData!.items.mochevina.analysisKeyName,
            norma: _getNorma(_mochevina, _mochevinaUnitId),
            minmax: _getMinMax(_mochevina, _mochevinaUnitId),
            creationDate: _creationDate),
        creatinine: ItemsChild(
            analysisPatientId: widget.thisData!.items.creatinine.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.creatinine.analysisPatientDate,
            analysisPatientValue: _creatinine,
            analysisPatientUnitId: _creatinineUnitId,
            analysisId: widget.thisData!.items.creatinine.analysisId,
            analysisName: widget.thisData!.items.creatinine.analysisName,
            analysisKeyName: widget.thisData!.items.creatinine.analysisKeyName,
            norma: _getNorma(_creatinine, _creatinineUnitId),
            minmax: _getMinMax(_creatinine, _creatinineUnitId),
            creationDate: _creationDate),
      ),
    );
    await _api.post(patientsId: _patientsId, thisData: thisData);
  }


  bool _areDifferent() {
    if (widget.isEditForm) {
      return (
          _date != convertTimestampToDateTime(widget.thisData!.date!) ||
              _ast != widget.thisData!.items.ast.analysisPatientValue ||
              _astUnitId != widget.thisData!.items.ast.analysisPatientUnitId ||
              _alt != widget.thisData!.items.alt.analysisPatientValue ||
              _altUnitId != widget.thisData!.items.alt.analysisPatientUnitId ||
              _bilirubinTotal != widget.thisData!.items.bilirubinTotal.analysisPatientValue ||
              _bilirubinTotalUnitId != widget.thisData!.items.bilirubinTotal.analysisPatientUnitId ||
              _mochevina != widget.thisData!.items.mochevina.analysisPatientValue ||
              _mochevinaUnitId != widget.thisData!.items.mochevina.analysisPatientUnitId ||
              _creatinine != widget.thisData!.items.creatinine.analysisPatientValue ||
              _creatinineUnitId != widget.thisData!.items.creatinine.analysisPatientUnitId
      );
    } else {
      return (
          _ast != null ||
              _alt != null ||
              _bilirubinTotal != null ||
              _mochevina != null ||
              _creatinine != null
      );
    }
  }



  List<String> _getUnitList(String analysisId) {
    final unitList = _dataSprTestsOptions
        .where((e) => e.analysisId == analysisId)
        .map((e) => e.unitName ?? '')
        .toSet() // Удаляем дубликаты
        .toList()
      ..sort();
    return unitList.isNotEmpty ? unitList : ['Нет данных'];
  }


  String? _getUnitId(String analysisId, String? unitName) {
    String? unitId;
    if (unitName != null) {
      unitId = _dataSprTestsOptions
          .firstWhereOrNull((e) => e.analysisId == analysisId && e.unitName == unitName)?.unitId;
    }
    return (unitId != null && unitId.isNotEmpty) ? unitId : null;
  }


  double? _getUnitMinValue(String analysisId, String? unitId) {
    List<double?>? listUnits;
    if (unitId != null) {
      listUnits = _dataSprTestsOptions
          .where((e) => e.analysisId == analysisId && e.unitId == unitId)
          .map((e) => e.minValue)
          .toList();
    }
    return (listUnits != null && listUnits.isNotEmpty) ? listUnits.first : null;
  }


  double? _getUnitMaxValue(String analysisId, String? unitId) {
    List<double?>? listUnits;
    if (unitId != null) {
      listUnits = _dataSprTestsOptions
          .where((e) => e.analysisId == analysisId && e.unitId == unitId)
          .map((e) => e.maxValue)
          .toList();
    }
    return (listUnits != null && listUnits.isNotEmpty) ? listUnits.first : null;
  }


  Minmax? _getMinMax(dynamic value, String? unitId)
  {
    return (unitId != null && value != null) ? Minmax(name: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.name,
        keyName: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.keyName,
        id: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.id,
        analysisId: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.analysisId,
        unitId: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.unitId,
        ageMin: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.ageMin,
        ageMax: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.ageMax,
        minValue: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.minValue,
        maxValue: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.maxValue,
        refMIn: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.refMIn,
        refMax: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.refMax,
        gender: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.gender,
        unitName: _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == unitId)?.unitName) : null;
  }


  bool _getNorma(dynamic value, String? unitId){
    Minmax? getMinMax = _getMinMax(value, unitId);
    if (getMinMax != null) {
      return (value > getMinMax.refMIn && value < getMinMax.refMax);
    }
    else {
      return true;
    }
  }

  bool _getRequired(){
    return (_ast == null &&
        _alt == null &&
        _bilirubinTotal == null &&
        _mochevina == null &&
        _creatinine == null) ? true
        : false;
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
                          SizedBox(height: 30.0),
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
        InputTextWithSelect(
          labelText: widget.thisData!.items.ast.analysisName ?? 'АСТ',
          fieldKey: _keys[Enum.ast]!,
          initialValue: _ast,
          unitOptions: _getUnitList(widget.thisData!.items.ast.analysisId),
          initialUnit: (_astUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _astUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.ast.analysisId, _astUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.ast.analysisId, _astUnitId),
          onChanged: (value) {
            setState(() {
              _ast = value.value;
              _astUnitId = _getUnitId(widget.thisData!.items.ast.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.alt.analysisName ?? 'АЛТ',
          fieldKey: _keys[Enum.alt]!,
          initialValue: _alt,
          unitOptions: _getUnitList(widget.thisData!.items.alt.analysisId),
          initialUnit: (_altUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _altUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.alt.analysisId, _altUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.alt.analysisId, _altUnitId),
          onChanged: (value) {
            setState(() {
              _alt = value.value;
              _altUnitId = _getUnitId(widget.thisData!.items.alt.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.bilirubinTotal.analysisName ?? 'Билирубин общий',
          fieldKey: _keys[Enum.bilirubinTotal]!,
          initialValue: _bilirubinTotal,
          unitOptions: _getUnitList(widget.thisData!.items.bilirubinTotal.analysisId),
          initialUnit: (_bilirubinTotalUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _bilirubinTotalUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.bilirubinTotal.analysisId, _bilirubinTotalUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.bilirubinTotal.analysisId, _bilirubinTotalUnitId),
          onChanged: (value) {
            setState(() {
              _bilirubinTotal = value.value;
              _bilirubinTotalUnitId = _getUnitId(widget.thisData!.items.bilirubinTotal.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.mochevina.analysisName ?? 'Мочевина',
          fieldKey: _keys[Enum.mochevina]!,
          initialValue: _mochevina,
          unitOptions: _getUnitList(widget.thisData!.items.mochevina.analysisId),
          initialUnit: (_mochevinaUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _mochevinaUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.mochevina.analysisId, _mochevinaUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.mochevina.analysisId, _mochevinaUnitId),
          onChanged: (value) {
            setState(() {
              _mochevina = value.value;
              _mochevinaUnitId = _getUnitId(widget.thisData!.items.mochevina.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.creatinine.analysisName ?? 'Креатинин',
          fieldKey: _keys[Enum.creatinine]!,
          initialValue: _creatinine,
          unitOptions: _getUnitList(widget.thisData!.items.creatinine.analysisId),
          initialUnit: (_creatinineUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _creatinineUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.creatinine.analysisId, _creatinineUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.creatinine.analysisId, _creatinineUnitId),
          onChanged: (value) {
            setState(() {
              _creatinine = value.value;
              _creatinineUnitId = _getUnitId(widget.thisData!.items.creatinine.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
      ],
    );
  }
}

