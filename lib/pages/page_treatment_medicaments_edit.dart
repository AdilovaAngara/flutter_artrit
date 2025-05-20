import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../api/api_spr.dart';
import '../api/api_treatment_medicaments.dart';
import '../data/data_result.dart';
import '../data/data_spr_drugs.dart';
import '../data/data_spr_treatment_drug_using_way.dart';
import '../data/data_spr_treatment_skipping_reasons.dart';
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
import '../widgets/input_select.dart';
import '../widgets/input_select_date.dart';
import '../widgets/input_text.dart';
import '../widgets/show_dialog_delete.dart';
import '../widgets/show_message.dart';


class PageTreatmentMedicamentsEdit extends StatefulWidget {
  final String title;
  final DataTreatmentMedicaments? thisData;
  final bool isEditForm;
  final VoidCallback? onDataUpdated;

  const PageTreatmentMedicamentsEdit({
    super.key,
    required this.title,
    required this.thisData,
    required this.isEditForm,
    required this.onDataUpdated,
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
  late List<String> _listSprDrugs;
  late List<String> _listSprTreatmentDrugForms;
  late List<String> _listSprTreatmentDrugProvision;
  late List<String> _listSprTreatmentDrugUsingRate;
  late List<String> _listSprTreatmentDrugUsingWay;
  late List<String> _listSprTreatmentSkippingReasons;
  List<String> _listUnits = [];

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
    _listSprDrugs = _thisSprDataDrugs
        .map((e) => e.name ?? '')
        .toList()
      ..sort();
    _thisSprDataTreatmentDrugUsingWay = await _apiSpr.getTreatmentDrugUsingWay();
    _listSprTreatmentDrugForms = await _apiSpr.getTreatmentDrugForms ();
    _listSprTreatmentDrugProvision = await _apiSpr.getTreatmentDrugProvision();
    _listSprTreatmentDrugUsingRate = await _apiSpr.getTreatmentDrugUsingRate ();

    _listSprTreatmentDrugUsingWay = _thisSprDataTreatmentDrugUsingWay
        .map((e) => e.name ?? '')
        .toList()
      ..sort();
    _listSprDataTreatmentSkippingReasons = await _apiSpr.getTreatmentSkippingReasons();
    _listSprTreatmentSkippingReasons = _listSprDataTreatmentSkippingReasons
        .map((e) => e.name ?? '')
        .toList()
      ..sort();

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
      widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
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
      if (_skippings.isEmpty && w.skippings == null) return false; // Оба null — нет различий
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
      _listUnits= await _apiSpr.getTreatmentUnits(recordId: pvId);
      //_ei = _listUnits.isNotEmpty ? _listUnits[0] : null;
    } else {
      _ei = null;
      _listUnits = [];
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
        InputSelect(
          labelText: 'Название лекарства',
          fieldKey: _keys[Enum.tnp]!,
          value: _tnp,
          required: true,
          listValues: _listSprDrugs,
          listRoles: Roles.asPatient,
          role: _role,
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
        InputSelect(
          labelText: 'Форма выпуска',
          fieldKey: _keys[Enum.tlf]!,
          value: _tlf,
          required: true,
          listValues: _listSprTreatmentDrugForms,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _tlf = value;
            });
          },
        ),
        InputSelect(
          labelText: 'Путь введения',
          fieldKey: _keys[Enum.pv]!,
          value: _pv,
          required: true,
          listValues: _listSprTreatmentDrugUsingWay,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) async {
            setState(() {
              _pv = value;
              _ei = null;
              _listUnits = [];
            });
            String? pvId = _getParametersId(_pv);
            await _getUnitList(pvId);
          },
        ),
        InputSelect(
          labelText: 'Единицы измерения',
          fieldKey: _keys[Enum.ei]!,
          value: _ei,
          required: true,
          listValues: _listUnits,
          listRoles: Roles.asPatient,
          role: _role,
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
        InputSelect(
          labelText: 'Кратность',
          fieldKey: _keys[Enum.krat]!,
          value: _krat,
          required: true,
          listValues: _listSprTreatmentDrugUsingRate,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _krat = value;
            });
          },
        ),
        InputSelectDate(
          labelText: 'Дата начала приёма',
          fieldKey: _keys[Enum.dnp]!,
          value: _dnp,
          lastDate: _getMinBeginDate(_skippings) ?? (_dop != null
              ? converStrToDate(_dop!)
              : null),
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _dnp = value;
            });
          },
        ),
        if (_toThisTime == null || !_toThisTime!)
        InputSelectDate(
          labelText: 'Дата окончания приёма',
          fieldKey: _keys[Enum.dop]!,
          value: _dop,
          firstDate: _getMaxEndDate(_skippings) ?? (_dnp != null
              ? converStrToDate(_dnp!)
              : null),
          lastDate: getMoscowDateTime().add(Duration(days: 365 * 18)),
          required: true,
          listRoles: Roles.asPatient,
          role: _role,
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
        InputSelect(
          labelText: 'Обеспечение лекарствами',
          fieldKey: _keys[Enum.obesplek]!,
          value: _obesplek,
          required: true,
          listValues: _listSprTreatmentDrugProvision,
          listRoles: Roles.asPatient,
          role: _role,
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
    String reasonName = '';

    if (isEditForm) {
      beginDate = _skippings[index!].beginDate != null ? _skippings[index].beginDate! : null;
      endDate = _skippings[index].endDate;
      reasonName = _skippings[index].reasonName ?? '';
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
                          InputSelectDate(
                            labelText: 'Дата начала пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.beginDate]!,
                            value: beginDate != null ? dateFormat(beginDate!) : null,
                            //initialDate: beginDate ?? endDate,
                            firstDate: converStrToDate(_dnp),
                            lastDate: endDate ?? converStrToDate(_dop),
                            required: true,
                            listRoles: Roles.asPatient,
                            role: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                beginDate = converStrToDate(value);
                              });
                            },
                          ),
                          InputSelectDate(
                            labelText: 'Дата окончания пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.endDate]!,
                            value: endDate != null ? dateFormat(endDate!) : null,
                            firstDate: beginDate ?? converStrToDate(_dnp),
                            lastDate: converStrToDate(_dop) ?? getMoscowDateTime().add(Duration(days: 365 * 18)),
                            required: true,
                            listRoles: Roles.asPatient,
                            role: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                endDate = converStrToDate(value);
                              });
                            },
                          ),
                          InputSelect(
                            labelText: 'Причина пропуска',
                            fieldKey: _keysSkippings[EnumSkippings.reasonName]!,
                            value: reasonName,
                            required: true,
                            listValues: _listSprTreatmentSkippingReasons,
                            listRoles: Roles.asPatient,
                            role: _role,
                            onChanged: (value) {
                              dialogSetState(() {
                                reasonName = value;
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
                              _skippings[index].reasonName = reasonName;
                              _skippings[index].reasonId = _listSprDataTreatmentSkippingReasons.firstWhereOrNull((e) => e.name == reasonName)?.id;
                            }
                            else {
                              Skipping newSkipping = Skipping(
                                beginDate: beginDate,
                                endDate: endDate,
                                reasonName: reasonName,
                                reasonId: _listSprDataTreatmentSkippingReasons.firstWhereOrNull((e) => e.name == reasonName)?.id,
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