import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_tests_immunology.dart';
import '../data/data_tests_immunology.dart';
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

class PageTestsImmunologyEdit extends StatefulWidget {
  final String title;
  final DataTestsImmunology? thisData;
  final bool isEditForm;

  const PageTestsImmunologyEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTestsImmunologyEdit> createState() => _PageTestsImmunologyEditState();
}

class _PageTestsImmunologyEditState extends State<PageTestsImmunologyEdit> {
  late Future<void> _future;
  /// API
  final ApiTestsImmunology _api = ApiTestsImmunology();
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

  dynamic _cReactiveProtein;
  dynamic _cReactiveProteinUnitId;

  dynamic _antinuclearFactor;
  dynamic _antinuclearFactorUnitId;

  dynamic _rheumatoidFactor;
  dynamic _rheumatoidFactorUnitId;

  dynamic _antiCcp;
  dynamic _antiCcpUnitId;


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
      _creationDate = widget.thisData!.items.cReactiveProtein.creationDate;

      _cReactiveProtein= widget.thisData!.items.cReactiveProtein.analysisPatientValue;
      _cReactiveProteinUnitId = widget.thisData!.items.cReactiveProtein.analysisPatientUnitId;

      _antinuclearFactor= widget.thisData!.items.antinuclearFactor.analysisPatientValue;
      _antinuclearFactorUnitId = widget.thisData!.items.antinuclearFactor.analysisPatientUnitId;

      _rheumatoidFactor= widget.thisData!.items.rheumatoidFactor.analysisPatientValue;
      _rheumatoidFactorUnitId = widget.thisData!.items.rheumatoidFactor.analysisPatientUnitId;

