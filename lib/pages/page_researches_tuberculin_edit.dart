import 'package:artrit/api/api_researches_tuberculin.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/data/data_researches_tuberculin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../data/data_spr_research_tuberculin_result.dart';
import '../data/data_spr_research_tuberculin_type.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/input_select.dart';
import '../widgets/input_select_date.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text_with_select.dart';

class PageResearchesTuberculinEdit extends StatefulWidget {
  final String title;
  final DataResearchesTuberculin? thisData;
  final bool isEditForm;
  final VoidCallback? onDataUpdated;

  const PageResearchesTuberculinEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
    required this.onDataUpdated,
  });

  @override
  State<PageResearchesTuberculinEdit> createState() => PageResearchesTuberculinEditState();
}

class PageResearchesTuberculinEditState extends State<PageResearchesTuberculinEdit> {
  late Future<void> _future;

  /// API
  final ApiResearchesTuberculin _api = ApiResearchesTuberculin();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprResearchTuberculinType> _dataSprResearchTuberculinType;
  late List<DataSprResearchTuberculinResult> _dataSprResearchTuberculinResult;
  List<String> _listSprResearchTuberculinType = [];
  List<String> _listSprResearchTuberculinResult = [];

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String? _date;
  int? _createDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _researchName;
  String? _resultName;
  double? _value;

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
    if (widget.isEditForm) {
      _recordId = widget.thisData!.id != null ? widget.thisData!.id! : '';
      _createDate = widget.thisData!.createDate;
      _date = widget.thisData!.date != null
          ? dateFormat(widget.thisData!.date!)
          : null;
      _value = widget.thisData!.value;
      _researchName = widget.thisData!.researchItem != null ? widget.thisData!.researchItem!.name : '';
      _resultName = widget.thisData!.result != null ? widget.thisData!.result!.name : '';
    }

    _dataSprResearchTuberculinType = await _apiSpr.getResearchTuberculosisType();
    _dataSprResearchTuberculinResult = await _apiSpr.getResearchTuberculosisResult();

    _listSprResearchTuberculinType = _dataSprResearchTuberculinType
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

    _listSprResearchTuberculinResult = _dataSprResearchTuberculinResult
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

    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    if (mounted) Navigator.pop(context);
  }


  Future<void> _request() async {
    if (_resultName == 'Отрицательный') _value = 0;
    DataResearchesTuberculin thisData = DataResearchesTuberculin(
        patientId: _patientsId,
        date: convertStrToDate(_date!),
        createDate: _createDate,
        value: _value,
        researchItemId: _dataSprResearchTuberculinType.firstWhereOrNull((e) => e.name == _researchName)?.id,
        resultId: _dataSprResearchTuberculinResult.firstWhereOrNull((e) => e.name == _resultName)?.id);

    widget.isEditForm
        ? await _api.put(recordId: _recordId, thisData: thisData)
        : await _api.post(thisData: thisData);
  }


    bool _areDifferent() {
      if (!widget.isEditForm || widget.thisData == null) {
        // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
        return _date != null
            || _researchName != null
            || _resultName != null
            || _value != null;
      }
      // Иначе Сравниваем поля
      final w = widget.thisData!;
      return w.date != convertStrToDate(_date ?? '')
      || w.researchItem!.name != _researchName
      || w.result!.name != _resultName
      || w.value != _value;
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
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            FormHeaderWidget(title: widget.title),
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
        InputSelectDate(
          labelText: 'Дата',
          fieldKey: _keys[Enum.date]!,
          value: _date,
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _date = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Исследование',
          fieldKey: _keys[Enum.researchName]!,
          value: _researchName,
          required: false,
          listValues: _listSprResearchTuberculinType,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _researchName = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Результат',
          fieldKey: _keys[Enum.resultName]!,
          value: _resultName,
          required: false,
          listValues: _listSprResearchTuberculinResult,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _resultName = value;
            });
          },
        ),
        if (_resultName != null && _resultName!.isNotEmpty && _resultName != 'Отрицательный')
        InputTextWithSelect(
          labelText: _resultName == 'Положительный' ? 'Папула' : _resultName ?? 'Значение',
          fieldKey: _keys[Enum.value]!,
          initialValue: _value,
          unitOptions: ['мм'],
          initialUnit: 'мм',
          required: true,
          min: 0.1,
          max: 300,
          errorText: 'Заполните поле',
          onChanged: (value) {
            setState(() {
              _value = value.value;
            });
          },
        ),
   ],
    );
  }
}
