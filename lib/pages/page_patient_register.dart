import 'package:artrit/api/api_patient.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/data/data_patient_register.dart';
import 'package:artrit/data/data_spr_doctors.dart';
import 'package:artrit/data/data_spr_hospitals.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import '../data/data_diagnoses.dart';
import '../data/data_result.dart';
import '../data/data_spr_diagnoses.dart';
import '../data/data_spr_item.dart';
import '../data/data_spr_region.dart';
import '../data/data_spr_relationship.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/checkbox_group_widget.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/input_text.dart';
import '../theme.dart';
import '../widgets/show_message.dart';

class PagePatientRegister extends StatefulWidget {
  final String title;

  const PagePatientRegister({
    super.key,
    required this.title,
  });

  @override
  State<PagePatientRegister> createState() => PagePatientRegisterState();
}

class PagePatientRegisterState extends State<PagePatientRegister> {
  late Future<void> _future;

  /// API
  final ApiPatient _apiPatient = ApiPatient();
  final ApiSpr _apiSpr = ApiSpr();

  /// Данные
  late List<DataSprHospitals> _dataSprHospitals;
  late List<DataSprRegion> _dataSprRegion;
  late List<DataSprDoctors> _dataSprDoctors;
  late List<DataSprRelationship> _dataSprRelationship;
  late List<DataSprDiagnoses> _dataSprDiagnoses;

  /// Справочники
  List<SprItem> _listSprDoctors = [];
  final List<SprItem> _listSprUveitExists = [
    SprItem(id: '1', name: 'Отсутствует'),
    SprItem(id: '2', name: 'Присутствует')
  ];

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  String? _lastNamePatient;
  String? _firstNamePatient;
  String? _patronymicPatient;
  String? _birthDate;
  String? _gender;
  String? _regionId;
  bool? _uveit;
  String? _relationshipDegreeId;
  String? _lastNameParent;
  String? _firstNameParent;
  String? _patronymicParent;
  String? _email;
  String? _phone;
  String? _diagnosisId;
  String? _diagnosisComment;
  String? _hospitalId;
  String? _unknownHospital;
  String? _doctorId;
  String? _unknownDoctor;
  bool _canContainCookies = false;
  bool _agreeEmail = false;
  bool _agreeLk = false;

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<EnumRegPatient, GlobalKey<FormFieldState>> _keysPatient = {
    for (var e in EnumRegPatient.values) e: GlobalKey<FormFieldState>(),
  };
  final Map<EnumRegParent, GlobalKey<FormFieldState>> _keysParent = {
    for (var e in EnumRegParent.values) e: GlobalKey<FormFieldState>(),
  };
  final Map<EnumDiagnoses, GlobalKey<FormFieldState>> _keysDiagnoses = {
    for (var e in EnumDiagnoses.values) e: GlobalKey<FormFieldState>(),
  };

  final _checkboxGroupKey = GlobalKey<FormFieldState<List<bool>>>();

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _dataSprRegion = await _apiSpr.getRegions();
    _dataSprHospitals = await _apiSpr.getHospitals();
    _dataSprDoctors = await _apiSpr.getDoctors();
    _listSprDoctors = _dataSprDoctors
        .map((e) => SprItem(id: e.id, name: e.name ?? ''))
        .toList();
    _listSprDoctors.addAll([
      SprItem(id: '1', name: 'Другой'),
      SprItem(id: '2', name: 'Отсутствует'),
    ]);
    _dataSprRelationship = await _apiSpr.getRelationship();
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();
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

    DataResult1 result = await _request();

    setState(() {
      _isLoading = false;
    });

