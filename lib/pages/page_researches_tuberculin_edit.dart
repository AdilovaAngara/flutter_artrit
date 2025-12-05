import 'package:artrit/api/api_researches_tuberculin.dart';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/data/data_researches_tuberculin.dart';
import 'package:artrit/data/data_spr_item.dart';
import 'package:flutter/material.dart';
import '../data/data_spr_research_tuberculin_result.dart';
import '../data/data_spr_research_tuberculin_type.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text_with_select.dart';

class PageResearchesTuberculinEdit extends StatefulWidget {
  final String title;
  final DataResearchesTuberculin? thisData;
  final bool isEditForm;

  const PageResearchesTuberculinEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
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

  /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  String? _date;
  int? _createDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _researchItemId;
  String? _resultId;
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
      _researchItemId = widget.thisData!.researchItem != null ? widget.thisData!.researchItem!.id : '';
      _resultId = widget.thisData!.result != null ? widget.thisData!.result!.id : '';
    }

    _dataSprResearchTuberculinType = await _apiSpr.getResearchTuberculosisType();
    _dataSprResearchTuberculinResult = await _apiSpr.getResearchTuberculosisResult();
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

    if (mounted) Navigator.pop(context);
  }


  Future<void> _request() async {
    if (_resultId == '45ecc39c-eab0-4565-9437-adb1c6706069') _value = 0; // Отрицательный
    DataResearchesTuberculin thisData = DataResearchesTuberculin(
        patientId: _patientsId,
        date: convertStrToDate(_date!),
        createDate: _createDate,
        value: _value,
        researchItemId: _researchItemId,
        resultId: _resultId);

    widget.isEditForm
        ? await _api.put(recordId: _recordId, thisData: thisData)
        : await _api.post(thisData: thisData);
  }


    bool _areDifferent() {
      if (!widget.isEditForm || widget.thisData == null) {
        // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
        return _date != null
            || _researchItemId != null
            || _resultId != null
            || _value != null;
      }
      // Иначе Сравниваем поля
      final w = widget.thisData!;
      return w.date != convertStrToDate(_date ?? '')
      || w.researchItem!.id != _researchItemId
      || w.result!.id != _resultId
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
        WidgetInputSelectDateTime(
          labelText: 'Дата',
          fieldKey: _keys[Enum.date]!,
          value: _date,
          lastDateTime: getMoscowDateTime(),
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _date = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Исследование',
          fieldKey: _keys[Enum.researchName]!,
          allValues: _dataSprResearchTuberculinType.map((e) => SprItem(id: e.id, name: e.name ?? '')).toList(),
          selectedValue: _researchItemId,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _researchItemId = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Результат',
          fieldKey: _keys[Enum.resultName]!,
          allValues: _dataSprResearchTuberculinResult.map((e) => SprItem(id: e.id, name: e.name ?? '')).toList(),
          selectedValue: _resultId,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _resultId = value;
            });
          },
        ),
        if (_resultId != null && _resultId!.isNotEmpty && _resultId != '45ecc39c-eab0-4565-9437-adb1c6706069')
        InputTextWithSelect(
          labelText: _resultId == 'e5579cf3-c9d8-4062-ac2f-6e32e3a7aeb4' ? 'Гиперемия' : 'Папула',
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
