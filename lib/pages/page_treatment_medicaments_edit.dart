import 'package:artrit/data/data_spr_item.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_treatment_medicaments.dart';
import '../data/data_result.dart';
import '../data/data_spr_drugs.dart';
import '../data/data_spr_treatment_drug_forms.dart';
import '../data/data_spr_treatment_drug_provision.dart';
import '../data/data_spr_treatment_drug_using_rate.dart';
import '../data/data_spr_treatment_drug_using_way.dart';
import '../data/data_spr_treatment_skipping_reasons.dart';
import '../data/data_spr_treatment_units.dart';
import '../data/data_treatment_medicaments.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/input_text.dart';
import '../widgets/show_dialog_delete.dart';
import '../widgets/show_message.dart';


class PageTreatmentMedicamentsEdit extends StatefulWidget {
  final String title;
  final DataTreatmentMedicaments? thisData;
  final bool isEditForm;

  const PageTreatmentMedicamentsEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
  });

  @override
  State<PageTreatmentMedicamentsEdit> createState() => _PageTreatmentMedicamentsEditState();
}

class _PageTreatmentMedicamentsEditState extends State<PageTreatmentMedicamentsEdit> {
  late Future<void> _future;
  /// API
  final ApiTreatmentMedicaments _api = ApiTreatmentMedicaments();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  late List<DataSprDrugs> _thisSprDataDrugs;
  late List<DataSprTreatmentDrugUsingWay> _thisSprDataTreatmentDrugUsingWay;
  late List<DataSprTreatmentSkippingReasons> _listSprDataTreatmentSkippingReasons;
  late List<DataSprTreatmentDrugForms> _listSprDataTreatmentDrugForms;
  late List<DataSprTreatmentDrugProvision> _listSprDataTreatmentDrugProvision;
  late List<DataSprTreatmentDrugUsingRate> _listSprDataTreatmentDrugUsingRate;
  late List<DataSprTreatmentUnits> _listSprDataSprTreatmentUnits = [];