    if (result.message != null) {
      ShowMessage.show(context: context, message: result.message!);
    } else {
      if (mounted) {
        Navigator.pop(context);
        ShowMessage.show(
            context: context,
            message:
                'Вы успешно зарегистрированы в системе. Логин и пароль придут на почту, указанную при регистрации');
      }
    }
  }

  Future<DataResult1> _request() async {
    DataPatientRegister thisData = DataPatientRegister(
        firstName: _firstNamePatient,
        lastName: _lastNamePatient,
        patrynomic: _patronymicPatient,
        birthDate: convertStrToDate(_birthDate) ?? getMoscowDateTime(),
        regionId: _regionId,
        isMale: _gender == listGender[0].name ? 'true' : 'false',
        isFemale: _gender == listGender[1].name ? 'true' : 'false',
        diagnosisId: _diagnosisId,
        diagnosisComment: _diagnosisComment,
        uveit: _uveit ?? false,
        doctorId: _doctorId,
        unknownDoctor: _unknownDoctor,
        hospitalId: _hospitalId,
        unknownHospital: _unknownHospital,
        canContainCookies: _canContainCookies,
        relationshipDegreeId: _relationshipDegreeId,
        applicantFirstName: _firstNameParent,
        applicantLastName: _lastNameParent,
        applicantPatrynomic: _patronymicParent,
        applicantEmail: _email,
        applicantPhone: _phone,
        notificationReceiveType: getNotificationReceiveType(
            agreeEmail: _agreeEmail, agreeLk: _agreeLk));
    return await _apiPatient.postRegister(thisData: thisData);
  }

  bool _areDifferent() {
    return _lastNamePatient != null ||
        _firstNamePatient != null ||
        _patronymicPatient != null ||
        _birthDate != null ||
        _gender != null ||
        _regionId != null ||
        _uveit != null ||
        _relationshipDegreeId != null ||
        _lastNameParent != null ||
        _firstNameParent != null ||
        _patronymicParent != null ||
        _email != null ||
        _phone != null ||
        _diagnosisId != null ||
        _diagnosisComment != null ||
        _hospitalId != null ||
        _unknownHospital != null ||
        _doctorId != null ||
        _doctorId != null ||
        _unknownDoctor != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
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
                      //padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10.0),
                          buildPatientForm(),
                          SizedBox(height: 30.0),
                          buildParentForm(),
                          SizedBox(height: 30.0),
                          buildDiagnosesForm(),
                          SizedBox(height: 30.0),
                          buildDoctorForm(),
                          SizedBox(height: 30.0),
                          CheckboxGroupWidget(
                            labelText: 'Способ получения уведомлений',
                            listAnswers: ['E-mail', 'Личный кабинет'],
                            fieldKey: _checkboxGroupKey,
                            selectedIndexes: [_agreeEmail, _agreeLk],
                            required: true,
                            listRoles: Roles.all,
                            onChanged: (value) {
                              setState(() {
                                _agreeEmail = value[0];
                                _agreeLk = value[1];
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 2,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 20),
                          // InputCheckbox(
                          //   fieldKey: _keysPatient[EnumRegPatient.canContainCookies]!,
                          //   labelText: 'Согласие на обработку персональных данных',
                          //   requiredTrue: true,
                          //   value: _canContainCookies,
                          //   listRoles: Roles.all,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _canContainCookies = value;
                          //     });
                          //   },
                          // ),
                          Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: InputCheckbox(
                                  fieldKey: _keysPatient[
                                      EnumRegPatient.canContainCookies]!,
                                  labelText: '',
                                  requiredTrue: true,
                                  value: _canContainCookies,
                                  listRoles: Roles.all,
                                  onChanged: (value) {
                                    setState(() {
                                      _canContainCookies = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        'Я прочитал(а) и соглашаюсь с условиями ',
                                    style: listLabelStyle,
                                    children: [
                                      TextSpan(
                                        text: 'Политики конфиденциальности',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => openUrl(
                                              'https://ja.aspirre-russia.ru/static/PrivacyPolicy.docx'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: ButtonWidget(
                        labelText: 'Зарегистрироваться',
                        showProgressIndicator: _isLoading,
                        listRoles: Roles.all,
                        onPressed: () async {
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

  Widget buildPatientForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Информация о пациенте',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysPatient[EnumRegPatient.lastName]!,
          value: _lastNamePatient,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _lastNamePatient = value;
            });
          },
        ),
        InputText(
          labelText: 'Имя',
          fieldKey: _keysPatient[EnumRegPatient.firstName]!,
          value: _firstNamePatient,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _firstNamePatient = value;
            });
          },
        ),
        InputText(
          labelText: 'Отчество',
          fieldKey: _keysPatient[EnumRegPatient.patronymic]!,
          value: _patronymicPatient,
          required: false,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _patronymicPatient = value;
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата рождения',
          fieldKey: _keysPatient[EnumRegPatient.birthDate]!,
          value: _birthDate,
          lastDateTime: getMoscowDateTime(),
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _birthDate = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Пол',
          fieldKey: _keysPatient[EnumRegPatient.gender]!,
          allValues: listGender,
          selectedValue: (_gender == 'Мужчина')
              ? 'Мужской'
              : (_gender == 'Женщина')
                  ? 'Женский'
                  : _gender,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Регион',
          fieldKey: _keysPatient[EnumRegPatient.regionName]!,
          allValues: _dataSprRegion
              .map((e) => SprItem(id: e.id, name: e.name))
              .toList(),
          selectedValue: _regionId,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _regionId = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildParentForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Информация об опекуне',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        WidgetInputSelect(
          labelText: 'Степень родства',
          fieldKey: _keysParent[EnumRegParent.relationshipDegreeId]!,
          allValues: _dataSprRelationship
              .map((e) => SprItem(id: e.id, name: e.name ?? ''))
              .toList(),
          selectedValue: _relationshipDegreeId,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _relationshipDegreeId = value;
            });
          },
        ),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysParent[EnumRegParent.lastName]!,
          value: _lastNameParent,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _lastNameParent = value;
            });
          },
        ),
        InputText(
          labelText: 'Имя',
          fieldKey: _keysParent[EnumRegParent.firstName]!,
          value: _firstNameParent,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _firstNameParent = value;
            });
          },
        ),
        InputText(
          labelText: 'Отчество',
          fieldKey: _keysParent[EnumRegParent.patronymic]!,
          value: _patronymicParent,
          required: false,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _patronymicParent = value;
            });
          },
        ),
        InputText(
          labelText: 'E-mail',
          fieldKey: _keysParent[EnumRegParent.email]!,
          value: _email,
          required: true,
          keyboardType: TextInputType.emailAddress,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _email = value;
            });
          },
        ),
        InputText(
          labelText: 'Телефон',
          fieldKey: _keysParent[EnumRegParent.phone]!,
          value: _phone,
          required: true,
          keyboardType: TextInputType.phone,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _phone = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildDiagnosesForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Диагноз',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        WidgetInputSelect(
          labelText: 'Название',
          fieldKey: _keysDiagnoses[EnumDiagnoses.diagnosisId]!,
          allValues: _dataSprDiagnoses
              .map((e) => SprItem(
                  id: e.id,
                  name:
                      '${e.mkbCode.trim()} ${e.synonym.trim().replaceAll('\n', '')}'))
              .toList(),
          selectedValue: _diagnosisId,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _diagnosisId = value;
                });
              }
            });
          },
        ),
        if (_diagnosisId == '18ff07ab-5fb5-49b1-8fe4-b301968df8af' ||
            _diagnosisId == '13019398-b69c-4d4b-a58b-d3ed4f485ed0')
          InputText(
            labelText: 'Комментарий к диагнозу',
            fieldKey: _keysDiagnoses[EnumDiagnoses.diagnosisComment]!,
            value: _diagnosisComment,
            maxLength: 300,
            required: false,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _diagnosisComment = value;
              });
            },
          ),
        WidgetInputSelect(
          labelText: 'Увеит',
          fieldKey: _keysPatient[EnumRegPatient.uveit]!,
          allValues: _listSprUveitExists,
          selectedValue: _uveit == null || _uveit.toString().isEmpty
              ? ''
              : _uveit!
                  ? _listSprUveitExists[1].name
                  : _listSprUveitExists[0].name,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _uveit = (value == _listSprUveitExists[0].name)
                  ? false
                  : (value == _listSprUveitExists[1].name)
                      ? true
                      : null;
            });
          },
        ),
      ],
    );
  }

  Widget buildDoctorForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Данные о враче',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        WidgetInputSelect(
          labelText: 'Название учреждения',
          fieldKey: _keysPatient[EnumRegPatient.hospitalName]!,
          allValues: _dataSprHospitals
              .map((e) => SprItem(id: e.id, name: e.name ?? ''))
              .toList(),
          selectedValue: _hospitalId,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _hospitalId = value;
            });
          },
        ),
        if (_hospitalId == '2a1101a8-0df3-4ac1-9c9e-4e5c15e9b422') // Другое
          InputText(
            labelText: 'Название учреждения',
            fieldKey: _keysPatient[EnumRegPatient.unknownHospital]!,
            value: _unknownHospital,
            maxLength: 300,
            required: (_hospitalId == '2a1101a8-0df3-4ac1-9c9e-4e5c15e9b422')
                ? true
                : false,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _unknownHospital = value;
              });
            },
          ),
        WidgetInputSelect(
          labelText: 'Врач',
          fieldKey: _keysPatient[EnumRegPatient.doctorFio]!,
          allValues: _listSprDoctors,
          selectedValue: _doctorId,
          isSort: false,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _doctorId = value;
            });
          },
        ),
        if (_doctorId == '1')
          InputText(
            labelText: 'ФИО врача',
            fieldKey: _keysPatient[EnumRegPatient.unknownDoctor]!,
            value: _unknownDoctor,
            maxLength: 200,
            required: (_doctorId == '1') ? true : false,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _unknownDoctor = value;
              });
            },
          ),
        if (_doctorId == '1')
          Text(
            'Указанный Вами врач в системе не зарегистрирован. Вы будете пользоваться приложением в режиме самоконтроля',
            style: textStyleGreen,
          ),
        if (_doctorId == '1') SizedBox(height: 5),
      ],
    );
  }
}
