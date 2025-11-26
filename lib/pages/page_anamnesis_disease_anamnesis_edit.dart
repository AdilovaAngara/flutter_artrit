import 'package:artrit/api/api_anamnesis_disease_anamnesis.dart';
import 'package:artrit/data/data_anamnesis_disease_anamnesis.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_select_date.dart';

class PageAnamnesisDiseaseAnamnesisEdit extends StatefulWidget {
  final String title;

  const PageAnamnesisDiseaseAnamnesisEdit({
    super.key,
    required this.title
  });

  @override
  State<PageAnamnesisDiseaseAnamnesisEdit> createState() =>
      _PageAnamnesisDiseaseAnamnesisEditState();
}

class _PageAnamnesisDiseaseAnamnesisEditState
    extends State<PageAnamnesisDiseaseAnamnesisEdit> {
  late Future<void> _future;

  /// API
  final ApiAnamnesisDiseaseAnamnesis _api = ApiAnamnesisDiseaseAnamnesis();

  /// Данные
  late DataAnamnesisDiseaseAnamnesis? _thisData;

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _patientsId;
  String? _dateDisease;
  String? _dateDiagnosis;

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
    _patientsId = (await readSecureData(SecureKey.patientsId));
    _thisData = await _api.get(patientsId: _patientsId);
    _dateDisease = convertTimestampToDate(_thisData?.dateDisease);
    _dateDiagnosis = convertTimestampToDate(_thisData?.dateDiagnosis);
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _request() async {
    DataAnamnesisDiseaseAnamnesis thisData = DataAnamnesisDiseaseAnamnesis(
        patientsId: _patientsId,
        dateDisease: convertToTimestamp(_dateDisease),
        dateDiagnosis: convertToTimestamp(_dateDiagnosis));
    _api.put(patientsId: _patientsId, thisData: thisData);
  }

  bool _areDifferent() {
    // Сравниваем поля
    final w = _thisData;
    return _dateDisease != convertTimestampToDate(w?.dateDisease) ||
        _dateDiagnosis != convertTimestampToDate(w?.dateDiagnosis);
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      //padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 10.0),
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

  Widget buildForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputSelectDate(
          labelText: 'Дата появления первых симптомов, жалоб',
          fieldKey: _keys[Enum.dateDisease]!,
          value: _dateDisease,
          initialDate: _dateDisease != null
              ? convertStrToDate(_dateDisease!)
              : _dateDiagnosis != null
                  ? convertStrToDate(_dateDiagnosis!)
                  : null,
          lastDate:
              _dateDiagnosis != null ? convertStrToDate(_dateDiagnosis!) : null,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dateDisease = value;
            });
          },
        ),
        InputSelectDate(
          labelText: 'Дата постановки диагноза',
          fieldKey: _keys[Enum.dateDiagnosis]!,
          value: _dateDiagnosis,
          firstDate:
              _dateDisease != null ? convertStrToDate(_dateDisease!) : null,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dateDiagnosis = value;
            });
          },
        ),
      ],
    );
  }
}
