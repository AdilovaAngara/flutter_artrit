import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_tests_clinical.dart';
import '../data/data_tests_clinical.dart';
import '../data/data_tests_options.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_select_date_time.dart';
import '../widgets/input_text_with_select.dart';

class PageTestsClinicalEdit extends StatefulWidget {
  final String title;
  final DataTestsClinical? thisData;
  final bool isEditForm;
  final VoidCallback? onDataUpdated;

  const PageTestsClinicalEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
    required this.onDataUpdated,
  });

  @override
  State<PageTestsClinicalEdit> createState() => _PageTestsClinicalEditState();
}

class _PageTestsClinicalEditState extends State<PageTestsClinicalEdit> {
  late Future<void> _future;
  /// API
  final ApiTestsClinical _api = ApiTestsClinical();
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

  dynamic _thrombocytes;
  dynamic _thrombocytesUnitId;

  dynamic _soe;
  dynamic _soeUnitId;

  dynamic _neutrophils;
  dynamic _neutrophilsUnitId;

  dynamic _monocytes;
  dynamic _monocytesUnitId;

  dynamic _eosinophils;
  dynamic _eosinophilsUnitId;

  dynamic _erythrocytes;
  dynamic _erythrocytesUnitId;

  dynamic _hemoglobin;
  dynamic _hemoglobinUnitId;

  dynamic _leukocytes;
  dynamic _leukocytesUnitId;

  dynamic _lymphocytes;
  dynamic _lymphocytesUnitId;

  dynamic _basophils;
  dynamic _basophilsUnitId;


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
      _creationDate = widget.thisData!.items.basophils.creationDate;

      _thrombocytes = widget.thisData!.items.thrombocytes.analysisPatientValue;
      _thrombocytesUnitId = widget.thisData!.items.thrombocytes.analysisPatientUnitId;

      _soe = widget.thisData!.items.soe.analysisPatientValue;
      _soeUnitId = widget.thisData!.items.soe.analysisPatientUnitId;

      _neutrophils = widget.thisData!.items.neutrophils.analysisPatientValue;
      _neutrophilsUnitId = widget.thisData!.items.neutrophils.analysisPatientUnitId;

      _monocytes = widget.thisData!.items.monocytes.analysisPatientValue;
      _monocytesUnitId = widget.thisData!.items.monocytes.analysisPatientUnitId;

      _eosinophils = widget.thisData!.items.eosinophils.analysisPatientValue;
      _eosinophilsUnitId = widget.thisData!.items.eosinophils.analysisPatientUnitId;

      _erythrocytes = widget.thisData!.items.erythrocytes.analysisPatientValue;
      _erythrocytesUnitId = widget.thisData!.items.erythrocytes.analysisPatientUnitId;

      _hemoglobin = widget.thisData!.items.hemoglobin.analysisPatientValue;
      _hemoglobinUnitId = widget.thisData!.items.hemoglobin.analysisPatientUnitId;

      _leukocytes = widget.thisData!.items.leukocytes.analysisPatientValue;
      _leukocytesUnitId = widget.thisData!.items.leukocytes.analysisPatientUnitId;

      _lymphocytes = widget.thisData!.items.lymphocytes.analysisPatientValue;
      _lymphocytesUnitId = widget.thisData!.items.lymphocytes.analysisPatientUnitId;

