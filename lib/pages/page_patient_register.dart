import 'package:artrit/api/api_patient.dart';
import 'package:artrit/api/api_patient_diagnoses.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/data/data_patient_register.dart';
import 'package:artrit/data/data_spr_doctors.dart';
import 'package:artrit/data/data_spr_hospitals.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import '../data/data_result.dart';
import '../data/data_spr_diagnoses.dart';
import '../data/data_spr_region.dart';
import '../data/data_spr_relationship.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/checkbox_group_widget.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_select.dart';
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

  // Справочники
  final List<String> _listGender = ['Мужской', 'Женский'];
  final List<String> _listSprUveitExists = ['Отсутствует', 'Присутствует'];
  List<String> _listSprRegion = [];
  final List<String> _listSprDoctors = ['Другой', 'Отсутствует'];
  List<String> _listSprHospitals = [];
  List<String> _listSprRelationship = [];
  List<String> _listSprDiagnoses = [];

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  String? _lastNamePatient;
  String? _firstNamePatient;
  String? _patronymicPatient;
  String? _birthDate;
  String? _gender;
  String? _regionName;
  bool? _uveit;
  String? _whoYouAreToThePatient;
  String? _lastNameParent;
  String? _firstNameParent;
  String? _patronymicParent;
  String? _email;
  String? _phone;
  String? _mkbName;
  String? _mkbCode;
  String? _diagnosisComment;
  String? _hospitalName;
  String? _unknownHospital;
  String? _doctorFio;
  String? _doctorId;
  String? _unknownDoctor;
  bool _canContainCookies = false;
  bool _agreeEmail = false;
  bool _agreeLk = false;
  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<EnumPatient, GlobalKey<FormFieldState>> _keysPatient = {
    for (var e in EnumPatient.values) e: GlobalKey<FormFieldState>(),
  };
  final Map<EnumParent, GlobalKey<FormFieldState>> _keysParent = {
    for (var e in EnumParent.values) e: GlobalKey<FormFieldState>(),
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
    _dataSprRelationship = await _apiSpr.getRelationship();
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();
    _listSprRegion = _dataSprRegion.map((e) => e.name).toList()..sort();
    _listSprHospitals = _dataSprHospitals.map((e) => e.name ?? '').toList()..sort();
    _listSprDoctors.addAll(_dataSprDoctors.map((e) => e.name ?? '').toList()..sort());
    _listSprRelationship = _dataSprRelationship.map((e) => e.name ?? '').toList()..sort();
    _listSprDiagnoses = _dataSprDiagnoses.map((e) => '${e.mkbCode} ${e.synonym.replaceAll('\n', '')}').toList()..sort();
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

    if (result.message != null)
    {
      ShowMessage.show(context: context, message: result.message!);
    }
    else {
      if (mounted) {
        Navigator.pop(context);
        ShowMessage.show(context: context, message: 'Вы успешно зарегистрированы в системе. Логин и пароль придут на почту, указанную при регистрации');
      }
    }
  }






    Future<DataResult1> _request() async {
      DataPatientRegister thisData = DataPatientRegister(
          firstName: _firstNamePatient,
          lastName: _lastNamePatient,
          patrynomic: _patronymicPatient,
          birthDate: convertStrToDate(_birthDate) ?? getMoscowDateTime(),
          regionId: _dataSprRegion.firstWhereOrNull((region) => region.name == _regionName)?.id ?? '',
          isMale: _gender == _listGender[0] ? 'true' : 'false',
          isFemale: _gender == _listGender[1] ? 'true' : 'false',
          diagnosisId: _dataSprDiagnoses.firstWhereOrNull((e) => '${e.mkbCode} ${e.synonym.replaceAll('\n', '')}' == _mkbName)?.id ?? '',
          diagnosisComment: _diagnosisComment,
          uveit: _uveit ?? false,
          doctorId: _doctorId,
          unknownDoctor: _unknownDoctor,
          hospitalId: _dataSprHospitals.firstWhereOrNull((e) => e.name == _hospitalName)?.id ?? '',
          unknownHospital: _unknownHospital,
          canContainCookies: _canContainCookies,
          relationshipDegreeId: _dataSprRelationship.firstWhereOrNull((e) => e.name == _whoYouAreToThePatient)?.id ?? '',
          applicantFirstName: _firstNameParent,
          applicantLastName: _lastNameParent,
          applicantPatrynomic: _patronymicParent,
          applicantEmail: _email,
          applicantPhone: _phone,
          notificationReceiveType: getNotificationReceiveType(agreeEmail: _agreeEmail, agreeLk: _agreeLk));
      return await _apiPatient.postRegister(thisData: thisData);
    }





  bool _areDifferent() {
    return _lastNamePatient != null ||
    _firstNamePatient != null ||
    _patronymicPatient != null ||
    _birthDate != null ||
    _gender != null ||
    _regionName != null ||
    _uveit != null ||
    _whoYouAreToThePatient != null ||
    _lastNameParent != null ||
    _firstNameParent != null ||
    _patronymicParent != null ||
    _email != null ||
    _phone != null ||
    _mkbName != null ||
    _mkbCode != null ||
    _diagnosisComment != null ||
    _hospitalName != null ||
    _unknownHospital != null ||
    _doctorFio != null ||
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
                          //   fieldKey: _keysPatient[EnumPatient.canContainCookies]!,
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
                              Checkbox(
                                value: _canContainCookies,
                                onChanged: (value) {
                                  setState(() {
                                    _canContainCookies = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Я прочитал(а) и соглашаюсь с условиями ',
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
                                          ..onTap = () =>
                                            openUrl('https://ja.aspirre-russia.ru/static/PrivacyPolicy.docx'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30,),
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
        Text('Информация о пациенте', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysPatient[EnumPatient.lastName]!,
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
          fieldKey: _keysPatient[EnumPatient.firstName]!,
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
          fieldKey: _keysPatient[EnumPatient.patronymic]!,
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
        InputSelectDate(
          labelText: 'Дата рождения',
          fieldKey: _keysPatient[EnumPatient.birthDate]!,
          value: _birthDate,
          required: true,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _birthDate = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Пол',
          fieldKey: _keysPatient[EnumPatient.gender]!,
          value: (_gender == 'Мужчина') ? 'Мужской' : (_gender == 'Женщина') ? 'Женский' : _gender,
          required: true,
          listValues: _listGender,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Регион',
          fieldKey: _keysPatient[EnumPatient.regionName]!,
          value: _regionName,
          required: true,
          listValues: _listSprRegion,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _regionName = value;
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
        Text('Информация об опекуне', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputSelect(
          labelText: 'Степень родства',
          fieldKey: _keysParent[EnumParent.whoYouAreToThePatient]!,
          value: _whoYouAreToThePatient,
          required: true,
          listValues: _listSprRelationship,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _whoYouAreToThePatient = value;
            });
          },
        ),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysParent[EnumParent.lastName]!,
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
          fieldKey: _keysParent[EnumParent.firstName]!,
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
          fieldKey: _keysParent[EnumParent.patronymic]!,
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
          fieldKey: _keysParent[EnumParent.email]!,
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
          fieldKey: _keysParent[EnumParent.phone]!,
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





  Widget buildDiagnosesForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Диагноз', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputSelect(
          labelText: 'Название',
          fieldKey: _keysDiagnoses[EnumDiagnoses.mkbName]!,
          value: _mkbName,
          required: true,
          listValues: _listSprDiagnoses,
          listRoles: Roles.all,
          onChanged: (value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _mkbName = value;
                  if (value.isNotEmpty) {
                    _mkbCode = _dataSprDiagnoses
                        .firstWhereOrNull((e) => '${e.mkbCode} ${e.synonym.replaceAll('\n', '')}' == value)
                        ?.mkbCode ??
                        '';
                  } else {
                    _mkbCode = '';
                  }
                });
              }
            });
          },
        ),
        SizedBox(height: 12.0,),
        InputText(
          labelText: 'Код МКБ-10',
          fieldKey: _keysDiagnoses[EnumDiagnoses.mkbCode]!,
          value: _mkbCode,
          required: true,
          readOnly: true,
          listRoles: Roles.all,
          onChanged: (value) {
          },
        ),
        if (_mkbCode == 'M31.8' || _mkbCode == 'M32.8')
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
        InputSelect(
          labelText: 'Увеит',
          fieldKey: _keysPatient[EnumPatient.uveit]!,
          value: _uveit == null || _uveit.toString().isEmpty ? '' : _uveit! ? _listSprUveitExists[1] : _listSprUveitExists[0],
          required: true,
          listValues: _listSprUveitExists,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _uveit = (value == _listSprUveitExists[0]) ? false : (value == _listSprUveitExists[1]) ? true : null;
            });
          },
        ),
      ],
    );
  }




  Widget buildDoctorForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Данные о враче', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputSelect(
          labelText: 'Название учреждения',
          fieldKey: _keysPatient[EnumPatient.hospitalName]!,
          value: _hospitalName,
          required: true,
          listValues: _listSprHospitals,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _hospitalName = value;
            });
          },
        ),
        if (_hospitalName == 'Другое')
          InputText(
            labelText: 'Название учреждения',
            fieldKey: _keysPatient[EnumPatient.unknownHospital]!,
            value: _unknownHospital,
            maxLength: 300,
            required: (_hospitalName == 'Другое') ? true : false,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _unknownHospital = value;
              });
            },
          ),
        InputSelect(
          labelText: 'Врач',
          fieldKey: _keysPatient[EnumPatient.doctorFio]!,
          value: _doctorFio,
          required: true,
          listValues: _listSprDoctors,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _doctorFio = value;
              if (_doctorFio == 'Другой') {
                _doctorId = '1';
              } else if (_doctorFio == 'Отсутствует') {
                _doctorId = '2';
              }
              else {
                _doctorId = _dataSprDoctors
                    .firstWhereOrNull((e) => e.name == _doctorFio)
                    ?.id ?? '';
              }
            });
          },
        ),
        if (_doctorFio == 'Другой')
          InputText(
            labelText: 'ФИО врача',
            fieldKey: _keysPatient[EnumPatient.unknownDoctor]!,
            value: _unknownDoctor,
            maxLength: 200,
            required: (_doctorFio == 'Другой') ? true : false,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _unknownDoctor = value;
              });
            },
          ),
        if (_doctorFio == 'Другой') Text('Указанный Вами врач в системе не зарегистрирован. Вы будете пользоваться приложением в режиме самоконтроля', style: textStyleGreen,),
        if (_doctorFio == 'Другой') SizedBox(height: 5),
      ],
    );
  }

}

