import 'package:artrit/api/api_parent.dart';
import 'package:artrit/api/api_patient.dart';
import 'package:artrit/api/api_patient_diagnoses.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../data/data_patient_diagnoses.dart';
import '../data/data_spr_diagnoses.dart';
import '../data/data_parent.dart';
import '../data/data_spr_region.dart';
import '../data/data_spr_relationship.dart';
import '../data/data_patient.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_select.dart';
import '../widgets/input_switch.dart';
import '../widgets/input_text.dart';
import '../theme.dart';

class PagePatientEdit extends StatefulWidget {
  final String title;
  final VoidCallback? onDataUpdated;

  const PagePatientEdit({
    super.key,
    required this.title,
    this.onDataUpdated,
  });

  @override
  State<PagePatientEdit> createState() => PagePatientEditState();
}

class PagePatientEditState extends State<PagePatientEdit> {
  late Future<void> _future;
  /// API
  final ApiPatient _apiPatient = ApiPatient();
  final ApiParent _apiParent = ApiParent();
  final ApiPatientDiagnoses _apiPatientDiagnoses = ApiPatientDiagnoses();
  final ApiSpr _apiSpr = ApiSpr();
  /// Данные
  late DataPatient _dataPatient;
  late DataParent _dataParent;
  late List<DataPatientDiagnoses> _dataPatientDiagnoses;
  late List<DataSprRegion> _dataSprRegion;
  late List<DataSprRelationship> _dataSprRelationship;
  late List<DataSprDiagnoses> _dataSprDiagnoses;
  // Справочники
  final List<String> _listGender = ['Мужской', 'Женский'];
  List<String> _listSprRegion = [];
  List<String> _listSprRelationship = [];
  /// Параметры
  bool _isLoading = false;
  late int _role;
  String _appBarTitle = '';
  late String _patientsId;
  late String? _lastNamePatient;
  late String? _firstNamePatient;
  late String? _patronymicPatient;
  late String? _birthDate;
  late String? _gender;
  late String? _regionName;
  late String? _address;
  bool _invalid = false;
  late String? _whoYouAreToThePatient;
  late String? _lastNameParent;
  late String? _firstNameParent;
  late String? _patronymicParent;
  late String? _email;
  late String? _phone;
  late String? _diagnosesId;
  late String? _diagnosisComment;
  late String? _mkbName;
  late String? _mkbCode;
  late String? _hospitalName;
  late String? _doctor;
  late String? _doctorFio;
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

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _appBarTitle = (_role == 1) ? widget.title : 'Данные пациента';
    _patientsId = await readSecureData(SecureKey.patientsId);
    _dataPatient = await _apiPatient.get(patientsId: _patientsId);
    _dataParent = await _apiParent.get(patientsId: _patientsId);
    _dataPatientDiagnoses = await _apiPatientDiagnoses.get(patientsId: _patientsId);
    _dataSprRegion = await _apiSpr.getRegions();
    _dataSprRelationship = await _apiSpr.getRelationship();
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();

    _lastNamePatient = _dataPatient.lastName;
    _firstNamePatient = _dataPatient.firstName;
    _patronymicPatient = _dataPatient.patronymic;
    _birthDate = convertTimestampToDate(_dataPatient.birthDate);
    _gender = _dataPatient.gender;
    _regionName = _dataPatient.regionName;
    _address = _dataPatient.address;
    _invalid = _getBootInvalid();

    _whoYouAreToThePatient = _dataParent.whoYouAreToThePatient;
    _lastNameParent = _dataParent.lastName;
    _firstNameParent = _dataParent.firstName;
    _patronymicParent = _dataParent.patronymic;
    _email = _dataParent.email;
    _phone = _dataParent.phone;

    _diagnosesId = _dataPatientDiagnoses.isNotEmpty ? _dataPatientDiagnoses.first.diagnosisId : null;
    _diagnosisComment = _dataPatientDiagnoses.isNotEmpty ? _dataPatientDiagnoses.first.comment ?? '' : '';
    if (_diagnosesId != null)
      {
        _mkbName = _dataSprDiagnoses.firstWhereOrNull((diagnoses) => diagnoses.id == _diagnosesId)?.mkbName;
        _mkbCode = _dataSprDiagnoses.firstWhereOrNull((diagnoses) => diagnoses.id == _diagnosesId)?.mkbCode;
      }
    else {
      _mkbName = '';
      _mkbCode = '';
    }
    _hospitalName = _dataPatient.hospitalName == 'Другое' ? _dataPatient.unknownHospital : _dataPatient.hospitalName;
    _doctor = _dataPatient.doctor;
    _doctorFio = _doctor == '1' ? _dataPatient.unknownDoctor : _dataPatient.doctorFio;
    _listSprRegion = _dataSprRegion.map((e) => e.name).toList()..sort();
    _listSprRelationship = _dataSprRelationship.map((e) => e.name ?? '').toList()..sort();
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

    await Future.wait([_putPatientData(), _putParentData()]);

