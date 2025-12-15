import 'package:artrit/pages/page_patient_edit.dart';
import 'package:flutter/material.dart';
import '../api/api_patients.dart';
import '../api/api_spr.dart';
import '../data/data_patients.dart';
import '../data/data_spr_diagnoses.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../routes.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/patients_card_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';
import 'menu.dart';

class PagePatients extends StatefulWidget {
  final String title;

  const PagePatients({
    super.key,
    required this.title,
  });

  @override
  State<PagePatients> createState() => _PagePatientsListState();
}

class _PagePatientsListState extends State<PagePatients> {
  late Future<void> _future;

  /// API
  final ApiPatients _apiPatients = ApiPatients();
  final ApiSpr _apiSpr = ApiSpr();

  /// Данные
  late List<DataPatients> _thisData = [];
  late List<DataPatients> _thisDataFiltered = [];
  late List<DataSprDiagnoses> _dataSprDiagnoses;

  /// Параметры
  late int _role;
  late String _doctorsId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _doctorsId = await readSecureData(SecureKey.doctorsId);
    _thisData = await _apiPatients.get(doctorsId: _doctorsId);
    _dataSprDiagnoses = await _apiSpr.getDiagnoses();
    setState(() {
      _thisDataFiltered = _thisData;
    });
  }

  void _filter(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _thisDataFiltered = _thisData.where((patient) {
        return patient.lastName.toLowerCase().contains(_searchQuery) ||
            patient.firstName.toLowerCase().contains(_searchQuery) ||
            (patient.patronymic?.toLowerCase().contains(_searchQuery) ?? false) ||
            patient.email.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
    _filter(_searchQuery);
  }

  void _navigateAndRefresh(BuildContext context) async {
    await deleteSecureData(SecureKey.patientsId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagePatientEdit(
          title: widget.title,
          isEditForm: false,
        ),
      ),
    ).then((_) async {
      await _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: widget.title),
      endDrawer: MenuDrawer(),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return errorDataWidget(snapshot.error);
          }

          return GestureDetector(
            onTap: () {
              // Скрываем клавиатуру при касании пустого места
              FocusScope.of(context).unfocus();
            },
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: Padding(
                padding: paddingFormAll,
                child: Column(
                  children: [
                    // Поле поиска
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Поиск пациента...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              onChanged: _filter,
                            ),
                          ),
                          ButtonWidget(
                            labelText: '',
                            icon: Icons.add_circle_rounded,
                            onlyText: true,
                            listRoles: Roles.asDoctor,
                            role: _role,
                            onPressed: () {
                              _navigateAndRefresh(context);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Список пациентов
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _thisDataFiltered.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              title: PatientsCardWidget(
                                lastName: _thisDataFiltered[index].lastName,
                                firstName: _thisDataFiltered[index].firstName,
                                patronymic: _thisDataFiltered[index].patronymic,
                                gender: _thisDataFiltered[index].gender ?? '',
                                birthDate: _thisDataFiltered[index].birthDate,
                                invalid: _thisDataFiltered[index].invalid,
                                mkbCode: _thisDataFiltered[index].diag ?? '',
                                mkbName: (_thisDataFiltered[index].diag != null)
                                    ? _dataSprDiagnoses
                                        .firstWhere(
                                            (diagnoses) =>
                                                diagnoses.mkbCode ==
                                                _thisDataFiltered[index].diag,
                                            orElse: () => DataSprDiagnoses(
                                                mkbCode: '',
                                                mkbName: 'Не указан',
                                                id: '',
                                                synonym: ''))
                                        .mkbName
                                    : 'Не указан',
                              ),
                              onTap: () async {
                                await deleteSecureData(SecureKey.patientsId);
                                await saveSecureData(SecureKey.patientsId,
                                    _thisDataFiltered[index].id);
                                if (mounted) {
                                  Navigator.pushNamed(
                                          context, AppRoutes.patientMain)
                                      .then((_) async {
                                    await deleteSecureData(
                                        SecureKey.patientsId);
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
