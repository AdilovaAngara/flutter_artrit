import 'dart:convert';
import 'package:artrit/api/api_spr.dart';
import 'package:artrit/pages/page_inspections_pain.dart';
import 'package:artrit/pages/page_inspections_uveit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/api_inspections.dart';
import '../data/data_inspections.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../widget_another/form_header_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/list_tile_color_widget.dart';
import '../widgets/input_select_date_time.dart';
import '../widgets/input_select.dart';
import '../widgets/button_widget.dart';
import '../widgets/input_text.dart';
import 'page_inspections_angles.dart';
import 'page_inspections_joint_syndrome.dart';
import 'page_inspections_limph.dart';
import 'page_inspections_rash.dart';

class PageInspectionsMainEdit extends StatefulWidget {
  final String title;
  final DataInspections? thisData;
  final bool isEditForm;
  final VoidCallback? onDataUpdated;

  const PageInspectionsMainEdit({
    super.key,
    required this.title,
    this.thisData,
    required this.isEditForm,
    required this.onDataUpdated,
  });

  @override
  State<PageInspectionsMainEdit> createState() =>
      PageInspectionsMainEditState();
}

class PageInspectionsMainEditState extends State<PageInspectionsMainEdit> {
  late Future<void> _future;

  /// API
  final ApiInspections _api = ApiInspections();
  final ApiSpr _apiSpr = ApiSpr();

  // Справочники
  List<double> _listSprTemperature = [];

  /// Параметры
  bool _isLoading = false; // Флаг загрузки
  late int _role;
  late String _patientsId;
  String? _recordId;
  String? _date = dateTimeFormat(getMoscowDateTime());
  int? _creationDate =
  convertToTimestamp(dateTimeFormat(getMoscowDateTime()));
  double? _tem;
  int _sis = 0;
  int _dia = 0;
  int? _chss;
  int? _utscov;
  int _ocbol = 0;
  int _sipCount = 0;
  String _siplist = '[]';