    /// Параметры
  bool _isLoading = false;
  late int _role;
  late String _patientsId;
  late String _recordId;
  int? _creationDate = convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  String? _tnp;
  String? _mnn;
  String? _pv;
  String? _ei;
  String? _tlf;
  String? _dnp;
  String? _dop;
  bool? _toThisTime;
  double? _srd;
  String? _krat;
  String? _pop;
  String? _obesplek;
  List<Skipping> _skippings = [];



  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final _formDialogKey = GlobalKey<FormState>();
  final Map<Enum, GlobalKey<FormFieldState>> _keys = {
    for (var e in Enum.values) e: GlobalKey<FormFieldState>(),
  };
  final Map<EnumSkippings, GlobalKey<FormFieldState>> _keysSkippings = {
    for (var e in EnumSkippings.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _thisSprDataDrugs = await _apiSpr.getDrugs();
    _thisSprDataTreatmentDrugUsingWay = await _apiSpr.getTreatmentDrugUsingWay();
    _listSprDataTreatmentDrugForms = await _apiSpr.getTreatmentDrugForms ();
    _listSprDataTreatmentDrugProvision = await _apiSpr.getTreatmentDrugProvision();
    _listSprDataTreatmentDrugUsingRate = await _apiSpr.getTreatmentDrugUsingRate ();
    _listSprDataTreatmentSkippingReasons = await _apiSpr.getTreatmentSkippingReasons();

    if (widget.isEditForm) {
      _recordId = widget.thisData!.id!;
      _dnp = widget.thisData!.dnp != null ? convertTimestampToDate(widget.thisData!.dnp!) : null;
      _dop = widget.thisData!.dop != null && widget.thisData!.dop!.date != null && widget.thisData!.dop!.date.toString().isNotEmpty ? convertTimestampToDate(widget.thisData!.dop!.date!) : null;
      _toThisTime = widget.thisData!.dop != null && widget.thisData!.dop!.checkbox != null ? widget.thisData!.dop!.checkbox : null;
      _tnp = widget.thisData!.tnp;
      _tlf = widget.thisData!.tlf;
      _mnn = widget.thisData!.mnn;
      _obesplek = widget.thisData!.obesplek;
      _pv = widget.thisData!.pv;
      _ei = widget.thisData!.ei;
      _srd = widget.thisData!.srd;
      _krat = widget.thisData!.krat;
      _pop = widget.thisData!.pop;
      _creationDate = widget.thisData!.creationDate!;

      // Глубокая копия _skippings
      _skippings = widget.thisData!.skippings?.map((s) => Skipping(
        beginDate: s.beginDate,
        endDate: s.endDate,
        reasonName: s.reasonName,
        reasonId: s.reasonId,
        menuBeginDate: s.menuBeginDate,
        menuEndDate: s.menuEndDate,
      )).toList() ?? [];

      await _getUnitList(_getParametersId(_pv));
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

    DataResult3 result = await _request();

    setState(() {
      _isLoading = false;
    });

    if (!result.success) {
      ShowMessage.show(context: context, message: result.userMessage?.toString() ?? 'Неизвестная ошибка');
    } else {
      if (mounted) Navigator.pop(context);
    }
  }


  Future<DataResult3> _request() async {
    DataTreatmentMedicaments thisData = DataTreatmentMedicaments(
        tnp: _tnp,
        tlf: _tlf,
        mnn: _mnn,
        obesplek: _obesplek,
        pv: _pv,
        ei: _ei,
        dnp: convertToTimestamp(_dnp!),
        dop: Dop(date: _dop != null ? convertToTimestamp(_dop!) : null, checkbox: _toThisTime),
        srd: _srd,
        krat: _krat,
        skippings: _skippings,
        pop: _pop,
        creationDate: _creationDate);

    return widget.isEditForm
        ? await _api.put(patientsId: _patientsId, recordId: _recordId, thisData: thisData)
        : await _api.post(patientsId: _patientsId, thisData: thisData);

  }


  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _tnp != null ||
          _tlf != null ||
          (_mnn ?? '') != '' ||
          _obesplek != null ||
          _pv != null ||
          _ei != null ||
          _dnp != null ||
          _dop != null ||
          _srd != null ||
          _krat != null ||
          (_pop ?? '') != '' ||
          _toThisTime != null ||
          _skippings.isNotEmpty;
    }

    final w = widget.thisData!;
    // Сравниваем списки _skippings и w.skippings
    bool areSkippingsDifferent() {
      if ((_skippings.isEmpty && w.skippings == null) || (_skippings.isEmpty && w.skippings!.isEmpty)) return false; // Оба null — нет различий
      if (_skippings.isEmpty || w.skippings == null) return true; // Один null — есть различия
      if (_skippings.length != w.skippings!.length) return true; // Разная длина — есть различия

      // Сравниваем каждый элемент
      for (int i = 0; i < _skippings.length; i++) {
        final current = _skippings[i];
        final original = w.skippings![i];
        if (current.beginDate != original.beginDate ||
            current.endDate != original.endDate ||
            current.reasonName != original.reasonName ||
            current.reasonId != original.reasonId ||
            current.menuBeginDate != original.menuBeginDate ||
            current.menuEndDate != original.menuEndDate) {
          return true; // Найдено различие
        }
      }
      return false; // Списки идентичны
    }

    return _tnp != w.tnp ||
        _tlf != w.tlf ||
        (_mnn ?? '') != (w.mnn ?? '') ||
        _obesplek != w.obesplek ||
        _pv != w.pv ||
        _ei != w.ei ||
        _dnp != convertTimestampToDate(w.dnp!) ||
        _dop != (w.dop?.date != null ? convertTimestampToDate(w.dop!.date!) : null) ||
        _toThisTime != w.dop?.checkbox ||
        _srd != w.srd ||
        _krat != w.krat ||
        (_pop ?? '') != (w.pop ?? '') ||
        areSkippingsDifferent();
  }




  String? _getParametersId(String? pv) {
    if (pv == null || pv.isEmpty) return null;
    try {
      return _thisSprDataTreatmentDrugUsingWay.firstWhereOrNull((e) => e.name == pv)?.id;
    } catch (e) {
      return null;
    }
  }




  Future<void> _getUnitList(String? pvId) async {
    if (pvId != null && pvId.isNotEmpty) {
      _listSprDataSprTreatmentUnits= await _apiSpr.getTreatmentUnits(recordId: pvId);
    } else {
      _ei = null;
      _listSprDataSprTreatmentUnits = [];
    }
    setState(() {
    });
  }



  // Поиск минимальной даты
  DateTime? _getMinBeginDate(List<Skipping> skippings) {
    if (skippings.isEmpty) return null;
    return skippings.fold<DateTime?>(
      null,
          (earliest, skipping) {
        if (skipping.beginDate == null) return earliest;
        if (earliest == null || skipping.beginDate!.isBefore(earliest)) {
          return skipping.beginDate;
        }
        return earliest;
      },
    );
  }



