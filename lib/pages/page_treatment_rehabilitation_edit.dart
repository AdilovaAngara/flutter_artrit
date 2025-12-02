import 'package:artrit/data/data_treatment_rehabilitations.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_treatment_rehabilitations.dart';
import '../data/data_spr_treatment_rehabilitations_types.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/input_text.dart';

class PageTreatmentRehabilitationEdit extends StatefulWidget {
  final String title;
  final DataTreatmentRehabilitations? thisData;
  final bool isEditForm;

  const PageTreatmentRehabilitationEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTreatmentRehabilitationEdit> createState() => _PageTreatmentRehabilitationEditState();
}

class _PageTreatmentRehabilitationEditState extends State<PageTreatmentRehabilitationEdit> {
  late Future<void> _future;
  /// API
  final ApiTreatmentRehabilitations _api = ApiTreatmentRehabilitations();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprTreatmentRehabilitationsTypes> _thisSprDataRehabilitationsTypes;
  List<String> _listSprRehabilitationsTypes= [];

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  int? _creationDate = convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _dateStart;
  String? _dateEnd;
  bool? _toThisTime;
  String? _type;
  String? _fizcomment;


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
    _thisSprDataRehabilitationsTypes = await _apiSpr.getTreatmentRehabilitationsTypes();
    _listSprRehabilitationsTypes = _thisSprDataRehabilitationsTypes
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id!;
      _dateStart= widget.thisData!.dateStart != null ? convertTimestampToDate(widget.thisData!.dateStart!) : null;
      _dateEnd = widget.thisData!.dateEnd != null && widget.thisData!.dateEnd!.date != null && widget.thisData!.dateEnd!.date.toString().isNotEmpty ? convertTimestampToDate(widget.thisData!.dateEnd!.date!) : null;
      _toThisTime = widget.thisData!.dateEnd != null && widget.thisData!.dateEnd!.checkbox != null ? widget.thisData!.dateEnd!.checkbox : null;
      _type = widget.thisData!.typeRehabil != null ? widget.thisData!.typeRehabil!.type ?? '' : '';
      _fizcomment = widget.thisData!.typeRehabil != null ? widget.thisData!.typeRehabil!.fizcomment ?? '' : '';
      _creationDate = widget.thisData!.creationDate!;
    }
    setState(() {});
  }


  void _changeData() async {
    if (!_formKey.currentState!.validate()) {
      showTopBanner(context: context);
      return;
    }

    if (_type != 'Физиотерапия') _fizcomment = null;

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
    DataTreatmentRehabilitations thisData = DataTreatmentRehabilitations(
        dateStart: convertToTimestamp(_dateStart!),
        typeRehabil: TypeRehabil(type: _type, fizcomment: _fizcomment),
        creationDate: _creationDate,
        dateEnd: DateEnd(date: _dateEnd != null ? convertToTimestamp(_dateEnd!) : null, checkbox: _toThisTime)
    );

    widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _dateStart != null ||
          _dateEnd != null ||
          _toThisTime != null ||
          _type != null ||
          _fizcomment != null;
    }
    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _dateStart != convertTimestampToDate(w.dateStart) ||
        _dateEnd != (w.dateEnd?.date != null ? convertTimestampToDate(w.dateEnd!.date!) : null) ||
        _toThisTime != w.dateEnd?.checkbox ||
        _type != w.typeRehabil?.type ||
        _fizcomment != w.typeRehabil?.fizcomment ;
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
          labelText: 'Вид реабилитации',
          fieldKey: _keys[Enum.type]!,
          value: _type,
          required: true,
          listValues: _listSprRehabilitationsTypes,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _type = value;
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата начала',
          fieldKey: _keys[Enum.dateStart]!,
          value: _dateStart,
          initialDate: _dateStart != null
              ? convertStrToDate(_dateStart!)
              : _dateEnd != null
              ? convertStrToDate(_dateEnd!)
              : null,
          lastDateTime: _dateEnd != null
              ? convertStrToDate(_dateEnd!)
              : null,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _dateStart = value;
            });
          },
        ),
        if (_toThisTime == null || !_toThisTime!)
          WidgetInputSelectDateTime(
            labelText: 'Дата окончания',
            fieldKey: _keys[Enum.dateEnd]!,
            value: _dateEnd,
            firstDateTime: _dateStart != null
                ? convertStrToDate(_dateStart!)
                : null,
            required: true,
            listRoles: Roles.asPatient,
            roleId: _role,
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
        if (_type == 'Физиотерапия')
        InputText(
          labelText: 'Уточните название процедуры',
          fieldKey: _keys[Enum.fizcomment]!,
          value: _fizcomment,
          maxLength: 200,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _fizcomment = value;
            });
          },
        ),
      ],
    );
  }

}