  // Не используется
  List<Syssind> _listSyssindNotUse1 = [
    Syssind(isActive: false, name: 'Туловище'),
    Syssind(isActive: false, name: 'Голова + шея'),
    Syssind(isActive: false, name: 'Правая нога'),
    Syssind(isActive: false, name: 'Правая рука'),
    Syssind(isActive: false, name: 'Бедро'),
    Syssind(isActive: false, name: 'Левая рука'),
    Syssind(isActive: false, name: 'Левая нога'),
    Syssind(isActive: false, name: 'Бедро(Сзади)'),
    Syssind(isActive: false, name: 'Спина'),
    Syssind(isActive: false)
  ];
  List<Syssind> _listSyssind2 = [
    Syssind(isActive: false, name: 'шейный левый'),
    Syssind(isActive: false, name: 'шейный правый'),
    Syssind(isActive: false, name: 'подмышечный левый'),
    Syssind(isActive: false, name: 'подмышечный правый'),
    Syssind(isActive: false, name: 'локтевой левый'),
    Syssind(isActive: false, name: 'локтевой правый'),
    Syssind(isActive: false, name: 'паховый левый'),
    Syssind(isActive: false, name: 'паховый правый'),
    Syssind(isActive: false, name: 'подколенный левый'),
    Syssind(isActive: false, name: 'подколенный правый')
  ];
  List<Joint> _joints = [];
  Uveit? _uveit;

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
      _recordId = widget.thisData!.id!;
      _date = convertTimestampToDateTime(widget.thisData!.date);
      _creationDate = widget.thisData!.creationDate;
      _tem = widget.thisData?.tem;
      _sis = widget.thisData?.ardav.sis ?? _sis;
      _dia = widget.thisData?.ardav.dia ?? _dia;
      _chss = widget.thisData?.chss;
      _utscov = widget.thisData?.utscov ?? _utscov;
      _ocbol = widget.thisData?.ocbol ?? _ocbol;
      _sipCount = widget.thisData?.sip ?? 0;
      _siplist = widget.thisData?.siplist ?? _siplist;
      //_listSyssind1 = widget.thisData?.syssind1 ?? _listSyssind1;
      _listSyssind2 = widget.thisData?.syssind2 ?? _listSyssind2;
      _joints = widget.thisData!.joints;
      _uveit = widget.thisData!.uveit;
    }

    _listSprTemperature = await _apiSpr.getTemperature();
    setState(() {});
  }




  Future<bool> _changeData(bool closeForm) async {
    if (!_formKey.currentState!.validate()) {
      showTopBanner(context: context);
      return false;
    }

    setState(() {
      _isLoading = true;
    });

    await _request();

    setState(() {
      _isLoading = false;
    });

    widget.onDataUpdated?.call(); // ✅ Вызываем колбэк
    if (mounted && closeForm) Navigator.pop(context);
    return true;
  }

  Future<void> _request() async {
    DataInspections thisData = DataInspections(
      id: widget.isEditForm ? _recordId : null,
      patientsId: _patientsId,
      date: convertToTimestamp(_date),
      tem: _tem,
      ardav: Ardav(
        sis: _sis,
        dia: _dia,
      ),
      chss: _chss,
      utscov: _utscov,
      ocbol: _ocbol,
      uveit: _uveit,
      joints: _joints,
      sip: _sipCount,
      syssind1: _listSyssindNotUse1,
      siplist: _siplist,
      uvellim: _listSyssind2.where((item) => item.isActive).length,
      syssind2: _listSyssind2,
      creationDate: _creationDate,
    );

    if (widget.isEditForm || _recordId != null) {
      await _api.put(
          patientsId: _patientsId, recordId: _recordId!, thisData: thisData);
    } else {
      _recordId = await _api.post(patientsId: _patientsId, thisData: thisData);
    }
  }

  bool _areDifferent() {
    if (!widget.isEditForm || widget.thisData == null) {
      // Если это форма добавления или данных нет, считаем, что есть изменения, если что-то заполнено
      return _tem != null ||
          _sis != 0 ||
          _dia != 0 ||
          _chss != null ||
          _utscov != null ||
          _ocbol != 0 ||
          _siplist != '[]' ||
          _joints.isNotEmpty ||
          _uveit != null;
    }

    // Иначе Сравниваем поля
    final w = widget.thisData!;
    return convertToTimestamp(_date ?? '') != w.date ||
        _tem != w.tem ||
        _sis != w.ardav.sis ||
        _dia != w.ardav.dia ||
        _chss != w.chss ||
        _utscov != w.utscov ||
        _ocbol != w.ocbol ||
        !listEquals([_siplist]..sort(), [w.siplist]..sort()) ||
        !listEquals([_joints]..sort(), [w.joints]..sort()) ||
        !listEquals([_listSyssind2]..sort(), [w.syssind2]..sort()) ||
        _uveit != w.uveit;
  }

  Future<bool> _getRecordId() async {
    if (_recordId == null) {
      return _changeData(false);
    }
    return true;
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
                          buildInspectionForm(),
                          SizedBox(height: 30),
                          buildInspectionMenu(),
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
                        listRoles: Roles.asPatient,
                        role: _role,
                        showProgressIndicator: _isLoading,
                        onPressed: () {
                          _changeData(true);
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

  Widget buildInspectionForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputSelectDateTime(
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
          labelText: 'Температура',
          fieldKey: _keys[Enum.tem]!,
          value: _tem,
          required: false,
          listValues: _listSprTemperature,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _tem = double.tryParse(value);
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InputText(
                labelText: 'Давление верхнее',
                fieldKey: _keys[Enum.sis]!,
                value: (_sis == 0) ? '' : _sis,
                required: (_dia > 0) ? true : false,
                keyboardType: TextInputType.number,
                min: 30,
                max: 300,
                listRoles: Roles.asPatient,
                role: _role,
                onChanged: (value) {
                  setState(() {
                    _sis = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InputText(
                labelText: 'нижнее',
                fieldKey: _keys[Enum.dia]!,
                value: (_dia == 0) ? '' : _dia,
                required: (_sis > 0) ? true : false,
                keyboardType: TextInputType.number,
                min: 15,
                max: (_sis == 0) ? 200 : _sis,
                listRoles: Roles.asPatient,
                role: _role,
                onChanged: (value) {
                  setState(() {
                    _dia = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
          ],
        ),
        InputText(
          labelText: 'ЧСС',
          fieldKey: _keys[Enum.chss]!,
          value: _chss,
          required: false,
          keyboardType: TextInputType.number,
          min: 40,
          max: 300,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _chss = int.tryParse(value);
            });
          },
        ),
        InputText(
          labelText: 'Утренняя скованность (в минутах)',
          fieldKey: _keys[Enum.utscov]!,
          value: _utscov,
          required: true,
          keyboardType: TextInputType.number,
          min: 0,
          max: 1000,
          listRoles: Roles.asPatient,
          role: _role,
          onChanged: (value) {
            setState(() {
              _utscov = int.tryParse(value) ?? 0;
            });
          },
        ),
      ],
    );
  }

  Widget buildInspectionMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTileColorWidget(
          title: 'Оценка боли',
          colorBorder: Colors.blue.shade200,
          imagePath: 'assets/light.png',
          onPressed: () async {
            _ocbol = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageInspectionsPain(
                      ocbol: _ocbol,
                      role: _role,
                    ),
                  ),
                ) ??
                _ocbol; // если вернется null, оставляем старое значение
            setState(() {}); // Обновляем UI после изменения данных
          },
        ),
        ListTileColorWidget(
          title: 'Увеит',
          colorBorder: Colors.deepPurple.shade200,
          imagePath: 'assets/eye.png',
          onPressed: () async {
            final result = await Navigator.push<List<dynamic>>(
              context,
              MaterialPageRoute(
                builder: (context) => PageInspectionsUveit(
                  uveit: _uveit,
                  role: _role,
                  viewRegime: false,
                ),
              ),
            );

            if (result != null && result.length == 2) {
              bool uveitExists = result[0] as bool; // Первый элемент
              if (!uveitExists) {
                _uveit = null;
              } else {
                _uveit = result[1] as Uveit; // Второй элемент
              }
            }
            setState(() {}); // Обновляем UI после изменения данных
          },
        ),
        ListTileColorWidget(
            title: 'Сыпь',
            colorBorder: Colors.red.shade200,
            imagePath: 'assets/rash.png',
            onPressed: () async {
              bool recordIdExists = await _getRecordId();
              if (recordIdExists) {
                final result = await Navigator.push<List<dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageInspectionsRash(
                      siplist: _siplist,
                      inspectionsId: _recordId!,
                      viewRegime: false,
                    ),
                  ),
                );

                if (result != null && result.length == 2) {
                  _sipCount = result[0] as int; // Первый элемент
                  _siplist = result[1] as String; // Второй элемент
                }
                setState(() {}); // Обновляем UI после изменения данных
              }
            }),
        ListTileColorWidget(
          title: 'Лимфоузлы',
          colorBorder: Colors.amber.shade200,
          imagePath: 'assets/lymph.png',
          onPressed: () async {
            _listSyssind2 = await Navigator.push<List<Syssind>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageInspectionsLimph(
                      listSyssind: _listSyssind2,
                      viewRegime: false,
                      role: _role,
                    ),
                  ),
                ) ??
                _listSyssind2; // если вернется null, оставляем старый список
            setState(() {}); // Обновляем UI после изменения данных
          },
        ),
        ListTileColorWidget(
          title: 'Суставной синдром',
          colorBorder: Colors.green.shade200,
          imagePath: 'assets/joints.png',
          onPressed: () async {
            bool recordIdExists = await _getRecordId();
            if (recordIdExists) {
              _joints = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageInspectionsJointSyndrome(
                    joints: _joints,
                    inspectionsId: _recordId!,
                    viewRegime: false,
                  ),
                ),
              ) ??
                  _joints; // если вернется null, оставляем старый список
              setState(() {}); // Обновляем UI после изменения данных
            }
          },
        ),
        ListTileColorWidget(
          title: 'Измерение углов',
          colorBorder: Colors.orange.shade200,
          imagePath: 'assets/corner.png',
          onPressed: () async {
            bool recordIdExists = await _getRecordId();
            if (recordIdExists) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PageInspectionsAngles(
                    inspectionsId: _recordId!,
                    onDataUpdated: () async {
                      widget.onDataUpdated?.call();
                    },
                  ),
                ),
              );
              setState(() {}); // Обновляем UI после изменения данных
            }
          },
        ),
      ],
    );
  }
}
