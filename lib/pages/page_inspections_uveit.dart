import 'package:artrit/data/data_spr_item.dart';
import 'package:flutter/material.dart';
import '../data/data_inspections.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners.dart';
import '../widgets/button_widget.dart';
import '../widgets/widget_input_select.dart';
import '../widgets/widget_input_select_date_time.dart';
import '../widgets/input_switch.dart';
import '../widgets/input_text.dart';
import '../widgets/switch_widget.dart';

class PageInspectionsUveit extends StatefulWidget {
  final Uveit? uveit;
  final int role;
  final bool viewRegime;

  const PageInspectionsUveit({
    super.key,
    required this.uveit,
    required this.role,
    required this.viewRegime,
  });

  @override
  State<PageInspectionsUveit> createState() => _PageInspectionsUveitState();
}

class _PageInspectionsUveitState extends State<PageInspectionsUveit> {

  /// Параметры
  late Uveit? _uveit;
  String? _consultationDate;
  int _sideType = 1;
  int? _diseaseCourse;
  bool _complications = false;
  String? _complicationsComment;
  bool _localTherapy = false;
  bool _uveitExists = false;

  // Справочники
  final List<SprItem> _listSprDiseaseCourse = [
    SprItem(id: '1', name: 'Обострение'),
    SprItem(id: '2', name: 'Вялотекущий'),
    SprItem(id: '3', name: 'Ремиссия')];
  final List<SprItem> _listSprUveitExists = [
    SprItem(id: '1', name: 'Отсутствует'),
    SprItem(id: '2', name: 'Присутствует')];

  /// Ключи
  final _formKey = GlobalKey<FormState>();
  final Map<EnumUveit, GlobalKey<FormFieldState>> _keys = {
    for (var e in EnumUveit.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    if (widget.uveit != null) {
      _uveit = widget.uveit!;
      _consultationDate = dateFormat(_uveit!.consultationDate);
      _sideType = _uveit!.sideType;
      _diseaseCourse = _uveit!.diseaseCourse;
      _complications = _uveit!.complications;
      _complicationsComment = _uveit!.complicationsComment;
      _localTherapy = _uveit!.localTherapy;
      _uveitExists = true;
    } else {
      _uveit = null;
    }
    super.initState();
  }


  void _changeData() async {
    if (!_formKey.currentState!.validate()) {
      showTopBanner(context: context);
      return;
    }
    if (_uveitExists) {
      _uveit = Uveit(
          consultationDate: convertStrToDate(_consultationDate!),
          sideType: _sideType,
          diseaseCourse: _diseaseCourse!,
          complications: _complications,
          complicationsComment: _complicationsComment,
          localTherapy: _localTherapy);
    }
    else {
      _uveit = null;
    }
    Navigator.pop(context, [_uveitExists, _uveit]);
  }


// Метод для сравнения исходного и текущего значения формы
  bool _areDifferent() {
    if (widget.uveit == null && !_uveitExists) {
      return false; // Оба null или отсутствуют
    }
    if (widget.uveit != null && !_uveitExists) {
      return true; // widget.uveit есть, а _uveitExists = false
    }
    if (widget.uveit == null && _uveitExists) {
      return true; // widget.uveit null, а _uveitExists = true
    }

    // Сравниваем поля
    final w = widget.uveit!;
    return w.consultationDate != convertStrToDate(_consultationDate!) ||
        w.sideType != _sideType ||
        w.diseaseCourse != _diseaseCourse ||
        w.complications != _complications ||
        w.complicationsComment != _complicationsComment ||
        w.localTherapy != _localTherapy;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Увеит',
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () { onBack(context, (_areDifferent())); },
      ),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetInputSelect(
                      labelText: 'Увеит',
                      fieldKey: _keys[EnumUveit.uveitExists]!,
                        allValues: _listSprUveitExists,
                      selectedValue: _uveitExists ? _listSprUveitExists[1].id : _listSprUveitExists[0].id,
                      required: true,
                      readOnly: widget.viewRegime,
                      cleanAvailable: false,
                      listRoles: Roles.asPatient,
                      roleId: widget.role,
                      onChanged: (value) {
                        setState(() {
                          _uveitExists = (value == _listSprUveitExists[0].id) ? false : true;
                        });
                      },
                    ),
                    if (_uveitExists)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildForm(),
                          SizedBox(height: 30),
                        ],
                      ),
                  ],),
                ),
              ),
              if (!widget.viewRegime)
              Container(
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: ButtonWidget(
                    labelText: 'Сохранить',
                    listRoles: Roles.asPatient,
                    role: widget.role,
                    onPressed: () {
                      setState(() {
                        if (!_complications) _complicationsComment = '';
                      });
                      _changeData();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildForm()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WidgetInputSelectDateTime(
          labelText: 'Дата консультации',
          fieldKey: _keys[EnumUveit.consultationDate]!,
          value: _consultationDate,
          lastDateTime: getMoscowDateTime(),
          required: _uveitExists,
          readOnly: widget.viewRegime,
          listRoles: Roles.asPatient,
          roleId: widget.role,
          onChanged: (value) {
            setState(() {
              _consultationDate = value;
            });
          },
        ),
        Row(
          children: [
            SwitchWidget(
              labelTextFirst: 'Односторонний',
              labelTextLast: 'Двусторонний',
              value: _sideType == 2 ? true : false,
              readOnly: widget.viewRegime,
              listRoles: Roles.asPatient,
              role: widget.role,
              onChanged: (newValue) {
                setState(() {
                  _sideType = newValue == true ? 2 : 1;
                });
              },
            ),
            Spacer(),
          ],
        ),
        WidgetInputSelect(
          labelText: 'Течение',
          fieldKey: _keys[EnumUveit.diseaseCourse]!,
          allValues: _listSprDiseaseCourse,
          selectedValue: _diseaseCourse?.toString(),
          required: _uveitExists,
          readOnly: widget.viewRegime,
          listRoles: Roles.asPatient,
          roleId: widget.role,
          onChanged: (value) {
            setState(() {
              if (value != null && value.isNotEmpty) {
                _diseaseCourse = int.parse(value);
              } else {
                _diseaseCourse = null;
              }
            });
          },
        ),
        InputSwitch(
          labelText: 'Осложнения',
          fieldKey: _keys[EnumUveit.complications]!,
          value: _complications,
          readOnly: widget.viewRegime,
          listRoles: Roles.asPatient,
          role: widget.role,
          onChanged: (value) {
            setState(() {
              _complications = value;
            });
          },
        ),
        if (_complications) InputText(
          labelText: 'Осложнения',
          fieldKey: _keys[EnumUveit.complicationsComment]!,
          value: _complicationsComment,
          required: _complications && _uveitExists,
          readOnly: widget.viewRegime,
          listRoles: Roles.asPatient,
          role: widget.role,
          onChanged: (value) {
            setState(() {
              _complicationsComment = value;
            });
          },
        ),
        InputSwitch(
          labelText: 'Местная терапия',
          fieldKey: _keys[EnumUveit.localTherapy]!,
          value: _localTherapy,
          readOnly: widget.viewRegime,
          listRoles: Roles.asPatient,
          role: widget.role,
          onChanged: (value) {
            setState(() {
              _localTherapy = value;
            });
          },
        ),
      ],
    );
  }




}



