import 'package:artrit/data/data_inspections_photo.dart';
import 'package:collection/collection.dart';
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
  final String? siplist;
  final String inspectionsId;
  final bool viewRegime;

  const PageInspectionsRash({
    super.key,
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
  bool _isBack = false;
  int? _selectedPart; // Идентификатор активной части
  String? _jointsId;
  static const String _bodyType = 'skin';
  String _siplist = '[]';
  List<Siplist> _listSiplist = [
    Siplist(numericId: 4, name: "Туловище", bol: false),
    Siplist(numericId: 8, name: "Правая нога", bol: false),
    Siplist(numericId: 1, name: "Голова + шея", bol: false),
    Siplist(numericId: 3, name: "Левая рука", bol: false),
    Siplist(numericId: 7, name: "Левая нога", bol: false),
    Siplist(numericId: 14, name: "Паховая область", bol: false),
    Siplist(numericId: 2, name: "Правая рука", bol: false),
    Siplist(numericId: 17, name: "Спина", bol: false),
    Siplist(numericId: 5, name: "Ягодицы", bol: false),
  ];

  /// Ключи
  final Map<EnumRash, GlobalKey<FormFieldState>> _keys = {
    for (var e in EnumRash.values) e: GlobalKey<FormFieldState>(),
  };

  @override
  void initState() {
    _siplist = widget.siplist ?? '[]';

    // Обновляем существующий список siplist (не меняя саму структуру)
    _listSiplist = _updateSiplistFromJson(_siplist, _listSiplist);

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




  List<Siplist> _updateSiplistFromJson(String jsonString, List<Siplist> targetList) {
    if (jsonString.isEmpty) targetList;

    try {
      final decoded = jsonDecode(jsonString);
      final List<dynamic> rawList = decoded is String ? jsonDecode(decoded) : decoded;

      for (final item in rawList) {
        final parsed = Siplist.fromJson(item);
        final idx = targetList.indexWhere((e) => e.numericId == parsed.numericId);
        if (idx != -1) {
          // Обновляем только bol (и name при желании)
          targetList[idx].bol = parsed.bol;
        }
      }
    } catch (e) {
      debugPrint('Ошибка при парсинге/обновлении siplist: $e');
    }
    return targetList;
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
          onBack(context, (widget.siplist != _siplist));
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
                          String siplist = jsonEncode(_listSiplist);
                          Navigator.pop(context, [
                            _listSiplist.where((item) => item.bol).length,
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
                part: 100, // 'Затылок',
                imagePath: 'assets/body_hair_back.svg',
                imagePathSelected: 'assets/body_hair_back.svg',
                top: screenHeight * 0.0,
                left: screenHeight * 0.282 - leftOffset,
                height: screenHeight * 0.1472,
                onTapAvailable: false),
            if (!isBack)
              BodyParts(
                  part: 1, // 'Голова + шея' // bodyHead,
                  imagePath: 'assets/body_head.svg',
                  imagePathSelected: 'assets/body_head_selected.svg',
                  top: screenHeight * 0.022,
                  left: screenHeight * 0.2952 - leftOffset,
                  height: screenHeight * 0.123),
            BodyParts(
                part: 101, // 'Челка',
                imagePath: 'assets/body_hair_front.svg',
                imagePathSelected: 'assets/body_hair_front.svg',
                top: screenHeight * 0.006,
                left: screenHeight * 0.295 - leftOffset,
                height: screenHeight * 0.05,
                onTapAvailable: false),
            !isBack
                ? BodyParts(
                part: 3, // Левая рука // bodyLeftHand,
                imagePath: 'assets/body_left_hand.svg',
                imagePathSelected: 'assets/body_left_hand_selected.svg',
                top: screenHeight * 0.165,
                left: screenHeight * 0.412 - leftOffset,
                height: screenHeight * 0.374)
                : BodyParts(
                part: 3, // Левая рука // bodyLeftHand,
                imagePath: 'assets/body_right_hand.svg',
                imagePathSelected: 'assets/body_right_hand_selected.svg',
                top: screenHeight * 0.166,
                left: screenHeight * 0.1362 - leftOffset,
                height: screenHeight * 0.374),
            !isBack
                ? BodyParts(
                part: 2, // Правая рука // bodyRightHand,
                imagePath: 'assets/body_right_hand.svg',
                imagePathSelected: 'assets/body_right_hand_selected.svg',
                top: screenHeight * 0.166,
                left: screenHeight * 0.1362 - leftOffset,
                height: screenHeight * 0.374)
                : BodyParts(
                part: 2, // Правая рука // bodyRightHand,
                imagePath: 'assets/body_left_hand.svg',
                imagePathSelected: 'assets/body_left_hand_selected.svg',
                top: screenHeight * 0.165,
                left: screenHeight * 0.412 - leftOffset,
                height: screenHeight * 0.374),
            !isBack
                ? BodyParts(
                part: 7, // bodyLeftLeg, // Левая нога
                imagePath: 'assets/body_left_leg_front.svg',
                imagePathSelected:
                'assets/body_left_leg_front_selected.svg',
                top: screenHeight * 0.4273,
                left: screenHeight * 0.334 - leftOffset,
                height: screenHeight * 0.555)
                : BodyParts(
                part: 7, // bodyLeftLeg, // Левая нога
                imagePath: 'assets/body_left_leg_back.svg',
                imagePathSelected: 'assets/body_left_leg_back_selected.svg',
                top: screenHeight * 0.4305,
                left: screenHeight * 0.245 - leftOffset,
                height: screenHeight * 0.5),
            !isBack
                ? BodyParts(
                part: 8, // bodyRightLeg, // Правая нога
                imagePath: 'assets/body_right_leg_front.svg',
                imagePathSelected:
                'assets/body_right_leg_front_selected.svg',
                top: screenHeight * 0.4295,
                left: screenHeight * 0.2445 - leftOffset,
                height: screenHeight * 0.555)
                : BodyParts(
                part: 8, // bodyRightLeg, // Правая нога
                imagePath: 'assets/body_right_leg_back.svg',
                imagePathSelected:
                'assets/body_right_leg_back_selected.svg',
                top: screenHeight * 0.4275,
                left: screenHeight * 0.333 - leftOffset,
                height: screenHeight * 0.5),
            !isBack
                ? BodyParts(
                part: 4, // Туловище // bodyBreast,
                imagePath: 'assets/body_breast.svg',
                imagePathSelected: 'assets/body_breast_selected.svg',
                top: screenHeight * 0.1455,
                left: screenHeight * 0.245 - leftOffset,
                height: screenHeight * 0.215)
                : BodyParts(
                part: 17, // Спина // bodyBreastBack,
                imagePath: 'assets/body_breast.svg',
                imagePathSelected: 'assets/body_breast_selected.svg',
                top: screenHeight * 0.1455,
                left: screenHeight * 0.245 - leftOffset,
                height: screenHeight * 0.215),
            if (isBack)
              BodyParts(
                part: 102, // Лопатки // bodyLopatki,
                imagePath: 'assets/body_breast_back.svg',
                imagePathSelected: 'assets/body_breast_back.svg',
                top: screenHeight * 0.2,
                left: screenHeight * 0.285 - leftOffset,
                height: screenHeight * 0.063,
              ),
            !isBack
                ? BodyParts(
                part: 14, // Бедро или Паховая область // bodyHips,
                imagePath: 'assets/body_hips.svg',
                imagePathSelected: 'assets/body_hips_selected.svg',
                top: screenHeight * 0.36,
                left: screenHeight * 0.25 - leftOffset,
                height: screenHeight * 0.135)
                : BodyParts(
                part: 5, // bodyHipsBack // Ягодицы или Бедро(Сзади)
                imagePath: 'assets/body_hips.svg',
                imagePathSelected: 'assets/body_hips_selected.svg',
                top: screenHeight * 0.36,
                left: screenHeight * 0.25 - leftOffset,
                height: screenHeight * 0.135),
            if (isBack)
              BodyParts(
                part: 103, // bodyButtocks, // Ягодицы
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

  void _togglePart(int part) {
    setState(() {
      if (part == 102) {
        part = 17;
      } else if (part == 103) {
        part = 5;
      }
      debugPrint(part.toString());
      _selectedPart = part;
      _jointsId = _listJointId.firstWhereOrNull((item) => item.bodyNumber == part)?.id;
    });
  }

  void _isActive(int part) {
    if (part == 102) {
      part = 17;
    } else if (part == 103) {
      part = 5;
    }
    Siplist? sip = _listSiplist.firstWhereOrNull((item) => item.numericId == part);
    if (sip == null) return;

    if (sip.bol) {
      int photoCount =
          _thisData!.where((e) => e.jointsId == _jointsId).toList().length;
      if (photoCount > 0) {
        ShowMessage.show(context: context,
            message:
            'Нельзя удалить сыпь с участка кожи, где есть фотография');
      } else {
        sip.bol = false;
      }
    } else {
      sip.bol = true;
    }
  }

  bool _partActive(int part) {
    if (part == 102 ||
        part == 103 ||
        part == 100 ||
        part == 101) {
      return false;
    }
    Siplist? sip = _listSiplist.firstWhereOrNull((item) => item.numericId == part);
    if (sip == null) {
      return false;
    } else {
      return sip.bol;
    }
  }

  bool partPhotoActive(int part) {
    if (part == 100 || part == 101) {
      return false;
    }
    if (part == 102) {
      part = 17;
    } else if (part == 103) {
      part = 5;
    }
    Siplist? sip = _listSiplist.firstWhereOrNull((item) => item.numericId == part);
    if (sip == null) {
      return false;
    } else {
      return sip.bol;
    }
  }
}


// const String bodyHead = 'Голова + шея';
// const String bodyLeftHand = 'Левая рука';
// const String bodyRightHand = 'Правая рука';
// const String bodyLeftLeg = 'Левая нога';
// const String bodyRightLeg = 'Правая нога';
// const String bodyBreast = 'Туловище';
// const String bodyBreastBack = 'Спина';
// const String bodyLopatki = 'Лопатки';
// const String bodyHips = 'Бедро';
// const String bodyHipsBack = 'Бедро(Сзади)';
// const String bodyButtocks = 'Ягодицы';

class BodyParts {
  final int part;
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
  final int bodyNumber;
  String id;

  BodyId({
    required this.bodyNumber,
    required this.id,
  });
}

List<BodyId> _listJointId = [
  BodyId(bodyNumber: 1, id: '6554660f-de03-4db3-9d7d-f7cf307f8374'),
  BodyId(bodyNumber: 3, id: '3267c7fd-8e44-45f2-bd58-1774394a9bdc'),
  BodyId(bodyNumber: 2, id: 'fd6220b0-c47e-4383-b9a0-cfd26292b7c7'),
  BodyId(bodyNumber: 7, id: 'fd86f9ba-07cd-4187-889a-227b2dcd4685'),
  BodyId(bodyNumber: 8, id: 'bae85dcf-f3ed-43c7-a10b-a5557536634e'),
  BodyId(bodyNumber: 4, id: 'f2289751-f85f-4c5d-8046-c474bd2c23db'),
  BodyId(bodyNumber: 17, id: '7b47c00b-80dd-4344-9c84-80bd25558db1'),
  BodyId(bodyNumber: 14, id: '9adea69f-6d79-480b-8d87-4ecbc2b583e3'),
  BodyId(bodyNumber: 5, id: '5969802e-7521-4bc2-b745-a899df78cd10'),
];
