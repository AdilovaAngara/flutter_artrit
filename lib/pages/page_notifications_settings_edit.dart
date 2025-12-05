import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_notifications_settings.dart';
import '../api/api_patients.dart';
import '../api/api_spr.dart';
import '../data/data_notifications_settings.dart';
import '../data/data_patients.dart';
import '../data/data_spr_frequency.dart';
import '../data/data_spr_item.dart';
import '../data/data_spr_sections.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/widget_input_multi_select.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/input_switch.dart';
import '../widgets/input_text.dart';

class PageNotificationsSettingsEdit extends StatefulWidget {
  final String title;
  final DataNotificationsSettings? thisData;
  final bool isEditForm;
  final bool forPatient;

  const PageNotificationsSettingsEdit(
      {super.key,
      required this.title,
      required this.thisData,
      required this.isEditForm,
      required this.forPatient });

  @override
  State<PageNotificationsSettingsEdit> createState() =>
      _PageNotificationsSettingsEditState();
}

class _PageNotificationsSettingsEditState
    extends State<PageNotificationsSettingsEdit> {
  late Future<void> _future;

  /// API
  final ApiNotificationsSettings _api = ApiNotificationsSettings();
  final ApiPatients _apiPatients = ApiPatients();
  final ApiSpr _apiSpr = ApiSpr();

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _doctorsId;
  late String _patientsId;
  late String _recordId;
  String? _name;
  int? _frequencyId;
  String? _beginDate;
  String? _endDate;
  bool _isDisabled = false;
  List<int>? _listSectionIds;
  List<String>? _listPatientIds;

  /// Справочники
  late List<DataPatients> _thisDataPatients = [];
  late List<DataSprFrequency> _thisSprDataFrequency;
  late List<DataSprSections> _thisSprDataSections;

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
    _doctorsId = await readSecureData(SecureKey.doctorsId);
    _patientsId = await readSecureData(SecureKey.patientsId);

    _thisDataPatients = await _apiPatients.get(doctorsId: _doctorsId);
    _thisSprDataFrequency = await _apiSpr.getFrequency();
    _thisSprDataSections = await _apiSpr.getSections();

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id;
      _name = widget.thisData!.name ?? '';
      _frequencyId = widget.thisData!.frequencyId;
      _beginDate = dateFormat(widget.thisData!.beginDate!);
      _endDate = dateFormat(widget.thisData!.endDate!);
      _isDisabled = widget.thisData!.isDisabled;
      _listSectionIds = widget.thisData!.sectionIds ?? [];
      _listPatientIds = widget.thisData!.patientIds ?? [];
    } else {
      if (_patientsId.isNotEmpty && widget.forPatient) {
        _listPatientIds = [_patientsId];
      }
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
    DataNotificationsSettings thisData = DataNotificationsSettings(
        id: '',
        doctorId: '',
        name: _name,
        frequencyId: _frequencyId ?? 0,
        beginDate: convertStrToDate(_beginDate),
        endDate: convertStrToDate(_endDate),
        isDisabled: _isDisabled,
        sectionIds: _listSectionIds,
        patientIds: _listPatientIds);

    widget.isEditForm
        ? await _api.put(recordId: _recordId, thisData: thisData)
        : await _api.post(thisData: thisData);
  }

  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _name != null ||
          _frequencyId != null ||
          _beginDate != null ||
          _endDate != null ||
          _isDisabled == true ||
          _listSectionIds != null ||
          _listPatientIds != null;
    }
    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _name != w.name ||
        _thisSprDataFrequency
                .firstWhere((e) => e.id == widget.thisData!.frequencyId)
                .id !=
            w.frequencyId ||
        convertStrToDate(_beginDate) != w.beginDate ||
        convertStrToDate(_endDate) != w.endDate ||
        _isDisabled != w.isDisabled ||
        !listEquals((w.sectionIds?.map((e) => e).toList() ?? [])..sort(),
            _listSectionIds?..sort()) ||
        !listEquals((w.patientIds?.map((e) => e).toList() ?? [])..sort(),
            _listPatientIds?..sort());
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
                        listRoles: Roles.asDoctor,
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
          labelText: 'Название уведомления',
          fieldKey: _keys[Enum.name]!,
          value: _name,
          maxLength: 200,
          required: true,
          listRoles: Roles.asDoctor,
          role: _role,
          onChanged: (value) {
            setState(() {
              _name = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Периодичность',
          fieldKey: _keys[Enum.frequency]!,
          allValues: _thisSprDataFrequency.map((e) => SprItem(id: e.id.toString(), name: e.name)).toList(),
          selectedValue: _frequencyId?.toString(),
          required: true,
          listRoles: Roles.asDoctor,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              if (value != null) {
                _frequencyId = int.parse(value);
              } else {
                _frequencyId = null;
              }
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата начала срока действия',
          fieldKey: _keys[Enum.beginDate]!,
          value: _beginDate,
          firstDateTime: convertStrToDate(_beginDate) ?? getMoscowDateTime(),
          lastDateTime: convertStrToDate(_endDate) ?? getMoscowDateTime().add(Duration(days: 6000)),
          required: true,
          listRoles: Roles.asDoctor,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _beginDate = value;
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата окончания срока действия',
          fieldKey: _keys[Enum.endDate]!,
          value: _endDate,
          firstDateTime: convertStrToDate(_beginDate) ?? getMoscowDateTime(),
          lastDateTime: getMoscowDateTime().add(Duration(days: 6000)),
          required: true,
          listRoles: Roles.asDoctor,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _endDate = value;
            });
          },
        ),
        InputSwitch(
          labelText: 'Статус',
          fieldKey: _keys[Enum.isDisabled]!,
          value: !_isDisabled,
          trueLabelText: 'Активно',
          falseLabelText: 'Выключено',
          listRoles: Roles.asDoctor,
          role: _role,
          onChanged: (value) {
            setState(() {
              _isDisabled = !value;
            });
          },
        ),
        WidgetInputMultiSelect(
          labelText: 'Список разделов',
          fieldKey: _keys[Enum.sectionIds]!,
          allValues: _thisSprDataSections
              .map((e) => SprItem(id: e.id.toString(), name: e.name))
              .toList(),
          selectedValues: _listSectionIds?.map((e) => e.toString()).toList(),
          required: true,
          listRoles: Roles.asDoctor,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              if (value != null) {
                _listSectionIds = value.map((e) => int.parse(e)).toList();
              } else {
                _listSectionIds = [];
              }
            });
          },
        ),
        WidgetInputMultiSelect(
          labelText: 'Список пациентов',
          fieldKey: _keys[Enum.patientIds]!,
          allValues: _thisDataPatients
              .map((e) => SprItem(
                  id: e.id,
                  name: '${e.lastName} ${e.firstName} ${e.patronymic ?? ''}'))
              .toList(),
          selectedValues: _listPatientIds,
          required: true,
          cleanAvailable: true,
          listRoles: Roles.asDoctor,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _listPatientIds = value ?? [];
            });
          },
        ),
      ],
    );
  }
}