      _antiCcp= widget.thisData!.items.antiCcp.analysisPatientValue;
      _antiCcpUnitId = widget.thisData!.items.antiCcp.analysisPatientUnitId;

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
    DataTestsImmunology thisData = DataTestsImmunology(
      isCreate: !widget.isEditForm,
      date: convertToTimestamp(_date),
      patientId: _patientsId,
      items: Items(
        cReactiveProtein: ItemsChild(
            analysisPatientId: widget.thisData!.items.cReactiveProtein.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.cReactiveProtein.analysisPatientDate,
            analysisPatientValue: _cReactiveProtein,
            analysisPatientUnitId: _cReactiveProteinUnitId,
            analysisId: widget.thisData!.items.cReactiveProtein.analysisId,
            analysisName: widget.thisData!.items.cReactiveProtein.analysisName,
            analysisKeyName: widget.thisData!.items.cReactiveProtein.analysisKeyName,
            norma: _getNorma(_cReactiveProtein, _cReactiveProteinUnitId),
            minmax: _getMinMax(_cReactiveProtein, _cReactiveProteinUnitId),
            creationDate: _creationDate),
        antinuclearFactor: ItemsChild(
            analysisPatientId: widget.thisData!.items.antinuclearFactor.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.antinuclearFactor.analysisPatientDate,
            analysisPatientValue: _antinuclearFactor,
            analysisPatientUnitId: _antinuclearFactorUnitId,
            analysisId: widget.thisData!.items.antinuclearFactor.analysisId,
            analysisName: widget.thisData!.items.antinuclearFactor.analysisName,
            analysisKeyName: widget.thisData!.items.antinuclearFactor.analysisKeyName,
            norma: _getNorma(_antinuclearFactor, _antinuclearFactorUnitId),
            minmax: _getMinMax(_antinuclearFactor, _antinuclearFactorUnitId),
            creationDate: _creationDate),
        rheumatoidFactor: ItemsChild(
            analysisPatientId: widget.thisData!.items.rheumatoidFactor.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.rheumatoidFactor.analysisPatientDate,
            analysisPatientValue: _rheumatoidFactor,
            analysisPatientUnitId: _rheumatoidFactorUnitId,
            analysisId: widget.thisData!.items.rheumatoidFactor.analysisId,
            analysisName: widget.thisData!.items.rheumatoidFactor.analysisName,
            analysisKeyName: widget.thisData!.items.rheumatoidFactor.analysisKeyName,
            norma: _getNorma(_rheumatoidFactor, _rheumatoidFactorUnitId),
            minmax: _getMinMax(_rheumatoidFactor, _rheumatoidFactorUnitId),
            creationDate: _creationDate),
        antiCcp: ItemsChild(
            analysisPatientId: widget.thisData!.items.antiCcp.analysisPatientId,
            analysisPatientDate: widget.thisData!.items.antiCcp.analysisPatientDate,
            analysisPatientValue: _antiCcp,
            analysisPatientUnitId: _antiCcpUnitId,
            analysisId: widget.thisData!.items.antiCcp.analysisId,
            analysisName: widget.thisData!.items.antiCcp.analysisName,
            analysisKeyName: widget.thisData!.items.antiCcp.analysisKeyName,
            norma: _getNorma(_antiCcp, _antiCcpUnitId),
            minmax: _getMinMax(_antiCcp, _antiCcpUnitId),
            creationDate: _creationDate),

      ),
    );
    await _api.post(patientsId: _patientsId, thisData: thisData);
  }


  bool _areDifferent() {
    if (widget.isEditForm) {
      return (
          _date != convertTimestampToDateTime(widget.thisData!.date!) ||
              _cReactiveProtein != widget.thisData!.items.cReactiveProtein.analysisPatientValue ||
              _cReactiveProteinUnitId != widget.thisData!.items.cReactiveProtein.analysisPatientUnitId ||
              _antinuclearFactor != widget.thisData!.items.antinuclearFactor.analysisPatientValue ||
              _antinuclearFactorUnitId != widget.thisData!.items.antinuclearFactor.analysisPatientUnitId ||
              _rheumatoidFactor != widget.thisData!.items.rheumatoidFactor.analysisPatientValue ||
              _rheumatoidFactorUnitId != widget.thisData!.items.rheumatoidFactor.analysisPatientUnitId ||
              _antiCcp != widget.thisData!.items.antiCcp.analysisPatientValue ||
              _antiCcpUnitId != widget.thisData!.items.antiCcp.analysisPatientUnitId
      );
    } else {
      return (
          _cReactiveProtein != null ||
              _antinuclearFactor != null ||
              _rheumatoidFactor != null ||
              _antiCcp != null
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
    return (_cReactiveProtein == null &&
        _antinuclearFactor == null &&
        _rheumatoidFactor == null &&
        _antiCcp == null) ? true
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
          labelText: widget.thisData!.items.cReactiveProtein.analysisName ?? 'С-реактивный белок',
          fieldKey: _keys[Enum.cReactiveProtein]!,
          initialValue: _cReactiveProtein,
          unitOptions: _getUnitList(widget.thisData!.items.cReactiveProtein.analysisId),
          initialUnit: (_cReactiveProteinUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _cReactiveProteinUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.cReactiveProtein.analysisId, _cReactiveProteinUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.cReactiveProtein.analysisId, _cReactiveProteinUnitId),
          onChanged: (value) {
            setState(() {
              _cReactiveProtein = value.value;
              _cReactiveProteinUnitId = _getUnitId(widget.thisData!.items.cReactiveProtein.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.antinuclearFactor.analysisName ?? 'Антинуклеарный фактор, 1',
          fieldKey: _keys[Enum.antinuclearFactor]!,
          initialValue: _antinuclearFactor,
          unitOptions: _getUnitList(widget.thisData!.items.antinuclearFactor.analysisId),
          initialUnit: (_antinuclearFactorUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _antinuclearFactorUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.antinuclearFactor.analysisId, _antinuclearFactorUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.antinuclearFactor.analysisId, _antinuclearFactorUnitId),
          onChanged: (value) {
            setState(() {
              _antinuclearFactor = value.value;
              _antinuclearFactorUnitId = _getUnitId(widget.thisData!.items.antinuclearFactor.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.rheumatoidFactor.analysisName ?? 'Ревматоидный фактор',
          fieldKey: _keys[Enum.rheumatoidFactor]!,
          initialValue: _rheumatoidFactor,
          unitOptions: _getUnitList(widget.thisData!.items.rheumatoidFactor.analysisId),
          initialUnit: (_rheumatoidFactorUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _rheumatoidFactorUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.rheumatoidFactor.analysisId, _rheumatoidFactorUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.rheumatoidFactor.analysisId, _rheumatoidFactorUnitId),
          onChanged: (value) {
            setState(() {
              _rheumatoidFactor = value.value;
              _rheumatoidFactorUnitId = _getUnitId(widget.thisData!.items.rheumatoidFactor.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
        InputTextWithSelect(
          labelText: widget.thisData!.items.antiCcp.analysisName ?? 'Антитела к циклическому цитруллинированному пептиду',
          fieldKey: _keys[Enum.antiCcp]!,
          initialValue: _antiCcp,
          unitOptions: _getUnitList(widget.thisData!.items.antiCcp.analysisId),
          initialUnit: (_antiCcpUnitId != null) ? _dataSprTestsOptions.firstWhereOrNull((e) => e.unitId == _antiCcpUnitId)?.unitName : null,
          required: _required,
          min: _getUnitMinValue(widget.thisData!.items.antiCcp.analysisId, _antiCcpUnitId),
          max: _getUnitMaxValue(widget.thisData!.items.antiCcp.analysisId, _antiCcpUnitId),
          onChanged: (value) {
            setState(() {
              _antiCcp = value.value;
              _antiCcpUnitId = _getUnitId(widget.thisData!.items.antiCcp.analysisId, value.unit);
              _required = _getRequired();
              _formKey.currentState!.validate();
            });
          },
        ),
      ],
    );
  }
}

