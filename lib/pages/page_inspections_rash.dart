import 'package:artrit/data/data_inspections_photo.dart';
import 'package:flutter/material.dart';
import '../api/api_inspections_photo.dart';
import '../data/data_inspections.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/image_strip_gallery.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/show_message.dart';
import '../widgets/switch_widget.dart';
import '../widgets/button_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class PageInspectionsRash extends StatefulWidget {
  final List<Syssind> listSyssind;
  final String? siplist;
  final String inspectionsId;
  final bool viewRegime;

  const PageInspectionsRash({
    super.key,
    required this.listSyssind,
    this.siplist,
    required this.inspectionsId,
    required this.viewRegime,
  });

  @override
  State<PageInspectionsRash> createState() => PageInspectionsRashState();
}

class PageInspectionsRashState extends State<PageInspectionsRash> {
  late Future<void> _future;

  /// API
  final ApiInspectionsPhoto _apiPhoto = ApiInspectionsPhoto();

  /// Данные
  List<DataInspectionsPhoto>? _thisData;

  /// Параметры
  late int _role;
  late String _patientsId;
  late String _inspectionsId;
  late List<Syssind> _listSyssind;
  bool _isBack = false;
  String? _selectedPart; // Идентификатор активной части
  String? _jointsId;
  static const String _bodyType = 'skin';

