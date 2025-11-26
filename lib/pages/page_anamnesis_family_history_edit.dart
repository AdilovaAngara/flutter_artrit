import 'package:artrit/api/api_anamnesis_family_history.dart';
import 'package:artrit/data/data_anamnesis_family_history.dart';
import 'package:artrit/data/data_spr_relatives.dart';
import 'package:artrit/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_multi_select.dart';
import '../widgets/input_switch.dart';

class PageAnamnesisFamilyHistoryEdit extends StatefulWidget {
  final String title;

  const PageAnamnesisFamilyHistoryEdit({
    super.key,
    required this.title
  });

  @override
  State<PageAnamnesisFamilyHistoryEdit> createState() => _PageAnamnesisFamilyHistoryEditState();
}

class _PageAnamnesisFamilyHistoryEditState extends State<PageAnamnesisFamilyHistoryEdit> {
  late Future<void> _future;
  /// API
  final ApiAnamnesisFamilyHistory _api = ApiAnamnesisFamilyHistory();
  final ApiSpr _apiSpr = ApiSpr();
  /// Данные
  late DataAnamnesisFamilyHistory _thisData;

  // Справочники
  late List<DataSprRelatives> _thisSprDataRelatives;
  List<String> _listSprRelatives= [];

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _patientsId;
  bool _radioart = false;
  bool _radiopsor = false;
  bool _radiokron = false;
  bool _radioyazkol = false;
  bool _radiobolbeh = false;
  bool _radiobouveit = false;
  bool _radiobobolrey = false;
  List<String> _valueart = [];
  List<String> _valuepsor = [];
  List<String> _valuekron = [];
  List<String> _valueyazkol = [];
  List<String> _valuebolbeh = [];
  List<String> _valuebouveit = [];
  List<String> _valuebobolrey = [];


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
    _thisData = await _api.get(patientsId: _patientsId);

    _radioart = getBoolValue(_thisData.radioart);
    _radiopsor = getBoolValue(_thisData.radiopsor);
    _radiokron = getBoolValue(_thisData.radiokron);
    _radioyazkol = getBoolValue(_thisData.radioyazkol);
    _radiobolbeh = getBoolValue(_thisData.radiobolbeh);
    _radiobouveit = getBoolValue(_thisData.radiobouveit);
    _radiobobolrey = getBoolValue(_thisData.radiobobolrey);
    _valueart = _thisData.valueart ?? [];
    _valuepsor = _thisData.valuepsor ?? [];
    _valuekron = _thisData.valuekron ?? [];
    _valueyazkol = _thisData.valueyazkol ?? [];
    _valuebolbeh = _thisData.valuebolbeh ?? [];
    _valuebobolrey = _thisData.valuebobolrey ?? [];
    _valuebouveit = _thisData.valuebouveit ?? [];

    _thisSprDataRelatives = await _apiSpr.getRelatives();