      _basophils = widget.thisData!.items.basophils.analysisPatientValue;
      _basophilsUnitId = widget.thisData!.items.basophils.analysisPatientUnitId;

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

    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    if (mounted) Navigator.pop(context);
  }


  Future<void> _request() async {
    DataTestsClinical thisData = DataTestsClinical(
      isCreate: !widget.isEditForm,
      date: convertToTimestamp(_date),
      patientId: _patientsId,
      items: Items(
        erythrocytes: ItemsChild(
            analysisPatientId: widget.thisData!.items.erythrocytes.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.erythrocytes.analysisPatientDate,
            analysisPatientValue: _erythrocytes,
            analysisPatientUnitId: _erythrocytesUnitId,
            analysisId: widget.thisData!.items.erythrocytes.analysisId,
            analysisName: widget.thisData!.items.erythrocytes.analysisName,
            analysisKeyName: widget.thisData!.items.erythrocytes.analysisKeyName,
            norma: _getNorma(_erythrocytes, _erythrocytesUnitId),
            minmax: _getMinMax(_erythrocytes, _erythrocytesUnitId),
            creationDate: _creationDate),
        thrombocytes: ItemsChild(
            analysisPatientId: widget.thisData!.items.thrombocytes.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.thrombocytes.analysisPatientDate,
            analysisPatientValue: _thrombocytes,
            analysisPatientUnitId: _thrombocytesUnitId,
            analysisId: widget.thisData!.items.thrombocytes.analysisId,
            analysisName: widget.thisData!.items.thrombocytes.analysisName,
            analysisKeyName: widget.thisData!.items.thrombocytes.analysisKeyName,
            norma: _getNorma(_thrombocytes, _thrombocytesUnitId),
            minmax: _getMinMax(_thrombocytes, _thrombocytesUnitId),
            creationDate: _creationDate),
        hemoglobin: ItemsChild(
            analysisPatientId: widget.thisData!.items.hemoglobin.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.hemoglobin.analysisPatientDate,
            analysisPatientValue: _hemoglobin,
            analysisPatientUnitId: _hemoglobinUnitId,
            analysisId: widget.thisData!.items.hemoglobin.analysisId,
            analysisName: widget.thisData!.items.hemoglobin.analysisName,
            analysisKeyName: widget.thisData!.items.hemoglobin.analysisKeyName,
            norma: _getNorma(_hemoglobin, _hemoglobinUnitId),
            minmax: _getMinMax(_hemoglobin, _hemoglobinUnitId),
            creationDate: _creationDate),
        soe: ItemsChild(
            analysisPatientId: widget.thisData!.items.soe.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.soe.analysisPatientDate,
            analysisPatientValue: _soe,
            analysisPatientUnitId: _soeUnitId,
            analysisId: widget.thisData!.items.soe.analysisId,
            analysisName: widget.thisData!.items.soe.analysisName,
            analysisKeyName: widget.thisData!.items.soe.analysisKeyName,
            norma:_getNorma(_soe, _soeUnitId),
            minmax: _getMinMax(_soe, _soeUnitId),
            creationDate: _creationDate),
        leukocytes: ItemsChild(
            analysisPatientId: widget.thisData!.items.leukocytes.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.leukocytes.analysisPatientDate,
            analysisPatientValue: _leukocytes,
            analysisPatientUnitId: _leukocytesUnitId,
            analysisId: widget.thisData!.items.leukocytes.analysisId,
            analysisName: widget.thisData!.items.leukocytes.analysisName,
            analysisKeyName: widget.thisData!.items.leukocytes.analysisKeyName,
            norma: _getNorma(_leukocytes, _leukocytesUnitId),
            minmax: _getMinMax(_leukocytes, _leukocytesUnitId),
            creationDate: _creationDate),
        neutrophils: ItemsChild(
            analysisPatientId: widget.thisData!.items.neutrophils.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.neutrophils.analysisPatientDate,
            analysisPatientValue: _neutrophils,
            analysisPatientUnitId: _neutrophilsUnitId,
            analysisId: widget.thisData!.items.neutrophils.analysisId,
            analysisName: widget.thisData!.items.neutrophils.analysisName,
            analysisKeyName: widget.thisData!.items.neutrophils.analysisKeyName,
            norma: _getNorma(_neutrophils, _neutrophilsUnitId),
            minmax: _getMinMax(_neutrophils, _neutrophilsUnitId),
            creationDate: _creationDate),
        lymphocytes: ItemsChild(
            analysisPatientId: widget.thisData!.items.lymphocytes.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.lymphocytes.analysisPatientDate,
            analysisPatientValue: _lymphocytes,
            analysisPatientUnitId: _lymphocytesUnitId,
            analysisId: widget.thisData!.items.lymphocytes.analysisId,
            analysisName: widget.thisData!.items.lymphocytes.analysisName,
            analysisKeyName: widget.thisData!.items.lymphocytes.analysisKeyName,
            norma: _getNorma(_lymphocytes, _lymphocytesUnitId),
            minmax: _getMinMax(_lymphocytes, _lymphocytesUnitId),
            creationDate: _creationDate),
        monocytes: ItemsChild(
            analysisPatientId: widget.thisData!.items.monocytes.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.monocytes.analysisPatientDate,
            analysisPatientValue: _monocytes,
            analysisPatientUnitId: _monocytesUnitId,
            analysisId: widget.thisData!.items.monocytes.analysisId,
            analysisName: widget.thisData!.items.monocytes.analysisName,
            analysisKeyName: widget.thisData!.items.monocytes.analysisKeyName,
            norma: _getNorma(_monocytes, _monocytesUnitId),
            minmax: _getMinMax(_monocytes, _monocytesUnitId),
            creationDate: _creationDate),
        basophils: ItemsChild(
            analysisPatientId: widget.thisData!.items.basophils.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.basophils.analysisPatientDate,
            analysisPatientValue: _basophils,
            analysisPatientUnitId: _basophilsUnitId,
            analysisId: widget.thisData!.items.basophils.analysisId,
            analysisName: widget.thisData!.items.basophils.analysisName,
            analysisKeyName: widget.thisData!.items.basophils.analysisKeyName,
            norma: _getNorma(_basophils, _basophilsUnitId),
            minmax: _getMinMax(_basophils, _basophilsUnitId),
            creationDate: _creationDate),
        eosinophils: ItemsChild(
            analysisPatientId: widget.thisData!.items.eosinophils.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.eosinophils.analysisPatientDate,
            analysisPatientValue: _eosinophils,
            analysisPatientUnitId: _eosinophilsUnitId,
            analysisId: widget.thisData!.items.eosinophils.analysisId,
            analysisName: widget.thisData!.items.eosinophils.analysisName,
            analysisKeyName: widget.thisData!.items.eosinophils.analysisKeyName,
            norma: _getNorma(_eosinophils, _eosinophilsUnitId),
            minmax: _getMinMax(_eosinophils, _eosinophilsUnitId),
            creationDate: _creationDate),
      ),
    );
    await _api.post(patientsId: _patientsId, thisData: thisData);
  }



  bool _areDifferent() {
    if (widget.isEditForm) {
      return (
          _date != convertTimestampToDateTime(widget.thisData!.date!) ||
              _thrombocytes != widget.thisData!.items.thrombocytes.analysisPatientValue ||
              _thrombocytesUnitId != widget.thisData!.items.thrombocytes.analysisPatientUnitId ||
              _soe != widget.thisData!.items.soe.analysisPatientValue ||
              _soeUnitId != widget.thisData!.items.soe.analysisPatientUnitId ||
              _neutrophils != widget.thisData!.items.neutrophils.analysisPatientValue ||
              _neutrophilsUnitId != widget.thisData!.items.neutrophils.analysisPatientUnitId ||
              _monocytes != widget.thisData!.items.monocytes.analysisPatientValue ||
              _monocytesUnitId != widget.thisData!.items.monocytes.analysisPatientUnitId ||
              _eosinophils != widget.thisData!.items.eosinophils.analysisPatientValue ||
              _eosinophilsUnitId != widget.thisData!.items.eosinophils.analysisPatientUnitId ||
              _erythrocytes != widget.thisData!.items.erythrocytes.analysisPatientValue ||
              _erythrocytesUnitId != widget.thisData!.items.erythrocytes.analysisPatientUnitId ||
              _hemoglobin != widget.thisData!.items.hemoglobin.analysisPatientValue ||
              _hemoglobinUnitId != widget.thisData!.items.hemoglobin.analysisPatientUnitId ||
              _leukocytes != widget.thisData!.items.leukocytes.analysisPatientValue ||
              _leukocytesUnitId != widget.thisData!.items.leukocytes.analysisPatientUnitId ||
              _lymphocytes != widget.thisData!.items.lymphocytes.analysisPatientValue ||
              _lymphocytesUnitId != widget.thisData!.items.lymphocytes.analysisPatientUnitId ||
              _basophils != widget.thisData!.items.basophils.analysisPatientValue ||
              _basophilsUnitId != widget.thisData!.items.basophils.analysisPatientUnitId
      );
    } else {
      return (
          _thrombocytes != null ||
              _soe != null ||
              _neutrophils != null ||
              _monocytes != null ||
              _eosinophils != null ||
              _erythrocytes != null ||
              _hemoglobin != null ||
              _leukocytes != null ||
              _lymphocytes != null ||
              _basophils != null
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
    return (_thrombocytes == null &&
        _soe == null &&
        _neutrophils == null &&
        _monocytes == null &&
        _eosinophils == null &&
        _erythrocytes == null &&
        _hemoglobin == null &&
        _leukocytes == null &&
        _lymphocytes == null &&
        _basophils == null) ? true
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
          InputSelectDateTime(
            labelText: 'Дата',
            fieldKey: _keys[Enum.date]!,
            value: _date,
            required: true,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _date = value;
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.thrombocytes.analysisName ?? 'Тромбоциты',
            fieldKey: _keys[Enum.thrombocytes]!,
            initialValue: _thrombocytes,
            unitOptions: _getUnitList(widget.thisData!.items.thrombocytes.analysisId),
            initialUnit: (_thrombocytesUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _thrombocytesUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.thrombocytes.analysisId, _thrombocytesUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.thrombocytes.analysisId, _thrombocytesUnitId),
            onChanged: (value) {
              setState(() {
                _thrombocytes = value.value;
                _thrombocytesUnitId = _getUnitId(widget.thisData!.items.thrombocytes.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.soe.analysisName ?? 'СОЭ',
            fieldKey: _keys[Enum.soe]!,
            initialValue: _soe,
            unitOptions: _getUnitList(widget.thisData!.items.soe.analysisId),
            initialUnit: (_soeUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _soeUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.soe.analysisId, _soeUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.soe.analysisId, _soeUnitId),
            onChanged: (value) {
              setState(() {
                _soe = value.value;
                _soeUnitId = _getUnitId(widget.thisData!.items.soe.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.neutrophils.analysisName ?? 'Нейтрофилы',
            fieldKey: _keys[Enum.neutrophils]!,
            initialValue: _neutrophils,
            unitOptions: _getUnitList(widget.thisData!.items.neutrophils.analysisId),
            initialUnit: (_neutrophilsUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _neutrophilsUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.neutrophils.analysisId, _neutrophilsUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.neutrophils.analysisId, _neutrophilsUnitId),
            onChanged: (value) {
              setState(() {
                _neutrophils = value.value;
                _neutrophilsUnitId = _getUnitId(widget.thisData!.items.neutrophils.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.monocytes.analysisName ?? 'Моноциты',
            fieldKey: _keys[Enum.monocytes]!,
            initialValue: _monocytes,
            unitOptions: _getUnitList(widget.thisData!.items.monocytes.analysisId),
            initialUnit: (_monocytesUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _monocytesUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.monocytes.analysisId, _monocytesUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.monocytes.analysisId, _monocytesUnitId),
            onChanged: (value) {
              setState(() {
                _monocytes = value.value;
                _monocytesUnitId = _getUnitId(widget.thisData!.items.monocytes.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.eosinophils.analysisName ?? 'Эозинофилы',
            fieldKey: _keys[Enum.eosinophils]!,
            initialValue: _eosinophils,
            unitOptions: _getUnitList(widget.thisData!.items.eosinophils.analysisId),
            initialUnit: (_eosinophilsUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _eosinophilsUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.eosinophils.analysisId, _eosinophilsUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.eosinophils.analysisId, _eosinophilsUnitId),
            onChanged: (value) {
              setState(() {
                _eosinophils = value.value;
                _eosinophilsUnitId = _getUnitId(widget.thisData!.items.eosinophils.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.erythrocytes.analysisName ?? 'Эритроциты',
            fieldKey: _keys[Enum.erythrocytes]!,
            initialValue: _erythrocytes,
            unitOptions: _getUnitList(widget.thisData!.items.erythrocytes.analysisId),
            initialUnit: (_erythrocytesUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _erythrocytesUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.erythrocytes.analysisId, _erythrocytesUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.erythrocytes.analysisId, _erythrocytesUnitId),
            onChanged: (value) {
              setState(() {
                _erythrocytes = value.value;
                _erythrocytesUnitId = _getUnitId(widget.thisData!.items.erythrocytes.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.hemoglobin.analysisName ?? 'Гемоглобин',
            fieldKey: _keys[Enum.hemoglobin]!,
            initialValue: _hemoglobin,
            unitOptions: _getUnitList(widget.thisData!.items.hemoglobin.analysisId),
            initialUnit: (_hemoglobinUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _hemoglobinUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.hemoglobin.analysisId, _hemoglobinUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.hemoglobin.analysisId, _hemoglobinUnitId),
            onChanged: (value) {
              setState(() {
                _hemoglobin = value.value;
                _hemoglobinUnitId = _getUnitId(widget.thisData!.items.hemoglobin.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.leukocytes.analysisName ?? 'Лейкоциты',
            fieldKey: _keys[Enum.leukocytes]!,
            initialValue: _leukocytes,
            unitOptions: _getUnitList(widget.thisData!.items.leukocytes.analysisId),
            initialUnit: (_leukocytesUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _leukocytesUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.leukocytes.analysisId, _leukocytesUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.leukocytes.analysisId, _leukocytesUnitId),
            onChanged: (value) {
              setState(() {
                _leukocytes = value.value;
                _leukocytesUnitId = _getUnitId(widget.thisData!.items.leukocytes.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.lymphocytes.analysisName ?? 'Лимфоциты',
            fieldKey: _keys[Enum.lymphocytes]!,
            initialValue: _lymphocytes,
            unitOptions: _getUnitList(widget.thisData!.items.lymphocytes.analysisId),
            initialUnit: (_lymphocytesUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _lymphocytesUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.lymphocytes.analysisId, _lymphocytesUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.lymphocytes.analysisId, _lymphocytesUnitId),
            onChanged: (value) {
              setState(() {
                _lymphocytes = value.value;
                _lymphocytesUnitId = _getUnitId(widget.thisData!.items.lymphocytes.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
          InputTextWithSelect(
            labelText: widget.thisData!.items.basophils.analysisName ?? 'Базофилы',
            fieldKey: _keys[Enum.basophils]!,
            initialValue: _basophils,
            unitOptions: _getUnitList(widget.thisData!.items.basophils.analysisId),
            initialUnit: (_basophilsUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _basophilsUnitId)?.unitName : null,
            required: _required,
            min: _getUnitMinValue(widget.thisData!.items.basophils.analysisId, _basophilsUnitId),
            max: _getUnitMaxValue(widget.thisData!.items.basophils.analysisId, _basophilsUnitId),
            onChanged: (value) {
              setState(() {
                _basophils = value.value;
                _basophilsUnitId = _getUnitId(widget.thisData!.items.basophils.analysisId, value.unit);
                _required = _getRequired();
                _formKey.currentState!.validate();
              });
            },
          ),
        ],
      );
    }
  }