  /// Ключи
  final Map<EnumRash, GlobalKey<FormFieldState>> _keys = {
    for (var e in EnumRash.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    // Если будем делать так, то при клике "Назад" передаются изменения
    //_listSyssind = widget.listSyssind;
    // Поэтому делаем глубокую копию списка
    _listSyssind = widget.listSyssind
        .map((syssind) => Syssind(
              name: syssind.name,
              isActive: syssind.isActive,
            ))
        .toList();

    _future = _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _inspectionsId = widget.inspectionsId;
    _thisData = await _apiPhoto.get(
        patientsId: _patientsId,
        bodyType: _bodyType,
        inspectionsId: _inspectionsId);
    setState(() {});
  }

  Future<void> _refreshData() async {
    _future = _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Сыпь',
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () {
          onBack(context, (areDifferent(widget.listSyssind, _listSyssind)));
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                Expanded(
                  child: Center(
                    child: buildInteractiveBody(_isBack),
                  ),
                ),
                (_selectedPart != null && !widget.viewRegime) ?
                  InputCheckbox(
                    fieldKey: _keys[EnumRash.isActive]!,
                    labelText: 'Наличие сыпи',
                    value: _partActive(_selectedPart!),
                    readOnly: widget.viewRegime,
                    textStyle: subtitleMiniTextStyle,
                    padding: 0,
                    listRoles: Roles.asPatient,
                    role: _role,
                    onChanged: (value) {
                      setState(() {
                        _isActive(_selectedPart!);
                      });
                    },
                  ) : SizedBox(height: 38),
                SwitchWidget(
                  labelTextFirst: 'Спереди',
                  labelTextLast: 'Сзади',
                  value: _isBack,
                  listRoles: Roles.all,
                  onChanged: (newValue) {
                    setState(() {
                      _isBack = newValue;
                      _selectedPart = null;
                      _jointsId = null;
                    });
                  },
                ),
                // Горизонтальная лента миниатюр
                SizedBox(
                  height: 100,
                  child: ImageStripGallery(
                    addPhotoEnabled: (_selectedPart != null &&
                        partPhotoActive(_selectedPart!)),
                    addPhotoEnabledText:
                        'Сначала нужно отметить наличие сыпи',
                    addPhotoBtnShow:
                        _selectedPart != null && !widget.viewRegime,
                    inspectionsId: _inspectionsId,
                    jointsId: (_selectedPart != null) ? _jointsId : null,
                    bodyType: _bodyType,
                    viewRegime: widget.viewRegime,
                    onDataUpdated: () {
                      _refreshData();
                    },
                  ),
                ),
                if (!widget.viewRegime)
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: ButtonWidget(
                        labelText: 'Применить',
                        listRoles: Roles.asPatient,
                        role: _role,
                        onPressed: () {
                          String siplist = getSiplist();
                          Navigator.pop(context, [
                            _listSyssind,
                            siplist
                          ]); // Передача значения назад
                        },
                      ),
                    ),
                  ),
              ],
            );
          }),
    );
  }

  Widget buildInteractiveBody(bool isBack) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double leftOffset = widget.viewRegime ? 20.0 : -10.0;
          double screenHeight = constraints.maxHeight;


          List<BodyParts> bodyParts = [
            // BodyParts(
            //     part: 'body',
            //     imagePath: 'assets/body.svg',
            //     top: screenHeight * 0.02,
            //     left: screenHeight * 0.145,
            //     height: screenHeight * 0.95,
            //     onTapAvailable: false),
            BodyParts(
                part: 'Затылок',
                imagePath: 'assets/body_hair_back.svg',
                imagePathSelected: 'assets/body_hair_back.svg',
                top: screenHeight * 0.0,
                left: screenHeight * 0.282 - leftOffset,
                height: screenHeight * 0.1472,
                onTapAvailable: false),
            if (!isBack)
              BodyParts(
                  part: bodyHead,
                  imagePath: 'assets/body_head.svg',
                  imagePathSelected: 'assets/body_head_selected.svg',
                  top: screenHeight * 0.022,
                  left: screenHeight * 0.2952 - leftOffset,
                  height: screenHeight * 0.123),
            BodyParts(
                part: 'Челка',
                imagePath: 'assets/body_hair_front.svg',
                imagePathSelected: 'assets/body_hair_front.svg',
                top: screenHeight * 0.006,
                left: screenHeight * 0.295 - leftOffset,
                height: screenHeight * 0.05,
                onTapAvailable: false),
            !isBack
                ? BodyParts(
                    part: bodyLeftHand,
                    imagePath: 'assets/body_left_hand.svg',
                    imagePathSelected: 'assets/body_left_hand_selected.svg',
                    top: screenHeight * 0.165,
                    left: screenHeight * 0.412 - leftOffset,
                    height: screenHeight * 0.374)
                : BodyParts(
                    part: bodyLeftHand,
                    imagePath: 'assets/body_right_hand.svg',
                    imagePathSelected: 'assets/body_right_hand_selected.svg',
                    top: screenHeight * 0.166,
                    left: screenHeight * 0.1362 - leftOffset,
                    height: screenHeight * 0.374),
            !isBack
                ? BodyParts(
                    part: bodyRightHand,
                    imagePath: 'assets/body_right_hand.svg',
                    imagePathSelected: 'assets/body_right_hand_selected.svg',
                    top: screenHeight * 0.166,
                    left: screenHeight * 0.1362 - leftOffset,
                    height: screenHeight * 0.374)
                : BodyParts(
                    part: bodyRightHand,
                    imagePath: 'assets/body_left_hand.svg',
                    imagePathSelected: 'assets/body_left_hand_selected.svg',
                    top: screenHeight * 0.165,
                    left: screenHeight * 0.412 - leftOffset,
                    height: screenHeight * 0.374),
            !isBack
                ? BodyParts(
                    part: bodyLeftLeg,
                    imagePath: 'assets/body_left_leg_front.svg',
                    imagePathSelected:
                        'assets/body_left_leg_front_selected.svg',
                    top: screenHeight * 0.4273,
                    left: screenHeight * 0.334 - leftOffset,
                    height: screenHeight * 0.555)
                : BodyParts(
                    part: bodyLeftLeg,
                    imagePath: 'assets/body_left_leg_back.svg',
                    imagePathSelected: 'assets/body_left_leg_back_selected.svg',
                    top: screenHeight * 0.4305,
                    left: screenHeight * 0.245 - leftOffset,
                    height: screenHeight * 0.5),
            !isBack
                ? BodyParts(
                    part: bodyRightLeg,
                    imagePath: 'assets/body_right_leg_front.svg',
                    imagePathSelected:
                        'assets/body_right_leg_front_selected.svg',
                    top: screenHeight * 0.4295,
                    left: screenHeight * 0.2445 - leftOffset,
                    height: screenHeight * 0.555)
                : BodyParts(
                    part: bodyRightLeg,
                    imagePath: 'assets/body_right_leg_back.svg',
                    imagePathSelected:
                        'assets/body_right_leg_back_selected.svg',
                    top: screenHeight * 0.4275,
                    left: screenHeight * 0.333 - leftOffset,
                    height: screenHeight * 0.5),
            !isBack
                ? BodyParts(
                    part: bodyBreast,
                    imagePath: 'assets/body_breast.svg',
                    imagePathSelected: 'assets/body_breast_selected.svg',
                    top: screenHeight * 0.1455,
                    left: screenHeight * 0.245 - leftOffset,
                    height: screenHeight * 0.215)
                : BodyParts(
                    part: bodyBreastBack,
                    imagePath: 'assets/body_breast.svg',
                    imagePathSelected: 'assets/body_breast_selected.svg',
                    top: screenHeight * 0.1455,
                    left: screenHeight * 0.245 - leftOffset,
                    height: screenHeight * 0.215),
            if (isBack)
              BodyParts(
                part: bodyLopatki,
                imagePath: 'assets/body_breast_back.svg',
                imagePathSelected: 'assets/body_breast_back.svg',
                top: screenHeight * 0.2,
                left: screenHeight * 0.285 - leftOffset,
                height: screenHeight * 0.063,
              ),
            !isBack
                ? BodyParts(
                    part: bodyHips,
                    imagePath: 'assets/body_hips.svg',
                    imagePathSelected: 'assets/body_hips_selected.svg',
                    top: screenHeight * 0.36,
                    left: screenHeight * 0.25 - leftOffset,
                    height: screenHeight * 0.135)
                : BodyParts(
                    part: bodyHipsBack,
                    imagePath: 'assets/body_hips.svg',
                    imagePathSelected: 'assets/body_hips_selected.svg',
                    top: screenHeight * 0.36,
                    left: screenHeight * 0.25 - leftOffset,
                    height: screenHeight * 0.135),
            if (isBack)
              BodyParts(
                part: bodyButtocks,
                imagePath: 'assets/body_hips_back.svg',
                imagePathSelected: 'assets/body_hips_back.svg',
                top: screenHeight * 0.472,
                left: screenHeight * 0.276 - leftOffset,
                height: screenHeight * 0.045,
              ),
          ];


          return Stack(
            alignment: Alignment.center,
            children: [
              // Фоновый слой для сброса _selectedPart
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPart = null;
                      _jointsId = null;
                    });
                  },
                  child: Container(
                    color: Colors.transparent, // Невидимый фон
                  ),
                ),
              ),
              // Все части тела (кликабельные)
              ...bodyParts.map((item) {
                return Positioned(
                  left: item.left,
                  top: item.top,
                  child: GestureDetector(
                    onTap: item.onTapAvailable ? () => _togglePart(item.part) : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Основное изображение
                        ColorFiltered(
                          colorFilter: _partActive(item.part)
                              ? ColorFilter.mode(
                              Colors.red.shade300, BlendMode.srcATop)
                              : const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply),
                          child: SvgPicture.asset(
                            item.imagePath,
                            height: item.height,
                          ),
                        ),
                        // Изображение с контуром (накладывается только если выбрано)
                        if (_selectedPart == item.part)
                          SvgPicture.asset(
                            item.imagePathSelected,
                            height: item.height,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _togglePart(String part) {
    setState(() {
      if (part == bodyLopatki) {
        part = bodyBreastBack;
      } else if (part == bodyButtocks) {
        part = bodyHipsBack;
      }
      _selectedPart = part;
      _jointsId = _listJointId.firstWhere((item) => item.bodyName == part).id;
    });
  }

  void _isActive(String part) {
    if (part == bodyLopatki) {
      part = bodyBreastBack;
    } else if (part == bodyButtocks) {
      part = bodyHipsBack;
    }
    if (_listSyssind.firstWhere((item) => item.name == part).isActive) {
      int photoCount =
          _thisData!.where((e) => e.jointsId == _jointsId).toList().length;
      if (photoCount > 0) {
        ShowMessage.show(context: context,
            message:
                'Нельзя удалить сыпь с участка кожи, где есть фотография');
      } else {
        _listSyssind.firstWhere((item) => item.name == part).isActive = false;
      }
    } else {
      _listSyssind.firstWhere((item) => item.name == part).isActive = true;
    }
  }

  bool _partActive(String part) {
    if (part == bodyLopatki ||
        part == bodyButtocks ||
        part == 'Затылок' ||
        part == 'Челка') {
      return false;
    }
    return _listSyssind.firstWhere((item) => item.name == part).isActive;
  }

  bool partPhotoActive(String part) {
    if (part == 'Затылок' || part == 'Челка') {
      return false;
    }
    if (part == bodyLopatki) {
      part = bodyBreastBack;
    } else if (part == bodyButtocks) {
      part = bodyHipsBack;
    }
    return _listSyssind.firstWhere((item) => item.name == part).isActive;
  }

  String getSiplist() {
    String siplist = jsonEncode([
      {
        "numeric_id": 4,
        "name": bodyBreast,
        "bol":
            _listSyssind.firstWhere((item) => item.name == bodyBreast).isActive
      },
      {
        "numeric_id": 8,
        "name": bodyRightLeg,
        "bol": _listSyssind
            .firstWhere((item) => item.name == bodyRightLeg)
            .isActive
      },
      {
        "numeric_id": 3,
        "name": bodyLeftHand,
        "bol": _listSyssind
            .firstWhere((item) => item.name == bodyLeftHand)
            .isActive
      },
      {
        "numeric_id": 7,
        "name": bodyLeftLeg,
        "bol":
            _listSyssind.firstWhere((item) => item.name == bodyLeftLeg).isActive
      },
      {
        "numeric_id": 14,
        "name": "Паховая область",
        "bol": _listSyssind.firstWhere((item) => item.name == bodyHips).isActive
      },
      {
        "numeric_id": 2,
        "name": bodyRightHand,
        "bol": _listSyssind
            .firstWhere((item) => item.name == bodyRightHand)
            .isActive
      },
      {
        "numeric_id": 17,
        "name": bodyBreastBack,
        "bol": _listSyssind
            .firstWhere((item) => item.name == bodyBreastBack)
            .isActive
      },
      {
        "numeric_id": 5,
        "name": bodyButtocks,
        "bol": _listSyssind
            .firstWhere((item) => item.name == bodyHipsBack)
            .isActive
      },
      {"numeric_id": 15, "name": "Правая нога(Сзади)", "bol": false}
    ]);
    siplist = jsonEncode(
        jsonDecode(siplist).where((item) => item["bol"] == true).toList());
    return siplist;
  }
}

const String bodyHead = 'Голова + шея';
const String bodyLeftHand = 'Левая рука';
const String bodyRightHand = 'Правая рука';
const String bodyLeftLeg = 'Левая нога';
const String bodyRightLeg = 'Правая нога';
const String bodyBreast = 'Туловище';
const String bodyBreastBack = 'Спина';
const String bodyLopatki = 'Лопатки';
const String bodyHips = 'Бедро';
const String bodyHipsBack = 'Бедро(Сзади)';
const String bodyButtocks = 'Ягодицы';

class BodyParts {
  final String part;
  final String imagePath;
  final String imagePathSelected; // Путь к SVG с контуром
  final double top;
  final double? bottom;
  final double left;
  final double? right;
  final double? width;
  final double height;
  final bool onTapAvailable;

  BodyParts({
    required this.part,
    required this.imagePath,
    required this.imagePathSelected,
    required this.top,
    this.bottom,
    required this.left,
    this.right,
    this.width,
    required this.height,
    this.onTapAvailable = true,
  });
}

class BodyId {
  final String bodyName;
  String id;

  BodyId({
    required this.bodyName,
    required this.id,
  });
}

List<BodyId> _listJointId = [
  BodyId(bodyName: bodyHead, id: '6554660f-de03-4db3-9d7d-f7cf307f8374'),
  BodyId(bodyName: bodyLeftHand, id: '3267c7fd-8e44-45f2-bd58-1774394a9bdc'),
  BodyId(bodyName: bodyRightHand, id: 'fd6220b0-c47e-4383-b9a0-cfd26292b7c7'),
  BodyId(bodyName: bodyLeftLeg, id: 'fd86f9ba-07cd-4187-889a-227b2dcd4685'),
  BodyId(bodyName: bodyRightLeg, id: 'bae85dcf-f3ed-43c7-a10b-a5557536634e'),
  BodyId(bodyName: bodyBreast, id: 'f2289751-f85f-4c5d-8046-c474bd2c23db'),
  BodyId(bodyName: bodyBreastBack, id: '7b47c00b-80dd-4344-9c84-80bd25558db1'),
  BodyId(bodyName: bodyHips, id: '9adea69f-6d79-480b-8d87-4ecbc2b583e3'),
  BodyId(bodyName: bodyHipsBack, id: '5969802e-7521-4bc2-b745-a899df78cd10'),
];
