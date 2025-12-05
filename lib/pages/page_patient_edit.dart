import 'package:artrit/api/api_parent.dart';
import 'package:artrit/api/api_patient.dart';
import 'package:artrit/api/api_diagnoses.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/data/data_spr_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../data/data_diagnoses.dart';
import '../data/data_patient_register.dart';
import '../data/data_result.dart';
import '../data/data_spr_diagnoses.dart';
import '../data/data_parent.dart';
import '../data/data_spr_doctors.dart';
import '../data/data_spr_hospitals.dart';
import '../data/data_spr_region.dart';
import '../data/data_spr_relationship.dart';
import '../data/data_patient.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/radio_group_widget.dart';
import '../widgets/show_message.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/input_switch.dart';
import '../widgets/input_text.dart';
import '../theme.dart';

class PagePatientEdit extends StatefulWidget {
  final String title;
  final bool isEditForm;

  const PagePatientEdit({
    super.key,
    required this.title,
    required this.isEditForm,
  });

  @override
  State<PagePatientEdit> createState() => PagePatientEditState();
}

class PagePatientEditState extends State<PagePatientEdit> {
  late Future<void> _future;

  /// API
  final ApiPatient _apiPatient = ApiPatient();
  final ApiParent _apiParent = ApiParent();
  final ApiDiagnoses _apiDiagnoses = ApiDiagnoses();
  final ApiSpr _apiSpr = ApiSpr();

  /// Данные
  late DataPatient _dataPatient;
  late DataParent _dataParent;
  late List<DataDiagnoses> _dataDiagnoses;
  late List<DataSprRegion> _dataSprRegion;
  late List<DataSprHospitals> _dataSprHospitals;
  late List<DataSprRelationship> _dataSprRelationship;
  late List<DataSprDiagnoses> _dataSprDiagnoses;
  late List<DataSprDoctors> _dataSprDoctors;

  /// Справочники
  List<SprItem> _listSprDoctors = [];

  /// Параметры
  bool _isLoading = false;
  late int _role;
  String _appBarTitle = '';
  late String _doctorsId;
  late String _patientsId;
  String? _lastNamePatient;
  String? _firstNamePatient;
  String? _patronymicPatient;
  String? _birthDate;
  String? _gender;
  String? _regionId;
  String? _address;
  int _invalid = 2;
  int? _notInvalidReason;
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
  String? _doctor;

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
    // Подгружаем справочники
    _dataSprRegion = await _apiSpr.getRegions();
    _dataSprHospitals = await _apiSpr.getHospitals();
    _dataSprRelationship = await _apiSpr.getRelationship();
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();
    _dataSprDoctors = await _apiSpr.getDoctors();
    _listSprDoctors = _dataSprDoctors
        .map((e) => SprItem(id: e.id, name: e.name ?? ''))
        .toList();
    _listSprDoctors.addAll([
      SprItem(id: '1', name: 'Другой'),
      SprItem(id: '2', name: 'Отсутствует'),
    ]);

    _appBarTitle = (_role == 1) ? widget.title : 'Данные пациента';