    setState(() {
      _isLoading = false;
    });

    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _putPatientData() async {
    DataPatient thisData = DataPatient(
      regionName: _regionName ?? '',
      hospitalName: _dataPatient.hospitalName,
      roleName: null,
      id: _dataPatient.id,
      doctor: _dataPatient.doctor,
      firstName: _firstNamePatient ?? '',
      patronymic: _patronymicPatient ?? '',
      lastName: _lastNamePatient ?? '',
      gender: _gender,
      address: _address,
      invalid: _invalid,
      notInvalidReason: _dataPatient.notInvalidReason,
      birthDate: convertToTimestamp(_birthDate),
      uveit: _dataPatient.uveit,
      notificationReceiveType: _dataPatient.notificationReceiveType,
      defaultLabProfileId: _dataPatient.defaultLabProfileId,
      regionId: _dataSprRegion.firstWhereOrNull((region) => region.name == _regionName)?.id,
      unknownDoctor: _dataPatient.unknownDoctor,
      hospitalId: _dataPatient.hospitalId,
      unknownHospital: _dataPatient.unknownHospital,
      roleId: _dataPatient.roleId,
      doctorFio: _dataPatient.doctorFio,
      questionnaireResult: _dataPatient.questionnaireResult,
      lastInspectionUveit: _dataPatient.lastInspectionUveit,
    );
    _apiPatient.put(patientsId: _patientsId, thisData: thisData);
  }

  Future<void> _putParentData() async {
    DataParent thisData = DataParent(
      whoYouAreToThePatient: _whoYouAreToThePatient,
      id: _dataParent.id,
      lastName: _lastNameParent,
      firstName: _firstNameParent,
      patronymic: _patronymicParent,
      email: _email,
      phone: _phone,
      patientsId: _dataParent.patientsId,
      relationshipDegreeId: _dataSprRelationship.firstWhereOrNull((relationship) => relationship.name == _whoYouAreToThePatient)?.id,
    );
    _apiParent.put(patientsId: _patientsId, thisData: thisData);
  }




  bool _areDifferent() {
    final w = _dataPatient;
    final p = _dataParent;
    return _lastNamePatient != w.lastName ||
        _firstNamePatient != w.firstName ||
        _patronymicPatient != w.patronymic ||
        _birthDate != convertTimestampToDate(w.birthDate) ||
        _gender != w.gender ||
        _regionName != w.regionName ||
        _address != w.address ||
        _invalid != _getBootInvalid() ||
        _whoYouAreToThePatient != p.whoYouAreToThePatient ||
        _lastNameParent != p.lastName ||
        _firstNameParent != p.firstName ||
        _patronymicParent != p.patronymic ||
        _email != p.email ||
        _phone != p.phone;
  }



bool _getBootInvalid()
{
  return (_dataPatient.invalid is int) ? _dataPatient.invalid != 0 : false;
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _appBarTitle,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          _buildPatientForm(),
                          SizedBox(height: 30),
                          _buildParentForm(),
                          SizedBox(height: 30),
                          _buildDiagnosesForm(),
                          SizedBox(height: 30),
                          _buildDoctorForm(),
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




  Widget _buildPatientForm() {
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _regionName = value;
            });
          },
        ),
        InputText(
          labelText: 'Адрес проживания',
          fieldKey: _keysPatient[EnumPatient.address]!,
          value: _address,
          required: false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _address = value;
            });
          },
        ),
        InputSwitch(
          labelText: 'Инвалидность',
          fieldKey: _keysPatient[EnumPatient.invalid]!,
          value: _invalid,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _invalid = value;
            });
          },
        ),
      ],
    );
  }






  Widget _buildParentForm() {
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
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
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _phone = value;
            });
          },
        ),
      ],
    );
  }





  Widget _buildDiagnosesForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Диагноз', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputText(
          labelText: 'Название',
          fieldKey: _keysDiagnoses[EnumDiagnoses.mkbName]!,
          value: _mkbName,
          required: true,
          readOnly: true,
          listRoles: Roles.all,
          role: _role,
          onChanged: (value) {
            setState(() {
              _mkbName = value;
            });
          },
        ),
        InputText(
          labelText: 'Код МКБ-10',
          fieldKey: _keysDiagnoses[EnumDiagnoses.mkbCode]!,
          value: _mkbCode,
          required: true,
          readOnly: true,
          listRoles: Roles.all,
          role: _role,
          onChanged: (value) {
            setState(() {
              _mkbCode = value;
            });
          },
        ),
        if (_mkbCode == 'M31.8' || _mkbCode == 'M32.8')
          InputText(
            labelText: 'Комментарий к диагнозу',
            fieldKey: _keysDiagnoses[EnumDiagnoses.diagnosisComment]!,
            value: _diagnosisComment,
            readOnly: true,
            required: false,
            listRoles: Roles.all,
            role: _role,
            onChanged: (value) {
              setState(() {
                _diagnosisComment = value;
              });
            },
          ),
      ],
    );
  }




  Widget _buildDoctorForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Данные о враче', style: captionTextStyle, textAlign: TextAlign.start,),
        SizedBox(height: 10),
        InputText(
          labelText: 'Название учреждения',
          fieldKey: _keysPatient[EnumPatient.hospitalName]!,
          value: _hospitalName,
          required: true,
          readOnly: true,
          listRoles: Roles.asPatient,
          role: _role,
        ),
        InputText(
          labelText: 'Врач',
          fieldKey: _keysPatient[EnumPatient.doctorFio]!,
          value: _doctorFio,
          required: true,
          readOnly: true,
          listRoles: Roles.asPatient,
          role: _role,
        ),
      ],
    );
  }

}

