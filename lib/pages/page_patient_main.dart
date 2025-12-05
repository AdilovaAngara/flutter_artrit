import 'package:artrit/pages/page_inspections_main.dart';
import 'package:artrit/pages/page_notifications_settings.dart';
import 'package:artrit/pages/page_patient_edit.dart';
import 'package:artrit/pages/page_questionnaire.dart';
import 'package:artrit/roles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_inspections.dart';
import '../api/api_inspections_photo.dart';
import '../api/api_patient.dart';
import '../api/api_diagnoses.dart';
import '../api/api_questionnaire.dart';
import '../api/api_spr.dart';
import '../data/data_inspections_photo.dart';
import '../data/data_diagnoses.dart';
import '../data/data_inspections.dart';
import '../data/data_questionnaire.dart';
import '../data/data_patient.dart';
import '../data/data_spr_diagnoses.dart';
import '../my_functions.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/patients_card_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widget_another/inspection_view_widget.dart';
import '../widgets/list_tile_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'menu.dart';

class PagePatientMain extends StatefulWidget {
  const PagePatientMain({super.key});

  @override
  State<PagePatientMain> createState() => PagePatientMainState();
}

class PagePatientMainState extends State<PagePatientMain> {
  late Future<void> _future;

  /// API
  final ApiPatient _apiPatient = ApiPatient();
  final ApiDiagnoses _apiPatientDiagnoses = ApiDiagnoses();
  final ApiInspections _apiInspections = ApiInspections();
  final ApiQuestionnaire _apiQuestionnaire = ApiQuestionnaire();
  final ApiSpr _apiSpr = ApiSpr();
  final ApiInspectionsPhoto _apiPhoto = ApiInspectionsPhoto();

  /// Данные
  late DataPatient _dataPatient;
  late List<DataDiagnoses> _dataDiagnoses;
  late List<DataInspections> _dataInspections;
  late List<DataQuestionnaire> _dataQuestionnaire;
  late List<DataSprDiagnoses> _dataSprDiagnoses;
  late List<DataInspectionsPhoto>? _allDataPhoto;

  /// Параметры
  late int _role;
  late String _patientsId;
  late String? _diagnosesId;
  String? _mkbName = 'Не указан';
  String? _mkbCode = '';
  int lastInspectionsIndex = 0;
  late RichText patientsInfoText;
  late bool _automaticallyImplyLeading = false;
  late String _fullAge;
  late double _doubleAge;
  late String _appBarTitle = '';
  static const String _bodyType = 'angles';

  /// Ключи
  final GlobalKey<AppBarWidgetState> _appBarKey = GlobalKey<AppBarWidgetState>();

  @override
  void initState() {
    _future = _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();
    await _loadDynamicData();
  }


  /// Загружаем данные, требующие постоянного обновления
  Future<void> _loadDynamicData() async {
    _dataPatient = await _apiPatient.get(patientsId: _patientsId);
    _dataDiagnoses = await _apiPatientDiagnoses.get(patientsId: _patientsId);
    _dataInspections = await _apiInspections.get(patientsId: _patientsId);
    _dataQuestionnaire = await _apiQuestionnaire.get(patientsId: _patientsId);
    _allDataPhoto =
    await _apiPhoto.getAll(patientsId: _patientsId, bodyType: _bodyType);
    setState(() {
      _fullAge = calculateAge(convertTimestampToDate(_dataPatient.birthDate),
          getFullAge: true, getDoubleAge: false);
      saveSecureData(SecureKey.fullAge, _fullAge);
      _doubleAge = double.parse(calculateAge(
          convertTimestampToDate(_dataPatient.birthDate),
          getFullAge: false,
          getDoubleAge: true));
      saveSecureData(SecureKey.doubleAge, _doubleAge.toString());
      _automaticallyImplyLeading = (_role == 1) ? false : true;
      _appBarTitle = (_role == 1)
          ? EnumMenu.homePatient.displayName
          : 'Карта пациента';
      _diagnosesId = _dataDiagnoses.isNotEmpty
          ? _dataDiagnoses.first.diagnosisId
          : null;
      if (_diagnosesId != null) {
        final diagnosis = _dataSprDiagnoses
            .firstWhereOrNull((diagnoses) => diagnoses.id == _diagnosesId);
        if (diagnosis != null) {
          _mkbName = diagnosis.mkbName;
          _mkbCode = diagnosis.mkbCode;
        }
      }
    });
  }



