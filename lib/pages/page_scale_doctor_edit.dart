import 'package:artrit/api/api_scale_doctor.dart';
import 'package:artrit/data/data_scale_doctor.dart';
import 'package:artrit/widgets/input_select_date_time.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/animated_color_scale_widget.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';

class PageScaleDoctorEdit extends StatefulWidget {
  final String title;
  final DataScaleDoctor? thisData;
  final bool isEditForm;

  const PageScaleDoctorEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageScaleDoctorEdit> createState() => _PageScaleDoctorEditState();
}

class _PageScaleDoctorEditState extends State<PageScaleDoctorEdit> {
  late Future<void> _future;

  /// API
  final ApiScaleDoctor _api = ApiScaleDoctor();

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  String? _doctorId;
  late String _recordId;
  int? _creationDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  int _scale = 0;

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
    _doctorId = await readSecureData(SecureKey.doctorsId);

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id!;
      _scale = widget.thisData!.scale ?? 0;
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
    DataScaleDoctor thisData = DataScaleDoctor(
      creationDate: _creationDate,
      scaleDate: convertStrToDateTime(convertTimestampToDateTime(_creationDate)),
      scale: _scale,
      doctorId: _doctorId!,
      patientId: _patientsId
    );

    widget.isEditForm
        ? await _api.put(
            patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);
  }

  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _scale != 0;
    }

    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return _scale != w.scale;
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
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  FormHeaderWidget(title: widget.title),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputSelectDateTime(
                            labelText: 'Дата',
                            fieldKey: _keys[Enum.creationDate]!,
                            value: convertTimestampToDateTime(_creationDate),
                            required: false,
                            readOnly: true,
                            listRoles: Roles.asDoctor,
                            role: _role,
                            onChanged: (value) {},
                          ),
                          SizedBox(height: 50),
                          Text(
                            'Установите оценку',
                            style: labelStyle,
                          ),
                          AnimatedColorScaleWidget(
                            value: _scale.toDouble(),
                            labelStart: 'Хорошее',
                            labelEnd: 'Плохое',
                            listRoles: Roles.asDoctor,
                            role: _role,
                            onChanged: (value) {
                              setState(() {
                                _scale = value.toInt();
                              });
                            },
                          ),
                          SizedBox(height: 10),
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
}