    if (widget.isEditForm) {
      _patientsId = await readSecureData(SecureKey.patientsId);
      _dataPatient = await _apiPatient.get(patientsId: _patientsId);
      _dataParent = await _apiParent.get(patientsId: _patientsId);
      _dataDiagnoses = await _apiDiagnoses.get(patientsId: _patientsId);


      _lastNamePatient = _dataPatient.lastName;
      _firstNamePatient = _dataPatient.firstName;
      _patronymicPatient = _dataPatient.patronymic;
      _birthDate = convertTimestampToDate(_dataPatient.birthDate);
      _gender = _dataPatient.gender;
      _regionId = _dataPatient.regionId;
      _address = _dataPatient.address;
      _invalid = _dataPatient.invalid;
      _notInvalidReason = _dataPatient.notInvalidReason;

      _relationshipDegreeId = _dataParent.relationshipDegreeId;
      _lastNameParent = _dataParent.lastName;
      _firstNameParent = _dataParent.firstName;
      _patronymicParent = _dataParent.patronymic;
      _email = _dataParent.email;
      _phone = _dataParent.phone;

      _diagnosisId =
          _dataDiagnoses.isNotEmpty ? _dataDiagnoses.first.diagnosisId : null;
      _diagnosisComment =
          _dataDiagnoses.isNotEmpty ? _dataDiagnoses.first.comment ?? '' : '';
      _hospitalId = _dataPatient.hospitalId;
      _unknownHospital = _dataPatient.unknownHospital;
      _doctor = _dataPatient.doctor;
    } else {
      _doctorsId = await readSecureData(SecureKey.doctorsId);
      _doctor = _doctorsId;
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

    if (widget.isEditForm) {
      await Future.wait(
        [_putPatientData(), _putParentData(), _putDiagnosisData()]);
    } else {
      DataResult1 result = await _postRequest();
      if (result.message != null) {
        ShowMessage.show(context: context, message: result.message!);
      } else {
        if (mounted) {
          Navigator.pop(context);
          ShowMessage.show(
              context: context,
              message:
              'Пациент успешно зарегистрирован в системе');
        }
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }



  Future<void> _putPatientData() async {
    DataPatient thisData = DataPatient(
      regionName: _dataSprRegion
              .firstWhereOrNull((region) => region.id == _regionId)
              ?.name ??
          '',
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
      notInvalidReason: _notInvalidReason,
      birthDate: convertToTimestamp(_birthDate),
      uveit: _dataPatient.uveit,
      notificationReceiveType: _dataPatient.notificationReceiveType,
      defaultLabProfileId: _dataPatient.defaultLabProfileId,
      regionId: _regionId,
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
      whoYouAreToThePatient: _dataSprRelationship
          .firstWhereOrNull(
              (relationship) => relationship.id == _relationshipDegreeId)
          ?.name,
      id: _dataParent.id,
      lastName: _lastNameParent,
      firstName: _firstNameParent,
      patronymic: _patronymicParent,
      email: _email,
      phone: _phone,
      patientsId: _dataParent.patientsId,
      relationshipDegreeId: _relationshipDegreeId,
    );
    _apiParent.put(patientsId: _patientsId, thisData: thisData);
  }

  Future<void> _putDiagnosisData() async {
    String recordId = _dataDiagnoses.first.id;
    DataDiagnoses thisData = DataDiagnoses(
        id: recordId,
        patientsId: _patientsId,
        diagnosisId: _diagnosisId,
        comment: _diagnosisComment,
        dateCreated: _dataDiagnoses.first.dateCreated);
    _apiDiagnoses.put(
        patientsId: _patientsId, recordId: recordId, thisData: thisData);
  }





  /// Запрос на добавление нового пациента
  Future<DataResult1> _postRequest() async {
    DataPatientRegister thisData = DataPatientRegister(
        firstName: _firstNamePatient,
        lastName: _lastNamePatient,
        patrynomic: _patronymicPatient ?? '',
        birthDate: convertStrToDate(_birthDate) ?? getMoscowDateTime(),
        regionId: _regionId,
        isMale: _gender == listGender[0].name ? 'true' : 'false',
        isFemale: _gender == listGender[1].name ? 'true' : 'false',
        diagnosisId: _diagnosisId,
        diagnosisComment: _diagnosisComment,
        uveit: false,
        doctorId: _doctor,
        unknownDoctor: null,
        hospitalId: _hospitalId,
        unknownHospital: _unknownHospital,
        canContainCookies: false,
        relationshipDegreeId: _relationshipDegreeId ?? 'd3cb858f-8b75-4f36-8b1f-350c33a17c38', // Отсутствует
        applicantFirstName: _firstNameParent ?? '',
        applicantLastName: _lastNameParent ?? '',
        applicantPatrynomic: _patronymicParent ?? '',
        applicantEmail: _email,
        applicantPhone: _phone,
        notificationReceiveType: getNotificationReceiveType(
            agreeEmail: true, agreeLk: true));
    return await _apiPatient.postRegister(thisData: thisData);
  }







  bool _areDifferent() {
    if (!widget.isEditForm) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _lastNamePatient != null ||
          _firstNamePatient != null ||
          _patronymicPatient != null ||
          _patronymicPatient != null ||
          _birthDate != null ||
          _gender != null ||
          _regionId != null ||
          _address != null ||
          _invalid == 1 ||
          _notInvalidReason != null ||
          _relationshipDegreeId != null ||
          _lastNameParent != null ||
          _firstNameParent != null ||
          _patronymicParent != null ||
          _email != null ||
          _phone != null;
    }

    // Иначе Сравниваем поля
    final w = _dataPatient;
    final p = _dataParent;
    return _lastNamePatient != w.lastName ||
        _firstNamePatient != w.firstName ||
        _patronymicPatient != w.patronymic ||
        _birthDate != convertTimestampToDate(w.birthDate) ||
        _gender != w.gender ||
        _regionId != w.regionId ||
        _address != w.address ||
        _invalid != w.invalid ||
        _notInvalidReason != w.notInvalidReason ||
        _relationshipDegreeId != p.relationshipDegreeId ||
        _lastNameParent != p.lastName ||
        _firstNameParent != p.firstName ||
        _patronymicParent != p.patronymic ||
        _email != p.email ||
        _phone != p.phone;
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
                          if (widget.isEditForm) ...[
                            _buildInvalidForm(),
                            SizedBox(height: 30),
                          ],
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
                        listRoles: Roles.all,
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
        Text(
          'Информация о пациенте',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysPatient[EnumPatient.lastName]!,
          value: _lastNamePatient,
          required: true,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
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
          listRoles: Roles.all,
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
          listRoles: Roles.all,
          role: _role,
          onChanged: (value) {
            setState(() {
              _patronymicPatient = value;
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата рождения',
          fieldKey: _keysPatient[EnumPatient.birthDate]!,
          value: _birthDate,
          lastDateTime: getMoscowDateTime(),
          required: true,
          listRoles: Roles.all,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _birthDate = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Пол',
          fieldKey: _keysPatient[EnumPatient.gender]!,
          allValues: listGender,
          selectedValue: (_gender == 'Мужчина')
              ? 'Мужской'
              : (_gender == 'Женщина')
                  ? 'Женский'
                  : _gender,
          required: true,
          listRoles: Roles.all,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Регион',
          fieldKey: _keysPatient[EnumPatient.regionName]!,
          allValues: _dataSprRegion
              .map((e) => SprItem(id: e.id, name: e.name))
              .toList(),
          selectedValue: _regionId,
          required: true,
          listRoles: Roles.all,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _regionId = value;
            });
          },
        ),
        InputText(
          labelText: 'Адрес проживания',
          fieldKey: _keysPatient[EnumPatient.address]!,
          value: _address,
          required: false,
          listRoles: Roles.all,
          role: _role,
          onChanged: (value) {
            setState(() {
              _address = value;
            });
          },
        ),
      ],
    );
  }







  Widget _buildInvalidForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Инвалидность',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        InputSwitch(
          labelText: 'Инвалидность',
          fieldKey: _keysPatient[EnumPatient.invalid]!,
          value: _invalid == 1 ? true : false,
          listRoles: Roles.all,
          role: _role,
          onChanged: (value) {
            setState(() {
              _invalid = value ? 1 : 2;
            });
          },
        ),
        if (_invalid == 2)
          RadioGroupWidget(
            labelText: 'Укажите причину',
            listAnswers: ['Сняли', 'Отказали', 'Не подавали документы'],
            selectedIndex: _notInvalidReason != null ? _notInvalidReason! - 1 : null,
            dividerHeight: 0,
            listRoles: Roles.all,
            onChanged: (value) {
              setState(() {
                _notInvalidReason = value != null ? value + 1 : null;
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
        Text(
          'Информация об опекуне',
          style: captionTextStyle,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 10),
        WidgetInputSelect(
          labelText: 'Степень родства',
          fieldKey: _keysParent[EnumParent.relationshipDegreeId]!,
          allValues: _dataSprRelationship
              .map((e) => SprItem(id: e.id, name: e.name ?? ''))
              .toList(),
          selectedValue: _relationshipDegreeId,
          required: Roles.asPatient.contains(_role) ? true : false,
          listRoles: Roles.all,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _relationshipDegreeId = value;
            });
          },
        ),
        InputText(
          labelText: 'Фамилия',
          fieldKey: _keysParent[EnumParent.lastName]!,
          value: _lastNameParent,
          required: Roles.asPatient.contains(_role) ? true : false,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
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
          required: Roles.asPatient.contains(_role) ? true : false,
          keyboardType: TextInputType.name,
          listRoles: Roles.all,
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
          listRoles: Roles.all,
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
          listRoles: Roles.all,
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
          listRoles: Roles.all,
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

  Widget _buildDiagnosesForm() {
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
        InputText(
          labelText: 'Комментарий к диагнозу',
          fieldKey: _keysDiagnoses[EnumDiagnoses.diagnosisComment]!,
          value: _diagnosisComment,
          maxLength: 300,
          required: Roles.asPatient.contains(_role)
              ? (_diagnosisId == '18ff07ab-5fb5-49b1-8fe4-b301968df8af' ||
              _diagnosisId == '13019398-b69c-4d4b-a58b-d3ed4f485ed0'
              ? true : false) : false,
          listRoles: Roles.all,
          onChanged: (value) {
            setState(() {
              _diagnosisComment = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDoctorForm() {
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
          fieldKey: _keysPatient[EnumPatient.hospitalName]!,
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
        if (_hospitalId == '2a1101a8-0df3-4ac1-9c9e-4e5c15e9b422' && widget.isEditForm) // Другое
          InputText(
            labelText: 'Название учреждения',
            fieldKey: _keysPatient[EnumPatient.unknownHospital]!,
            value: _unknownHospital,
            maxLength: 300,
            required: (_hospitalId == '2a1101a8-0df3-4ac1-9c9e-4e5c15e9b422' && Roles.asPatient.contains(_role))
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
          fieldKey: _keysPatient[EnumPatient.doctorFio]!,
          allValues: _listSprDoctors,
          selectedValue: _doctor,
          isSort: false,
          required: true,
          readOnly: true,
          listRoles: Roles.all,
        ),
      ],
    );
  }
}