  Future<void> _refreshData() async {
    await _loadDynamicData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        key: _appBarKey,
        title: _appBarTitle,
        automaticallyImplyLeading: _automaticallyImplyLeading,
        showChat: true,
        showNotifications: true,
      ),
      endDrawer: MenuDrawer(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Padding(
              padding: paddingFormAll,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ListTileWidget(
                    widgetSubtitle: PatientsCardWidget(
                      lastName: _dataPatient.lastName,
                      firstName: _dataPatient.firstName,
                      patronymic: _dataPatient.patronymic,
                      gender: _dataPatient.gender ?? '',
                      birthDate: _dataPatient.birthDate,
                      invalid: _dataPatient.invalid,
                      mkbCode: _mkbCode,
                      mkbName: _mkbName,
                      uveit: _dataPatient.uveit,
                      lastInspectionUveit: _dataPatient.lastInspectionUveit,
                    ),
                    iconSize: 35,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              PagePatientEdit(
                                title: EnumMenu.profilePatient.displayName,
                                isEditForm: true,
                              ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: EnumMenu.anamnesis.displayName,
                    iconTrailing: EnumMenu.anamnesis.icon,
                    colorIconTrailing: EnumMenu.anamnesis.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.anamnesis,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.inspections.displayName,
                    iconTrailing: EnumMenu.inspections.icon,
                    colorIconTrailing: EnumMenu.inspections.iconColor,
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              PageInspectionsMain(
                                title: EnumMenu.inspections.displayName
                              ),
                          ),
                        ).then((_) async {
                          await _refreshData();
                        }),
                  ),
                  ListTileWidget(
                    title: EnumMenu.tests.displayName,
                    iconTrailing: EnumMenu.tests.icon,
                    colorIconTrailing: EnumMenu.tests.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.tests,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.researches.displayName,
                    iconTrailing: EnumMenu.researches.icon,
                    colorIconTrailing: EnumMenu.researches.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.researches,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.treatment.displayName,
                    iconTrailing: EnumMenu.treatment.icon,
                    colorIconTrailing: EnumMenu.treatment.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.treatment,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.tuberculosis.displayName,
                    iconTrailing: EnumMenu.tuberculosis.icon,
                    colorIconTrailing: EnumMenu.tuberculosis.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.tuberculosis,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.vaccination.displayName,
                    iconTrailing: EnumMenu.vaccination.icon,
                    colorIconTrailing: EnumMenu.vaccination.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.vaccination,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.questionnaire.displayName,
                    widgetSubtitle: Column(
                      children: [
                        SizedBox(
                          height: 2,
                        ),
                        Row(
                          children: [
                            Text('Индекс ФН:', style: subtitleTextStyle),
                            SizedBox(width: 10.0),
                            Text(
                                '${(_dataQuestionnaire.isNotEmpty) ? _dataQuestionnaire[0].result : 'Нет данных'}',
                                style: listLabelStyle),
                          ],
                        ),
                      ],
                    ),
                    iconTrailing: EnumMenu.questionnaire.icon,
                    colorIconTrailing: EnumMenu.questionnaire.iconColor,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => PageQuestionnaire(
                          title: EnumMenu.questionnaire.displayName,
                        ),
                      ),
                    ).then((_) async {
                      await _refreshData();
                    }),
                  ),
                  ListTileWidget(
                    title: EnumMenu.scale.displayName,
                    iconTrailing: EnumMenu.scale.icon,
                    colorIconTrailing: EnumMenu.scale.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.scale,
                    ),
                  ),
                  ListTileWidget(
                    title: EnumMenu.report.displayName,
                    iconTrailing: EnumMenu.report.icon,
                    colorIconTrailing: EnumMenu.report.iconColor,
                    onTap: () => navigateToPageMenu(
                      context,
                      EnumMenu.report,
                    ),
                  ),
                  if (Roles.asDoctor.contains(_role))
                  ListTileWidget(
                    title: EnumMenu.notificationsSettings.displayName,
                    iconTrailing: EnumMenu.notificationsSettings.icon,
                    colorIconTrailing: EnumMenu.notificationsSettings.iconColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            PageNotificationsSettings(
                              title: EnumMenu.notificationsSettings.displayName,
                              forPatient: true,
                            ),
                        ),
                      );
                    }
                  ),
                  ListTileWidget(
                    title: 'Последний осмотр',
                    widgetSubtitle: (_dataInspections.isNotEmpty)
                        ? Text(
                            convertTimestampToDateTime(
                                    _dataInspections[lastInspectionsIndex]
                                        .date) ??
                                '',
                            style: subtitleTextStyle)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 2,
                              ),
                              Text('Нет данных', style: subtitleTextStyle),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Text('Увеит:', style: subtitleTextStyle),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    _dataPatient.uveit
                                        ? 'Присутствует'
                                        : 'Отсутствует',
                                    style: listLabelStyle,
                                  ),
                                ],
                              ),
                            ],
                          ),
                    iconTrailing: FontAwesomeIcons.clock,
                    colorIconTrailing: Colors.grey,
                    shapeParam: 0.0,
                    padding: 0.0,
                    onTap: () {},
                  ),
                  if (_dataInspections.isNotEmpty)
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: InspectionViewWidget(
                        thisData: _dataInspections[lastInspectionsIndex],
                        allData: _dataInspections,
                        allDataPhoto: _allDataPhoto,
                        doubleAge: _doubleAge,
                        role: _role,
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