  // Поиск максимальной даты
  DateTime? _getMaxEndDate(List<Skipping> skippings) {
    if (skippings.isEmpty) return null;
    return skippings.fold<DateTime?>(
      null,
          (later, skipping) {
        if (skipping.endDate == null) return later;
        if (later == null || skipping.endDate!.isAfter(later)) {
          return skipping.endDate;
        }
        return later;
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: getFormTitle(widget.isEditForm),
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () { onBack(context, (_areDifferent())); },
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
                          buildFormSkippings(),
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
        WidgetInputSelect(
          labelText: 'Название лекарства',
          fieldKey: _keys[Enum.tnp]!,
          allValues: _thisSprDataDrugs.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _tnp,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _tnp = value;
            });
          },
        ),
        InputText(
          labelText: 'МНН',
          fieldKey: _keys[Enum.mnn]!,
          value: _mnn,
          maxLength: 200,
          required: false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _mnn = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Форма выпуска',
          fieldKey: _keys[Enum.tlf]!,
          allValues: _listSprDataTreatmentDrugForms.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _tlf,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _tlf = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Путь введения',
          fieldKey: _keys[Enum.pv]!,
          allValues: _thisSprDataTreatmentDrugUsingWay.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _pv,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) async {
            setState(() {
              _pv = value;
              _ei = null;
              _listSprDataSprTreatmentUnits = [];
            });
            String? pvId = _getParametersId(_pv);
            await _getUnitList(pvId);
          },
        ),
        WidgetInputSelect(
          labelText: 'Единицы измерения',
          fieldKey: _keys[Enum.ei]!,
          allValues: _listSprDataSprTreatmentUnits.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _ei,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _ei = value;
            });
          },
        ),
        InputText(
          labelText: 'Средняя разовая доза',
          fieldKey: _keys[Enum.srd]!,
          value: _srd,
          required: true,
          keyboardType: TextInputType.number,
          min: 1,
          max: 3000000,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _srd = value.isNotEmpty ? double.parse(value) : null;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Кратность',
          fieldKey: _keys[Enum.krat]!,
          allValues: _listSprDataTreatmentDrugUsingRate.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _krat,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _krat = value;
            });
          },
        ),
        WidgetInputSelectDateTime(
          labelText: 'Дата начала приёма',
          fieldKey: _keys[Enum.dnp]!,
          value: _dnp,
          lastDateTime: _getMinBeginDate(_skippings) ?? (_dop != null
              ? convertStrToDate(_dop!)
              : null),
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _dnp = value;
            });
          },
        ),
        if (_toThisTime == null || !_toThisTime!)
          WidgetInputSelectDateTime(
          labelText: 'Дата окончания приёма',
          fieldKey: _keys[Enum.dop]!,
          value: _dop,
          firstDateTime: _getMaxEndDate(_skippings) ?? (_dnp != null
              ? convertStrToDate(_dnp!)
              : null),
          lastDateTime: getMoscowDateTime().add(Duration(days: 365 * 18)),
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _dop = value;
            });
          },
        ),
        InputCheckbox(
          fieldKey: _keys[Enum.toThisTime]!,
          labelText: 'По настоящее время',
          value: _toThisTime ?? false,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dop = null;
              _toThisTime = value;
            });
          },
        ),
        InputText(
          labelText: 'Причина окончания приёма',
          fieldKey: _keys[Enum.pop]!,
          value: _pop,
          maxLength: 200,
          required: _dop == null ? false : true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _pop = value;
            });
          },
        ),
        WidgetInputSelect(
          labelText: 'Обеспечение лекарствами',
          fieldKey: _keys[Enum.obesplek]!,
          allValues: _listSprDataTreatmentDrugProvision.map((e) => SprItem(id: e.name ?? '', name: e.name ?? '')).toList(),
          selectedValue: _obesplek,
          required: true,
          listRoles: Roles.asPatient,
          roleId: _role,
          onChanged: (value) {
            setState(() {
              _obesplek = value;
            });
          },
        ),
        SizedBox(height: 25),
        Row(
          children: [
            Text('ПРОПУСК ПРИЕМА ЛЕКАРСТВА', style: captionMenuTextStyle, textAlign: TextAlign.start,),
            ButtonWidget(
              labelText: '',
              icon: Icons.add_circle_rounded,
              onlyText: true,
              listRoles: Roles.asPatient,
              role: _role,
              onPressed: () {
                _showEditRecDialog(false);
              },
            ),
          ],
        ),
      ],
    );
  }



  Widget buildFormSkippings() {
    if (_skippings.isEmpty) {
      return SizedBox.shrink();
    }

    _skippings.sort((a, b) {
      if (a.beginDate == null && b.beginDate == null) {
        return 0; // Оба значения null, считаем их равными
      }
      if (a.beginDate == null) {
        return -1; // a.treatmentBeginDate null, считаем его меньше
      }
      if (b.beginDate == null) {
        return 1; // b.treatmentBeginDate null, считаем его больше
      }
      return a.beginDate!.compareTo(b.beginDate!);
    });

    return ListView.builder(
      shrinkWrap: true, // Для использования внутри другого прокручиваемого виджета
      physics: NeverScrollableScrollPhysics(), // Отключаем прокрутку, если внутри ScrollView
      itemCount: _skippings.length,
      itemBuilder: (context, index) {

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${index+1}) ', style: inputTextStyle,),
                Text(_skippings[index].beginDate != null ? dateFormat(_skippings[index].beginDate!) ?? '' : '', style: inputTextStyle,),
                Text(' - ', style: inputTextStyle,),
                Text(_skippings[index].endDate != null ? dateFormat(_skippings[index].endDate!) ?? '' : '', style: inputTextStyle,),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.blue),
                      onPressed: () {
                        _showEditRecDialog(true, index: index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
            Text(_skippings[index].reasonName != null ? _skippings[index].reasonName! : '', style: inputTextStyle,),
            SizedBox(height: 10.0,),
          ],
        );
      },
    );
  }





  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false, // Диалог не закроется при клике вне его
      builder: (BuildContext context) {
        return ShowDialogDelete(
          onConfirm: () {
            _skippings.removeAt(index);
            setState(() {});
          },
        );
      },
    );
  }



  void _showEditRecDialog(bool isEditForm, {int? index}) {
    DateTime? beginDate;
    DateTime? endDate;
    String? reasonId = '';

    if (isEditForm) {
      beginDate = _skippings[index!].beginDate != null ? _skippings[index].beginDate! : null;
      endDate = _skippings[index].endDate;
      reasonId = _skippings[index].reasonId ?? '';
    }
    showDialog(
        context: context,
        barrierDismissible: false, // Диалог не закроется при клике вне его
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext dialogContext, StateSetter dialogSetState) {
                return Form(
                  key: _formDialogKey,
                  child: AlertDialog(
                    title: Text(
                      getFormTitle(isEditForm),
                      style: formHeaderStyle,
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        // Чтобы высота AlertDialog зависела от содержимого окна, а не занимала всю высоту экрана
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          WidgetInputSelectDateTime(
                            labelText: 'Дата начала пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.beginDate]!,
                            value: beginDate != null ? dateFormat(beginDate!) : null,
                            //initialDate: beginDate ?? endDate,
                            firstDateTime: convertStrToDate(_dnp),
                            lastDateTime: endDate ?? convertStrToDate(_dop),
                            required: true,
                            listRoles: Roles.asPatient,
                            roleId: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                beginDate = convertStrToDate(value);
                              });
                            },
                          ),
                          WidgetInputSelectDateTime(
                            labelText: 'Дата окончания пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.endDate]!,
                            value: endDate != null ? dateFormat(endDate!) : null,
                            firstDateTime: beginDate ?? convertStrToDate(_dnp),
                            lastDateTime: convertStrToDate(_dop) ?? getMoscowDateTime().add(Duration(days: 365 * 18)),
                            required: true,
                            listRoles: Roles.asPatient,
                            roleId: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                endDate = convertStrToDate(value);
                              });
                            },
                          ),
                          WidgetInputSelect(
                            labelText: 'Причина пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.reasonName]!,
                            allValues: _listSprDataTreatmentSkippingReasons.map((e) => SprItem(id: e.id, name: e.name ?? '')).toList(),
                            selectedValue: reasonId,
                            required: true,
                            listRoles: Roles.asPatient,
                            roleId: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                reasonId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ButtonWidget(
                        labelText: 'Отмена',
                        onlyText: true,
                        dialogForm: true,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      SizedBox(width: 10,),
                      ButtonWidget(
                        labelText: 'Сохранить',
                        onlyText: true,
                        dialogForm: true,
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () async {
                          if (!_formDialogKey.currentState!.validate()) {
                            ShowMessage.show(context: context);
                          }
                          else {
                            if (isEditForm)
                            {
                              _skippings[index!].beginDate = beginDate;
                              _skippings[index].endDate = endDate;
                              _skippings[index].reasonId = reasonId;
                              _skippings[index].reasonName = _listSprDataTreatmentSkippingReasons.firstWhereOrNull((e) => e.id == reasonId)?.name;
                            }
                            else {
                              Skipping newSkipping = Skipping(
                                beginDate: beginDate,
                                endDate: endDate,
                                reasonName: _listSprDataTreatmentSkippingReasons.firstWhereOrNull((e) => e.id == reasonId)?.name,
                                reasonId: reasonId,
                                menuBeginDate: false,
                                menuEndDate: false,
                              );
                              _skippings.add(newSkipping);
                            }

                            Navigator.pop(dialogContext);
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
          );
        });
  }





}