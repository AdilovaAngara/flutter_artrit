import 'package:auto_size_text/auto_size_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../api/api_inspections_joints.dart';
import '../api/api_inspections_photo.dart';
import '../data/data_inspections.dart';
import '../data/data_inspections_joints.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../secure_storage.dart';
import '../theme.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/image_strip_gallery.dart';
import '../widgets/input_checkbox.dart';
import '../widgets/button_widget.dart';
import '../widgets/show_message.dart';

class PageInspectionsJointSyndrome extends StatefulWidget {
  final List<Joint> joints;
  final String inspectionsId;
  final bool viewRegime;

  const PageInspectionsJointSyndrome({
    super.key,
    required this.joints,
    required this.inspectionsId,
    required this.viewRegime,
  });

  @override
  State<PageInspectionsJointSyndrome> createState() =>
      PageInspectionsJointSyndromeState();
}

class PageInspectionsJointSyndromeState
    extends State<PageInspectionsJointSyndrome> {
  late Future<void> _future;

  /// API
  final ApiInspectionsPhoto _apiPhoto = ApiInspectionsPhoto();
  final ApiInspectionsJoints _apiJoints = ApiInspectionsJoints();
  /// Данные
  List<DataInspectionsPhoto>? _thisData;
  List<DataInspectionsJoints>? _thisDataJoints;
  /// Параметры
  late int _role;
  late String _patientsId;
  late String _inspectionsId;
  late List<Joint> _joints;
  int? _selectedPart; // Идентификатор активной части
  String? _jointsId;
  bool _isPainful = false;
  bool _isSwollen = false;
  bool _isMovementLimited = false;
  final String _btnPath = 'assets/radioBtn.svg';
  final String _btnPath1 = 'assets/radioBtn_1.svg';
  final String _btnPath2 = 'assets/radioBtn_2.svg';
  final String _btnPath3 = 'assets/radioBtn_3.svg';
  final String _btnPath4 = 'assets/radioBtn_4.svg';
  static const String _bodyType = 'joints';
  final GlobalKey _checkboxColumnKey = GlobalKey();
  double _checkboxHeight = 120; // Начальная высота (по умолчанию)
  /// Ключи
  final Map<EnumJoints, GlobalKey<FormFieldState>> _keys = {
    for (var e in EnumJoints.values) e: GlobalKey<FormFieldState>(),
  };


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCheckboxHeight();
    });
    // Делаем глубокую копию списка
    _joints = widget.joints.map((joint) => Joint(
        jointId: joint.jointId,
        isPainful: joint.isPainful,
        isSwollen: joint.isSwollen,
        isMovementLimited: joint.isMovementLimited
    )).toList();

    _future = _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    _role = await getUserRole();
    _patientsId = await readSecureData(SecureKey.patientsId);
    _inspectionsId = widget.inspectionsId;
    _thisDataJoints = await _apiJoints.get(patientsId: _patientsId, bodyType: _bodyType);
    _thisData = await _apiPhoto.get(
        patientsId: _patientsId,
        bodyType: _bodyType,
        inspectionsId: _inspectionsId);
    setState(() { });
  }

  Future<void> _refreshData() async {
    _future = _loadData();
  }

  // Метод для сравнения содержимого двух списков
  bool _areDifferent() {
    // Удаляем из _joints записи, которые не имеют паталогию
    _joints.removeWhere((joint) =>
    !joint.isPainful && !joint.isSwollen && !joint.isMovementLimited);
    if (widget.joints.length != _joints.length) return true;
    for (int i = 0; i < widget.joints.length; i++) {
      if (widget.joints[i].jointId != _joints[i].jointId ||
          widget.joints[i].isPainful != _joints[i].isPainful ||
          widget.joints[i].isSwollen != _joints[i].isSwollen ||
          widget.joints[i].isMovementLimited != _joints[i].isMovementLimited) {
        return true;
      }
    }
    return false;
  }


  void _updateCheckboxHeight() {
    final RenderBox? renderBox = _checkboxColumnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _checkboxHeight = renderBox.size.height; // Получаем реальную высоту
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Суставной синдром',
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  width: double.infinity, // Занимает всю ширину контейнера
                  height: 30,
                  child: Center(
                    child: AutoSizeText(
                      (_selectedPart != null && _thisDataJoints != null) ?
                      _thisDataJoints!.firstWhereOrNull((item) => item.numericId == _selectedPart)?.name ?? ''
                          : 'Сустав не выбран',
                      maxLines: 1,
                      minFontSize: 8, // Минимальный размер шрифта
                      maxFontSize: 24, // Максимальный размер шрифта
                      overflow: TextOverflow.ellipsis,
                      style: subtitleMiniTextStyle,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      // Включает возможность перетаскивания
                      boundaryMargin: EdgeInsets.all(20.0),
                      minScale: 0.5,
                      maxScale: 15.0,
                      child: buildInteractiveBody(),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 2, 0, 10),
                  child: Center(
                    child: Column(
                      key: _checkboxColumnKey, // 📌 Добавляем ключ для отслеживания высоты Column
                      children: [
                        if (_selectedPart != null)
                          Column(
                            children: [
                              InputCheckbox(
                                fieldKey: _keys[EnumJoints.isPainful]!,
                                labelText: 'Болезненный сустав',
                                value: _isPainful,
                                readOnly: widget.viewRegime,
                                textStyle: subtitleMiniTextStyle,
                                padding: 0,
                                listRoles: Roles.asPatient,
                                role: _role,
                                onChanged: (value) {
                                  setState(() {
                                    if (_allowDelCheck(_isPainful, _isSwollen, _isMovementLimited)) {
                                      _isPainful = value;
                                      _joints
                                          .firstWhere((item) => item.jointId == _selectedPart!)
                                          .isPainful = value;
                                    }
                                  });
                                },
                              ),
                              InputCheckbox(
                                fieldKey: _keys[EnumJoints.isSwollen]!,
                                labelText: 'Припухший сустав',
                                value: _isSwollen,
                                readOnly: widget.viewRegime,
                                textStyle: subtitleMiniTextStyle,
                                padding: 0,
                                listRoles: Roles.asPatient,
                                role: _role,
                                onChanged: (value) {
                                  setState(() {
                                    if (_allowDelCheck(_isSwollen, _isPainful, _isMovementLimited)) {
                                      _isSwollen = value;
                                      _joints
                                          .firstWhere((item) => item.jointId == _selectedPart!)
                                          .isSwollen = value;
                                    }
                                  });
                                },
                              ),
                              InputCheckbox(
                                fieldKey: _keys[EnumJoints.isMovementLimited]!,
                                labelText: 'Ограниченный в движении сустав',
                                value: _isMovementLimited,
                                readOnly: widget.viewRegime,
                                textStyle: subtitleMiniTextStyle,
                                padding: 0,
                                listRoles: Roles.asPatient,
                                role: _role,
                                onChanged: (value) {
                                  setState(() {
                                    if (_allowDelCheck(_isMovementLimited, _isPainful, _isSwollen)) {
                                      _isMovementLimited = value;
                                      _joints
                                          .firstWhere((item) => item.jointId == _selectedPart!)
                                          .isMovementLimited = value;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        if (_selectedPart == null) SizedBox(height: _checkboxHeight,),
                        // Горизонтальная лента миниатюр
                        SizedBox(
                          height: 100,
                          child: ImageStripGallery(
                            addPhotoEnabled: (_selectedPart != null && (_isPainful || _isSwollen || _isMovementLimited)),
                            addPhotoEnabledText: 'Сначала нужно отметить патологию',
                            addPhotoBtnShow: _selectedPart != null && !widget.viewRegime,
                            inspectionsId: _inspectionsId,
                            jointsId: (_selectedPart != null) ? _jointsId : null,
                            bodyType: _bodyType,
                            viewRegime: widget.viewRegime,
                            onDataUpdated: () {
                              setState(() {
                                _refreshData();
                              });
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
                                  Navigator.pop(context, _joints); // Передача значения назад/ Передача значения назад
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }



  bool _allowDelCheck(bool thisCheck, bool otherCheck1, bool otherCheck2)
  {
    int photoCount =
        _thisData!.where((e) => e.jointsId == _jointsId).toList().length;
    if (photoCount > 0 && thisCheck && !otherCheck1 && !otherCheck2) {
      ShowMessage.show(context: context, message:
      'Нельзя снять все галочки с сустава, к которому принязана фотография');
      return false;
    }
    else {
      return true;
    }
  }


  void _togglePart(int jointId) {
    if (jointId != 0) {
      setState(() {
        _selectedPart = (_selectedPart == jointId) ? null : jointId;
        if (_selectedPart != null && _thisDataJoints != null) {
          _jointsId = _thisDataJoints!.firstWhereOrNull((item) => item.numericId == _selectedPart)?.id;
          //leftOffset = 10;
          if (hasJointId(jointId)) {
            Joint? selectedJoint =
            _joints.firstWhereOrNull((item) => item.jointId == _selectedPart!);
            if (selectedJoint == null) return;
            _isPainful = selectedJoint.isPainful;
            _isSwollen = selectedJoint.isSwollen;
            _isMovementLimited = selectedJoint.isMovementLimited;
          } else {
            Joint newJoint = Joint(
                jointId: jointId,
                isPainful: false,
                isSwollen: false,
                isMovementLimited: false);
            _joints.add(newJoint);
            _isPainful = false;
            _isSwollen = false;
            _isMovementLimited = false;
          }
        } else {
          //leftOffset = 50;
        }
      });
    }
  }


  bool hasJointId(int jointsNumericId) {
    Joint? joint = _joints.firstWhereOrNull((item) => item.jointId == jointsNumericId);
    return (joint == null) ? false : true;
  }

  ColorFilter partColor(int jointId) {
    if (jointId == 0) {
      return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }

    bool isPainful = false;
    bool isSwollen = false;
    bool isMovementLimited = false;

    if (hasJointId(jointId)) {
      isPainful = _joints
          .firstWhere((item) => item.jointId == jointId)
          .isPainful;
      isSwollen = _joints
          .firstWhere((item) => item.jointId == jointId)
          .isSwollen;
      isMovementLimited = _joints
          .firstWhere((item) => item.jointId == jointId)
          .isMovementLimited;
    }

    if (isSwollen) {
      return ColorFilter.mode(Colors.red.shade300, BlendMode.srcATop);
    } else if (isPainful && isMovementLimited) {
      return ColorFilter.mode(Colors.red.shade300, BlendMode.srcATop);
    } else if (isPainful || isMovementLimited) {
      return ColorFilter.mode(Colors.green, BlendMode.srcATop);
    }
    return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
  }

  Widget _bodyPart(
      int jointsNumericId,
      String imagePath, {
        double? top,
        double? bottom,
        double? left,
        double? right,
        double? width,
        double? height,
        double borderWidth = 1.8,
      }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () => _togglePart(jointsNumericId),
        child: Stack(
          children: [
            ColorFiltered(
              colorFilter: partColor(jointsNumericId),
              child: SvgPicture.asset(
                imagePath,
                width: width,
                height: height,
              ),
            ),
            if (_selectedPart == jointsNumericId)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border:
                    Border.all(color: Colors.deepPurpleAccent, width: borderWidth),
                    borderRadius: BorderRadius.circular(13.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }



  Widget buildInteractiveBody() {
    double leftOffset = widget.viewRegime ? 10.0 : 0.0;
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = constraints.maxHeight + 70;

          // Размеры суставов
          double heightMainJoints = 0.024;
          double heightHandFingersJoints = 0.009;
          double heightLegFingersJoints = 0.006;

          // Размер рамки для выбранных суставов
          double borderWidthHandFingersJoints = 0.7;
          double borderWidthLegFingersJoints = 0.45;

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

              _bodyPart(0, 'assets/body.svg',
                  top: screenHeight * 0.02,
                  left: screenHeight * 0.16 - leftOffset,
                  height: screenHeight * 0.83),
              _bodyPart(1, _btnPath,
                  top: screenHeight * 0.08,
                  left: screenHeight * 0.286 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(2, _btnPath,
                  top: screenHeight * 0.08,
                  left: screenHeight * 0.346 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(3, _btnPath,
                  top: screenHeight * 0.125,
                  left: screenHeight * 0.298 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(4, _btnPath,
                  top: screenHeight * 0.125,
                  left: screenHeight * 0.335 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(5, _btnPath,
                  top: screenHeight * 0.14,
                  left: screenHeight * 0.272 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(6, _btnPath,
                  top: screenHeight * 0.14,
                  left: screenHeight * 0.361 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(7, _btnPath,
                  top: screenHeight * 0.15,
                  left: screenHeight * 0.245 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(8, _btnPath,
                  top: screenHeight * 0.15,
                  left: screenHeight * 0.3885 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(9, _btnPath,
                  top: screenHeight * 0.26,
                  left: screenHeight * 0.224 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(10, _btnPath,
                  top: screenHeight * 0.26,
                  left: screenHeight * 0.409 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(11, _btnPath,
                  top: screenHeight * 0.365,
                  left: screenHeight * 0.193 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(12, _btnPath,
                  top: screenHeight * 0.365,
                  left: screenHeight * 0.44 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(13, _btnPath,
                  top: screenHeight * 0.402,
                  left: screenHeight * 0.1685 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(14, _btnPath,
                  top: screenHeight * 0.402,
                  left: screenHeight * 0.479 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(15, _btnPath,
                  top: screenHeight * 0.417,
                  left: screenHeight * 0.174 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(16, _btnPath,
                  top: screenHeight * 0.417,
                  left: screenHeight * 0.4745 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(17, _btnPath,
                  top: screenHeight * 0.42,
                  left: screenHeight * 0.183 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(18, _btnPath,
                  top: screenHeight * 0.42,
                  left: screenHeight * 0.465 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(19, _btnPath,
                  top: screenHeight * 0.4239,
                  left: screenHeight * 0.1915 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(20, _btnPath,
                  top: screenHeight * 0.4239,
                  left: screenHeight * 0.4558 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(21, _btnPath,
                  top: screenHeight * 0.425,
                  left: screenHeight * 0.201 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(22, _btnPath,
                  top: screenHeight * 0.425,
                  left: screenHeight * 0.4465 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(23, _btnPath,
                  top: screenHeight * 0.4115,
                  left: screenHeight * 0.162 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(24, _btnPath,
                  top: screenHeight * 0.4115,
                  left: screenHeight * 0.487 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(25, _btnPath,
                  top: screenHeight * 0.429,
                  left: screenHeight * 0.169 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(26, _btnPath,
                  top: screenHeight * 0.429,
                  left: screenHeight * 0.48 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(27, _btnPath,
                  top: screenHeight * 0.435,
                  left: screenHeight * 0.179 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(28, _btnPath,
                  top: screenHeight * 0.435,
                  left: screenHeight * 0.469 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(29, _btnPath,
                  top: screenHeight * 0.436,
                  left: screenHeight * 0.19 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(30, _btnPath,
                  top: screenHeight * 0.436,
                  left: screenHeight * 0.458 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(31, _btnPath,
                  top: screenHeight * 0.435,
                  left: screenHeight * 0.201 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(32, _btnPath,
                  top: screenHeight * 0.435,
                  left: screenHeight * 0.447 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(33, _btnPath,
                  top: screenHeight * 0.438,
                  left: screenHeight * 0.164 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(34, _btnPath,
                  top: screenHeight * 0.438,
                  left: screenHeight * 0.485 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(35, _btnPath,
                  top: screenHeight * 0.446,
                  left: screenHeight * 0.1755 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(36, _btnPath,
                  top: screenHeight * 0.446,
                  left: screenHeight * 0.473 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(37, _btnPath,
                  top: screenHeight * 0.448,
                  left: screenHeight * 0.188 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(38, _btnPath,
                  top: screenHeight * 0.448,
                  left: screenHeight * 0.46 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(39, _btnPath,
                  top: screenHeight * 0.445,
                  left: screenHeight * 0.2016 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(40, _btnPath,
                  top: screenHeight * 0.445,
                  left: screenHeight * 0.446 - leftOffset,
                  height: screenHeight * heightHandFingersJoints,
                  borderWidth: borderWidthHandFingersJoints),
              _bodyPart(41, _btnPath,
                  top: screenHeight * 0.4,
                  left: screenHeight * 0.278 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(42, _btnPath,
                  top: screenHeight * 0.4,
                  left: screenHeight * 0.355 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(43, _btnPath,
                  top: screenHeight * 0.57,
                  left: screenHeight * 0.275 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(44, _btnPath,
                  top: screenHeight * 0.57,
                  left: screenHeight * 0.358 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(45, _btnPath,
                  top: screenHeight * 0.75,
                  left: screenHeight * 0.283 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(46, _btnPath,
                  top: screenHeight * 0.75,
                  left: screenHeight * 0.35 - leftOffset,
                  height: screenHeight * heightMainJoints),
              _bodyPart(47, _btnPath,
                  top: screenHeight * 0.78,
                  left: screenHeight * 0.285 - leftOffset,
                  height: screenHeight * 0.019),
              _bodyPart(48, _btnPath,
                  top: screenHeight * 0.78,
                  left: screenHeight * 0.352 - leftOffset,
                  height: screenHeight * 0.019),
              _bodyPart(49, _btnPath,
                  top: screenHeight * 0.805,
                  left: screenHeight * 0.282 - leftOffset,
                  height: screenHeight * 0.019),
              _bodyPart(50, _btnPath,
                  top: screenHeight * 0.805,
                  left: screenHeight * 0.355 - leftOffset,
                  height: screenHeight * 0.019),
              _bodyPart(51, _btnPath,
                  top: screenHeight * 0.834,
                  left: screenHeight * 0.299 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(52, _btnPath,
                  top: screenHeight * 0.834,
                  left: screenHeight * 0.3515 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(53, _btnPath,
                  top: screenHeight * 0.832,
                  left: screenHeight * 0.2926 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(54, _btnPath,
                  top: screenHeight * 0.832,
                  left: screenHeight * 0.358 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(55, _btnPath,
                  top: screenHeight * 0.83,
                  left: screenHeight * 0.286 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(56, _btnPath,
                  top: screenHeight * 0.83,
                  left: screenHeight * 0.3645 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(57, _btnPath,
                  top: screenHeight * 0.828,
                  left: screenHeight * 0.2795 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(58, _btnPath,
                  top: screenHeight * 0.828,
                  left: screenHeight * 0.3711 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(59, _btnPath,
                  top: screenHeight * 0.826,
                  left: screenHeight * 0.2733 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(60, _btnPath,
                  top: screenHeight * 0.826,
                  left: screenHeight * 0.3775 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(61, _btnPath,
                  top: screenHeight * 0.841,
                  left: screenHeight * 0.2965 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(62, _btnPath,
                  top: screenHeight * 0.841,
                  left: screenHeight * 0.355 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(63, _btnPath,
                  top: screenHeight * 0.839,
                  left: screenHeight * 0.29 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(64, _btnPath,
                  top: screenHeight * 0.839,
                  left: screenHeight * 0.361 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(65, _btnPath,
                  top: screenHeight * 0.837,
                  left: screenHeight * 0.284 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(66, _btnPath,
                  top: screenHeight * 0.837,
                  left: screenHeight * 0.367 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(67, _btnPath,
                  top: screenHeight * 0.835,
                  left: screenHeight * 0.2779 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(68, _btnPath,
                  top: screenHeight * 0.835,
                  left: screenHeight * 0.373 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(69, _btnPath,
                  top: screenHeight * 0.833,
                  left: screenHeight * 0.272 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(70, _btnPath,
                  top: screenHeight * 0.833,
                  left: screenHeight * 0.379 - leftOffset,
                  height: screenHeight * heightLegFingersJoints,
                  borderWidth: borderWidthLegFingersJoints),
              _bodyPart(71, _btnPath1,
                  top: screenHeight * 0.1,
                  left: screenHeight * 0.32 - leftOffset,
                  height: screenHeight * 0.03),
              _bodyPart(72, _btnPath4,
                  top: screenHeight * 0.15,
                  left: screenHeight * 0.32 - leftOffset,
                  height: screenHeight * 0.14),
              _bodyPart(73, _btnPath3,
                  top: screenHeight * 0.31,
                  left: screenHeight * 0.32 - leftOffset,
                  height: screenHeight * 0.086),
              _bodyPart(74, _btnPath2,
                  top: screenHeight * 0.33,
                  left: screenHeight * 0.29 - leftOffset,
                  height: screenHeight * 0.046),
              _bodyPart(75, _btnPath2,
                  top: screenHeight * 0.33,
                  left: screenHeight * 0.35 - leftOffset,
                  height: screenHeight * 0.046),
            ],
          );
        },
      ),
    );
  }


}







