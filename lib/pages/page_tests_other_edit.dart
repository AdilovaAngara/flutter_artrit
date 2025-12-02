import 'package:artrit/api/api_tests_other.dart';
import 'package:artrit/data/data_spr_item.dart';
import 'package:artrit/data/data_tests_other.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../data/data_tests_options.dart';
import '../data/data_spr_other_tests_names.dart';
import '../data/data_spr_other_tests_units.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/input_text_with_select.dart';
import '../widgets/widget_input_select_date_time.dart';

class PageTestsOtherEdit extends StatefulWidget {
  final String title;
  final DataTestsOther? thisData;
  final bool isEditForm;

  const PageTestsOtherEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTestsOtherEdit> createState() => _PageTestsOtherEditState();
}

class _PageTestsOtherEditState extends State<PageTestsOtherEdit> {
  late Future<void> _future;
  /// API
  final ApiTestsOther _api = ApiTestsOther();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataTestsOptions> _dataSprTestsOptions;
  late List<DataSprOtherTestsNames> _dataSprNamesForOtherTest;
  late List<DataSprOtherTestsUnits> _dataSprUnitsForOtherTest;

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String? _date = dateTimeFormat(getMoscowDateTime());
  int? _creationDate = convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  late int _fullAge;
  String? _analys;
  dynamic _znachNum;
  String? _znachSel = '';
  String? _unitId;
  String? _parametersId;
  List<String> _listUnits = [];

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
    _dataSprNamesForOtherTest = await _apiSpr.getNamesForOtherTest();

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id!;
      _date = convertTimestampToDateTime(widget.thisData!.date);
      _creationDate = widget.thisData!.creationDate!;
      _analys = widget.thisData!.analys;
      _znachNum = widget.thisData!.znach.num;
      _znachSel = widget.thisData!.znach.sel;
      _parametersId = widget.thisData!.parametersId;
      _unitId = widget.thisData!.unitsId;
      await _getUnitList(_parametersId);
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
    DataTestsOther thisData = DataTestsOther(
      date: convertToTimestamp(_date),
      analys: _analys,
      znach: Znach(num: _znachNum, sel: _znachSel!),
      unitsId: _unitId!,
      parametersId: _parametersId!,
      creationDate: _creationDate,
    );

    widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }



  String? _getAnalysisName(String? parametersId) {
    if (parametersId == null || parametersId.isEmpty) return null;
    try {
      return _dataSprNamesForOtherTest.firstWhereOrNull((e) => e.id == parametersId)?.name;
    } catch (e) {
      return null;
    }
  }



  Future<void> _getUnitList(String? parametersId) async {
    if (parametersId == null || parametersId.isEmpty) {
      _listUnits = ['Нет данных'];
    } else {
      _dataSprUnitsForOtherTest = await _apiSpr.getUnitForOtherTest(recordId: parametersId);
      final listUnits = _dataSprUnitsForOtherTest.map((e) => e.name)
          .toSet() // Удаляем дубликаты
          .toList()..sort();
      listUnits.isNotEmpty ? _listUnits = listUnits : _listUnits = ['Нет данных'];
    }
    _znachSel = _listUnits[0];
    setState(() {
    });
  }



  String? _getUnitId(String? unitName) {
    if (unitName == null || unitName.isEmpty) return null;
    try {
      return _dataSprUnitsForOtherTest.firstWhereOrNull((e) => e.name == unitName)?.id;
    } catch (e) {
      return null;
    }
  }


  double? _getUnitMinValue(String? analysisId, String? unitId) {
    if (unitId == null || analysisId == null) return null;
    final listUnits = _dataSprTestsOptions
        .where((e) => e.analysisId == analysisId && e.unitId == unitId)
        .map((e) => e.minValue)
        .toList();
    return listUnits.isNotEmpty ? listUnits.first : null;
  }

  double? _getUnitMaxValue(String? analysisId, String? unitId) {
    if (unitId == null || analysisId == null) return null;
    final listUnits = _dataSprTestsOptions
        .where((e) => e.analysisId == analysisId && e.unitId == unitId)
        .map((e) => e.maxValue)
        .toList();
    return listUnits.isNotEmpty ? listUnits.first : null;
  }




  bool _areDifferent() {
    if (widget.isEditForm) {
      return (
          _date != convertTimestampToDateTime(widget.thisData!.date) ||
              _analys != widget.thisData!.analys ||
              _znachNum != widget.thisData!.znach.num ||
              _znachSel != widget.thisData!.znach.sel ||
              _unitId != widget.thisData!.unitsId
      );
    } else {
      return (
          _analys != null ||
              _znachNum != null ||
              _znachSel!.isNotEmpty ||
              _unitId != null
      );
    }
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
        WidgetInputSelect(
          labelText: 'Название анализа',
          fieldKey: _keys[Enum.analys]!,
          allValues: _dataSprNamesForOtherTest.map((e) => SprItem(id: e.id, name: e.name)).toList(),
          selectedValue: _parametersId,
          required: true,
          cleanAvailable: false,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _parametersId = value;
              _analys = _getAnalysisName(_parametersId);
              _getUnitList(_parametersId);
              _unitId = null; // Сбрасываем ID единицы
            });
          },
        ),
        InputTextWithSelect(
          labelText: 'Значение',
          fieldKey: _keys[Enum.znachNum]!,
          initialValue: _znachNum,
          unitOptions: _listUnits,
          initialUnit: (_znachSel != null) ? _znachSel : null,
          required: true,
          min: _getUnitMinValue(_parametersId, _unitId),
          max: _getUnitMaxValue(_parametersId, _unitId),
          errorText: 'Заполните поле',
          onChanged: (value) {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _znachNum = value.value;
                    _znachSel = value.unit;
                    _unitId = _getUnitId(value.unit);
                  });
                }
              });
            }
          },
        ),
      ],
    );
  }
}