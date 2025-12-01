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
    _dataSprDiagnoses= await _apiSpr.getDiagnoses();
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
            (patient.patronymic?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
    if (mounted) {
      setState(() {});
    }
  }



  void _navigateAndRefresh(BuildContext context) async {
    await deleteSecureData(SecureKey.patientsId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          PagePatientEdit(
              title: widget.title,
            isEditForm: false,
          ),),
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
                                    ? _dataSprDiagnoses.firstWhere(
                                        (diagnoses) =>
                                    diagnoses.mkbCode == _thisDataFiltered[index].diag,
                                    orElse: () => DataSprDiagnoses(mkbCode: '', mkbName: 'Не указан', id: '', synonym: ''))
                                    .mkbName
                                    : 'Не указан',
                              ),
                              onTap: () async {
                                await deleteSecureData(SecureKey.patientsId);
                                await saveSecureData(SecureKey.patientsId, _thisDataFiltered[index].id);
                                if (mounted) {
                                  Navigator.pushNamed(context, AppRoutes.patientMain);
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


//
//
//
//
// import 'package:flutter/material.dart';
// import '../api/api_patients.dart';
// import '../api/api_spr.dart';
// import '../data/data_patients.dart';
// import '../data/data_spr_diagnoses.dart';
// import '../routes.dart';
// import '../secure_storage.dart';
// import '../widget_another/patients_card_widget.dart';
// import '../widgets/app_bar_widget.dart';
// import '../widgets/list_tile_widget.dart';
// import 'menu.dart';
//
// class PagePatients extends StatefulWidget {
//   const PagePatients({super.key});
//
//   @override
//   State<PagePatients> createState() => _PagePatientsListState();
// }
//
// class _PagePatientsListState extends State<PagePatients> {
//   late Future<void> _future;
//   final ApiPatients _apiPatients = ApiPatients();
//   final ApiSpr _apiSpr = ApiSpr();
//
//   late List<DataPatients> _thisData = [];
//   late List<DataPatients> _filteredData = [];
//   late List<DataSprDiagnoses> _dataSprDiagnoses = [];
//   late String _doctorsId = '';
//   String _searchQuery = '';
//
//   // Фильтры
//   bool? _invalidFilter;
//   int? _ageFrom;
//   int? _ageTo;
//   String? _selectedDiagnosis;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = _loadData();
//   }
//
//   Future<void> _loadData() async {
//     _doctorsId = (await readSecureData('doctorsId'))!;
//     final thisData = await _apiPatients.get(doctorsId: _doctorsId);
//     final dataSprDiagnoses = await _apiSpr.getDiagnoses();
//     setState(() {
//       _thisData = thisData;
//       _filteredData = thisData;
//       _dataSprDiagnoses = dataSprDiagnoses;
//     });
//   }
//
//   void _filterPatients() {
//     setState(() {
//       _filteredData = _thisData.where((patient) {
//         bool matchesSearch = patient.lastName.toLowerCase().contains(_searchQuery) ||
//             patient.firstName.toLowerCase().contains(_searchQuery) ||
//             (patient.patronymic?.toLowerCase().contains(_searchQuery) ?? false);
//
//         bool matchesInvalid = _invalidFilter == null || patient.invalid == _invalidFilter;
//
//         bool matchesAge = true;
//         if (_ageFrom != null || _ageTo != null) {
//           int age = DateTime.now().year - int.parse(patient.birthDate.toString().split('-')[0]);
//           matchesAge = (_ageFrom == null || age >= _ageFrom!) && (_ageTo == null || age <= _ageTo!);
//         }
//
//         bool matchesDiagnosis = _selectedDiagnosis == null || patient.diag == _selectedDiagnosis;
//
//         return matchesSearch && matchesInvalid && matchesAge && matchesDiagnosis;
//       }).toList();
//     });
//   }
//
//   void _resetFilters() {
//     setState(() {
//       _searchQuery = '';
//       _invalidFilter = null;
//       _ageFrom = null;
//       _ageTo = null;
//       _selectedDiagnosis = null;
//       _filteredData = _thisData;
//     });
//   }
//
//   Future<void> _refreshData() async {
//     await _loadData();
//     if (mounted) {
//       setState(() {
//         _future = _loadData();
//       });
//     }
//   }
//
//   void _showFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         bool? tempInvalid = _invalidFilter;
//         int? tempAgeFrom = _ageFrom;
//         int? tempAgeTo = _ageTo;
//         String? tempDiagnosis = _selectedDiagnosis;
//
//         return AlertDialog(
//           title: Text('Фильтры', style: formHeaderStyle,),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Инвалидность
//               DropdownButtonFormField<bool>(
//                 value: tempInvalid,
//                 decoration: InputDecoration(labelText: 'Инвалидность'),
//                 items: [
//                   DropdownMenuItem(value: null, child: Text('Не учитывать')),
//                   DropdownMenuItem(value: true, child: Text('Да')),
//                   DropdownMenuItem(value: false, child: Text('Нет')),
//                 ],
//                 onChanged: (value) => tempInvalid = value,
//               ),
//
//               // Возраст
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: 'Возраст от'),
//                       keyboardType: TextInputType.number,
//                       initialValue: tempAgeFrom?.toString(),
//                       onChanged: (value) => tempAgeFrom = int.tryParse(value),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: 'до'),
//                       keyboardType: TextInputType.number,
//                       initialValue: tempAgeTo?.toString(),
//                       onChanged: (value) => tempAgeTo = int.tryParse(value),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Диагноз
//               DropdownButtonFormField<String>(
//                 value: tempDiagnosis,
//                 decoration: InputDecoration(labelText: 'Диагноз'),
//                 items: [
//                   DropdownMenuItem(value: null, child: Text('Любой')),
//                   ..._dataSprDiagnoses.map((d) => DropdownMenuItem(
//                     value: d.mkbCode,
//                     child: Text(d.mkbName),
//                   )),
//                 ],
//                 onChanged: (value) => tempDiagnosis = value,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _resetFilters();
//                 Navigator.pop(context);
//               },
//               child: Text('Сброс'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _invalidFilter = tempInvalid;
//                   _ageFrom = tempAgeFrom;
//                   _ageTo = tempAgeTo;
//                   _selectedDiagnosis = tempDiagnosis;
//                 });
//                 _filterPatients();
//                 Navigator.pop(context);
//               },
//               child: Text('Применить'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBarWidget(title: 'Пациенты'),
//       endDrawer: MenuDrawer(),
//       body: FutureBuilder(
//         future: _future,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//                         return errorDataWidget(snapshot.error);
//           }
//
//           return RefreshIndicator(
//             onRefresh: _refreshData,
//             child: Padding(
//               padding: const EdgeInsets.all(15.0),
//               child: Column(
//                 children: [
//                   // Поиск + Фильтр
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Поиск пациента...',
//                             prefixIcon: Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               _searchQuery = value.toLowerCase();
//                               _filterPatients();
//                             });
//                           },
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       IconButton(
//                         icon: Icon(Icons.filter_list),
//                         onPressed: _showFilterDialog,
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: 10),
//
//                   // Список пациентов
//                   Expanded(
//                     child: ListView.builder(
//                       padding: EdgeInsets.zero,
//                       itemCount: _filteredData.length,
//                       itemBuilder: (context, index) {
//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: ListTile(
//                             tileColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                             ),
//                             title: ListTileWidget(
//                               widgetSubtitle: PatientsCardWidget(
//                                 lastName: _filteredData[index].lastName,
//                                 firstName: _filteredData[index].firstName,
//                                 patronymic: _filteredData[index].patronymic,
//                                 gender: _filteredData[index].gender ?? '',
//                                 birthDate: _filteredData[index].birthDate,
//                                 invalid: _filteredData[index].invalid,
//                                 mkbCode: _filteredData[index].diag ?? '',
//                                 mkbName: (_filteredData[index].diag != null)
//                                     ? _dataSprDiagnoses.firstWhere(
//                                         (diagnoses) =>
//                                     diagnoses.mkbCode == _filteredData[index].diag,
//                                     orElse: () => DataSprDiagnoses(mkbCode: '', mkbName: 'Не указан', id: '', synonym: ''))
//                                     .mkbName
//                                     : 'Не указан',
//                               ),
//                               pageName: AppRoutes.patient,
//                               onTap: () {},
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
