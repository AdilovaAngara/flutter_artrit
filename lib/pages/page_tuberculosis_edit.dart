import 'package:artrit/api/api_spr.dart';
import 'package:artrit/widgets/input_multi_select.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_tuberculosis.dart';
import '../data/data_spr_drugs.dart';
import '../data/data_spr_item.dart';
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

  /// Справочники
  late List<DataSprDrugs> _thisSprDataDrugs;
  late List<DataSprSideEffects> _thisSprDataSideEffects;

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  String _recordId = '';
  String? _treatmentBeginDate;
  String? _treatmentEndDate;
  List<String> _listDrugs = [];
  List<String> _listSideEffects = [];
  String? _customSideEffects;
  late DateTime? _createdOn = getMoscowDateTime();
  final String _otherSideEffectId = '5635270d-c19d-4fa3-8131-c2f9d6742036'; // Другое

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
      _recordId = widget.thisData!.id;
      _createdOn = widget.thisData!.createdOn;
      _treatmentBeginDate = dateFormat(widget.thisData!.treatmentBeginDate);
      _treatmentEndDate = dateFormat(widget.thisData!.treatmentEndDate);
      _listDrugs = widget.thisData!.drugs != null ? widget.thisData!.drugs!.map((e) => e.id).toList() : [];
      _listSideEffects = widget.thisData!.sideEffects != null ? widget.thisData!.sideEffects!.map((e) => e.id).toList() : [];
      _customSideEffects = widget.thisData!.customSideEffects[0];
    }

    _thisSprDataDrugs = await _apiSpr.getDrugs();
    _thisSprDataSideEffects = await _apiSpr.getSideEffects();
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
      id: _recordId,
      patientId: _patientsId,
        treatmentBeginDate: convertStrToDate(_treatmentBeginDate),
        treatmentEndDate: convertStrToDate(_treatmentEndDate),
        createdOn: _createdOn,
        drugIds: _listDrugs,
        sideEffectIds: _listSideEffects,
        customSideEffects: _listSideEffects.contains(_otherSideEffectId) ? [_customSideEffects ?? ''] : [''], ); // Другое

    widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
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
    return w.treatmentBeginDate != convertStrToDate(_treatmentBeginDate) ||
        w.treatmentEndDate != convertStrToDate(_treatmentEndDate) ||
        !listEquals(w.drugs!.map((e) => e.id).toList()..sort(), _listDrugs..sort(),) ||
        !listEquals(w.sideEffects!.map((e) => e.id).toList()..sort(), _listSideEffects..sort(),) ||
        w.customSideEffects[0] != _customSideEffects;
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
              ? convertStrToDate(_treatmentBeginDate)
              : convertStrToDate(_treatmentEndDate),
          lastDate: convertStrToDate(_treatmentEndDate),
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
          firstDate: convertStrToDate(_treatmentBeginDate),
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
          allValues: _thisSprDataDrugs.map((e) => SprItem(id: e.id.toString(), name: e.name ?? ''))
              .toList(),
          selectedValues: _listDrugs,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _listDrugs = value ?? [];
            });
          },
        ),
        InputMultiSelect(
          labelText: 'Нежелательные явления',
          fieldKey: _keys[Enum.sideEffects]!,
          allValues: _thisSprDataSideEffects.map((e) => SprItem(id: e.id.toString(), name: e.name))
              .toList(),
          selectedValues: _listSideEffects,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _listSideEffects = value ?? [];
            });
          },
        ),

        if (_listSideEffects.contains(_otherSideEffectId))
          InputText(
            labelText: 'Другое',
            fieldKey: _keys[Enum.customSideEffects]!,
            value: _customSideEffects,
            maxLength: 200,
            required: _listSideEffects.contains(_otherSideEffectId) ? true : false,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: (value) {
              setState(() {
                _customSideEffects = value;
              });
            },
          ),
        if (_listSideEffects.contains(_otherSideEffectId)) SizedBox(height: 10),
      ],
    );
  }
}
