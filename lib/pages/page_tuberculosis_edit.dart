import 'package:artrit/api/api_spr.dart';
import 'package:artrit/widgets/input_multi_select.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_tuberculosis.dart';
import '../data/data_spr_drugs.dart';
import '../data/data_spr_side_effects.dart';
import '../data/data_tuberculosis.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/input_select_date.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';

class PageTuberculosisEdit extends StatefulWidget {
  final String title;
  final DataTuberculosis? thisData;
  final bool isEditForm;

  const PageTuberculosisEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTuberculosisEdit> createState() => PageTuberculosisEditState();
}

class PageTuberculosisEditState extends State<PageTuberculosisEdit> {
  late Future<void> _future;

  /// API
  final ApiTuberculosis _api = ApiTuberculosis();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprDrugs> _thisSprDataDrugs;
  late List<DataSprSideEffects> _thisSprDataSideEffects;
  List<String> _listSprDrugs = [];
  List<String> _listSprSideEffects = [];

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String? _treatmentBeginDate;
  String? _treatmentEndDate;
  List<String> _listDrugs = [];
  List<String> _listSideEffects = [];
  String? _customSideEffects;
  late DateTime? _createdOn = getMoscowDateTime();

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
      _createdOn = widget.thisData!.createdOn;
      _treatmentBeginDate = widget.thisData!.treatmentBeginDate != null
          ? dateFormat(widget.thisData!.treatmentBeginDate!)
          : null;
      _treatmentEndDate = widget.thisData!.treatmentEndDate != null
          ? dateFormat(widget.thisData!.treatmentEndDate!)
          : null;
      _listDrugs = widget.thisData!.drugs != null
          ? widget.thisData!.drugs!.map((e) => e.name ?? '').toList()
          : [];
      _listDrugs.sort();
      _listSideEffects = widget.thisData!.sideEffects != null
          ? widget.thisData!.sideEffects!.map((e) => e.name ?? '').toList()
          : [];
      _listSideEffects.sort();
      _customSideEffects = widget.thisData!.customSideEffects != null
          ? widget.thisData!.customSideEffects![0]
          : null;
    }

    _thisSprDataDrugs = await _apiSpr.getDrugs();
    _thisSprDataSideEffects = await _apiSpr.getSideEffects();

    _listSprDrugs = _thisSprDataDrugs
        .where((e) => e.isTuberculosisInfection ?? false)
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

    _listSprSideEffects = _thisSprDataSideEffects
        .map((e) => e.name)
        .toList()
      ..sort();
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
    DataTuberculosis thisData = DataTuberculosis(
        treatmentBeginDate: convertStrToDate(_treatmentBeginDate!),
        treatmentEndDate: convertStrToDate(_treatmentEndDate!),
        createdOn: _createdOn,
        drugIds: _getDrugIds(),
        sideEffectIds: _getSideEffectIds(),
        customSideEffects: _listSideEffects.contains('Другое') ? [_customSideEffects ?? ''] : ['']);

    widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }




  List<String> _getDrugIds() {
    List<String> drugIds = [];
    for (int i = 0; i < _listDrugs.length; i++) {
      drugIds.add(_thisSprDataDrugs
          .where((e) => e.name?.toLowerCase() == _listDrugs[i].toLowerCase())
          .map((e) => e.id)
          .first);
    }
    drugIds.sort();
    return drugIds;
  }

  List<String> _getSideEffectIds() {
    List<String> sideEffectIds = [];
    for (int i = 0; i < _listSideEffects.length; i++) {
      sideEffectIds.add(_thisSprDataSideEffects
          .where(
              (e) => e.name.toLowerCase() == _listSideEffects[i].toLowerCase())
          .map((e) => e.id)
          .first);
    }
    sideEffectIds.sort();
    return sideEffectIds;
  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _treatmentBeginDate != null ||
          _treatmentEndDate != null ||
          _listDrugs.isNotEmpty ||
          _listSideEffects.isNotEmpty ||
          _customSideEffects != null;
    }
    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return w.treatmentBeginDate != convertStrToDate(_treatmentBeginDate ?? '') ||
        w.treatmentEndDate != convertStrToDate(_treatmentEndDate ?? '') ||
        !listEquals(
            (w.drugs?.map((e) => e.id).toList() ?? [])..sort(),
            (_getDrugIds())..sort()) ||
        !listEquals(
            (w.sideEffects?.map((e) => e.id).toList() ?? [])..sort(),
            (_getSideEffectIds())..sort()) ||
        w.customSideEffects?[0] != _customSideEffects;
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
          labelText: 'Дата начала лечения',
          fieldKey: _keys[Enum.treatmentBeginDate]!,
          value: _treatmentBeginDate,
          initialDate: _treatmentBeginDate != null
              ? convertStrToDate(_treatmentBeginDate!)
              : _treatmentEndDate != null
                  ? convertStrToDate(_treatmentEndDate!)
                  : null,
          lastDate: _treatmentEndDate != null
              ? convertStrToDate(_treatmentEndDate!)
              : null,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _treatmentBeginDate = value;
            });
          },
        ),
        InputSelectDate(
          labelText: 'Дата завершения лечения',
          fieldKey: _keys[Enum.treatmentEndDate]!,
          value: _treatmentEndDate,
          firstDate: _treatmentBeginDate != null
              ? convertStrToDate(_treatmentBeginDate!)
              : null,
          lastDate: getMoscowDateTime().add(Duration(days: 365 * 18)),
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _treatmentEndDate = value;
            });
          },
        ),
        InputMultiSelect(
          labelText: 'Лекарственные препараты',
          fieldKey: _keys[Enum.drugs]!,
          listSelectValue: _listDrugs,
          required: true,
          listValues: _listSprDrugs,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _listDrugs = value;
            });
          },
        ),
        InputMultiSelect(
          labelText: 'Нежелательные явления',
          fieldKey: _keys[Enum.sideEffects]!,
          listSelectValue: _listSideEffects,
          required: false,
          listValues: _listSprSideEffects,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _listSideEffects = value;
            });
          },
        ),
        if (_listSideEffects.contains('Другое'))
          InputText(
            labelText: 'Другое',
            fieldKey: _keys[Enum.customSideEffects]!,
            value: _customSideEffects,
            maxLength: 200,
            required: _listSideEffects.contains('Другое') ? true : false,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _customSideEffects = value;
              });
            },
          ),
        if (_listSideEffects.contains('Другое')) SizedBox(height: 10),
      ],
    );
  }
}