    _listSprRelatives = _thisSprDataRelatives
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

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
    DataAnamnesisFamilyHistory thisData = DataAnamnesisFamilyHistory(
        radioart: getRadioValue(_radioart),
        radiopsor: getRadioValue(_radiopsor),
        radiokron: getRadioValue(_radiokron),
        radioyazkol: getRadioValue(_radioyazkol),
        radiobolbeh: getRadioValue(_radiobolbeh),
        radiobouveit: getRadioValue(_radiobouveit),
        radiobobolrey: getRadioValue(_radiobobolrey),

        valueart: _radioart ? _valueart : [],
        valuepsor: _radiopsor ? _valuepsor : [],
        valuekron: _radiokron ? _valuekron : [],
        valueyazkol: _radioyazkol ? _valueyazkol : [],
        valuebolbeh: _radiobolbeh ? _valuebolbeh : [],
        valuebouveit: _radiobouveit ? _valuebouveit : [],
        valuebobolrey: _radiobobolrey ? _valuebobolrey : []);
    await _api.put(patientsId: _patientsId, thisData: thisData);
  }


  bool _areDifferent() {
    // Сравниваем поля
    final w = _thisData;
    return _radioart != getBoolValue(w.radioart) ||
        _radiopsor != getBoolValue(w.radiopsor) ||
        _radiokron != getBoolValue(w.radiokron) ||
        _radioyazkol != getBoolValue(w.radioyazkol) ||
        _radiobolbeh != getBoolValue(w.radiobolbeh) ||
        _radiobouveit != getBoolValue(w.radiobouveit) ||
        _radiobobolrey != getBoolValue(w.radiobobolrey) ||
        !listEquals(_valueart..sort(), w.valueart ?? []..sort()) ||
        !listEquals(_valuepsor..sort(), w.valuepsor ?? []..sort()) ||
        !listEquals(_valuekron..sort(), w.valuekron ?? []..sort()) ||
        !listEquals(_valueyazkol..sort(), w.valueyazkol ?? []..sort()) ||
        !listEquals(_valuebolbeh..sort(), w.valuebolbeh ?? []..sort()) ||
        !listEquals(_valuebobolrey..sort(), w.valuebobolrey ?? []..sort()) ||
        !listEquals(_valuebouveit..sort(), w.valuebouveit ?? []..sort());
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
              padding: paddingForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(top: 10.0),
                      child: buildForm(),
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
        _buildGroup(
          label: 'Артрит',
          switchKey: Enum.radioart,
          switchValue: _radioart,
          multiSelectKey: Enum.valueart,
          multiSelectValue: _valueart,
          onSwitchChanged: (value) => setState(() => _radioart = value),
          onMultiSelectChanged: (value) => setState(() => _valueart = value),
        ),
        _buildGroup(
          label: 'Псориаз',
          switchKey: Enum.radiopsor,
          switchValue: _radiopsor,
          multiSelectKey: Enum.valuepsor,
          multiSelectValue: _valuepsor,
          onSwitchChanged: (value) => setState(() => _radiopsor = value),
          onMultiSelectChanged: (value) => setState(() => _valuepsor = value),
        ),
        _buildGroup(
          label: 'Болезнь Крона',
          switchKey: Enum.radiokron,
          switchValue: _radiokron,
          multiSelectKey: Enum.valuekron,
          multiSelectValue: _valuekron,
          onSwitchChanged: (value) => setState(() => _radiokron = value),
          onMultiSelectChanged: (value) => setState(() => _valuekron = value),
        ),
        _buildGroup(
          label: 'Язвенный колит',
          switchKey: Enum.radioyazkol,
          switchValue: _radioyazkol,
          multiSelectKey: Enum.valueyazkol,
          multiSelectValue: _valueyazkol,
          onSwitchChanged: (value) => setState(() => _radioyazkol = value),
          onMultiSelectChanged: (value) => setState(() => _valueyazkol = value),
        ),
        _buildGroup(
          label: 'Болезнь Бехтерева',
          switchKey: Enum.radiobolbeh,
          switchValue: _radiobolbeh,
          multiSelectKey: Enum.valuebolbeh,
          multiSelectValue: _valuebolbeh,
          onSwitchChanged: (value) => setState(() => _radiobolbeh = value),
          onMultiSelectChanged: (value) => setState(() => _valuebolbeh = value),
        ),
        _buildGroup(
          label: 'Увеит',
          switchKey: Enum.radiobouveit,
          switchValue: _radiobouveit,
          multiSelectKey: Enum.valuebouveit,
          multiSelectValue: _valuebouveit,
          onSwitchChanged: (value) => setState(() => _radiobouveit = value),
          onMultiSelectChanged: (value) => setState(() => _valuebouveit = value),
        ),
        _buildGroup(
          label: 'Болезнь Рейтера',
          switchKey: Enum.radiobobolrey,
          switchValue: _radiobobolrey,
          multiSelectKey: Enum.valuebobolrey,
          multiSelectValue: _valuebobolrey,
          onSwitchChanged: (value) => setState(() => _radiobobolrey = value),
          onMultiSelectChanged: (value) => setState(() => _valuebobolrey = value),
        ),
      ],
    );
  }

// Метод для создания группы в контейнере
  Widget _buildGroup({
    required String label,
    required Enum switchKey,
    required bool switchValue,
    required Enum multiSelectKey,
    required List<String> multiSelectValue,
    required ValueChanged<bool> onSwitchChanged,
    required ValueChanged<List<String>> onMultiSelectChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0), // Отступ между группами
      padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0), // Внутренний отступ
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0), // Закруглённые углы
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем контейнер на всю ширину
        children: [
          InputSwitch(
            labelText: label,
            fieldKey: _keys[switchKey]!,
            value: switchValue,
            listRoles: Roles.asPatient,
            role: _role,
            onChanged: onSwitchChanged,
          ),
          if (switchValue)
            InputMultiSelect(
              labelText: 'Родственники',
              fieldKey: _keys[multiSelectKey]!,
              listSelectValue: multiSelectValue,
              required: true,
              listValues: _listSprRelatives,
              listRoles: Roles.asPatient,
              role: _role,
              onChanged: onMultiSelectChanged,
            ),
        ],
      ),
    );
  }





}
