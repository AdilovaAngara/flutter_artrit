import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../data/data_inspections.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';

class PageInspectionsLimph extends StatefulWidget {
  final List<Syssind> listSyssind;
  final bool viewRegime;
  final int role;

  const PageInspectionsLimph({
    super.key,
    required this.listSyssind,
    required this.viewRegime,
    required this.role
  });

  @override
  State<PageInspectionsLimph> createState() => PageInspectionsLimphState();
}

class PageInspectionsLimphState extends State<PageInspectionsLimph> {
  late List<Syssind> _listSyssind;
  String btnPath = 'assets/radioBtn.svg';

  @override
  void initState() {
    // Если будем делать так, то при клике "Назад" передаются изменения
    //_listSyssind = widget.listSyssind;
    // Поэтому делаем глубокую копию списка
    _listSyssind = widget.listSyssind.map((syssind) => Syssind(
      name: syssind.name,
      isActive: syssind.isActive,
    )).toList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Лимфоузлы',
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () { onBack(context, (areDifferent(widget.listSyssind, _listSyssind))); },
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                panEnabled: true, // Включает возможность перетаскивания
                boundaryMargin: EdgeInsets.all(20.0),
                minScale: 0.5,
                maxScale: 4.0,
                child: buildInteractiveBody(),
              ),
            ),
          ),
          if (!widget.viewRegime)
          Container(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: ButtonWidget(
                labelText: 'Применить',
                listRoles: Roles.asPatient,
                role: widget.role,
                onPressed: () {
                  Navigator.pop(context, _listSyssind); // Передача значения назад
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInteractiveBody() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double fullScreenHeight = MediaQuery.of(context).size.height;
          double safePadding = MediaQuery.of(context).padding.top +
              MediaQuery.of(context).padding.bottom;

          double appBarHeight = kToolbarHeight;
          double buttonHeight = 50.0;
          double extraPadding = 10.0;

          double fixedElementsHeight = appBarHeight +
              buttonHeight +
              extraPadding;
          final double screenHeight =
              fullScreenHeight - safePadding - fixedElementsHeight;

          return Stack(
            alignment: Alignment.center,
            children: [
              _bodyPart('body', 'assets/body.svg',
                  top: screenHeight * 0.02,
                  left: screenHeight * 0.085,
                  height: screenHeight * 0.8),
              _bodyPart('шейный левый', btnPath,
                  top: screenHeight * 0.11,
                  left: screenHeight * 0.25,
                  height: screenHeight * 0.024),
              _bodyPart('шейный правый', btnPath,
                  top: screenHeight * 0.11,
                  left: screenHeight * 0.22,
                  height: screenHeight * 0.024),
              _bodyPart('подмышечный левый', btnPath,
                  top: screenHeight * 0.18,
                  left: screenHeight * 0.295,
                  height: screenHeight * 0.024),
              _bodyPart('подмышечный правый', btnPath,
                  top: screenHeight * 0.18,
                  left: screenHeight * 0.175,
                  height: screenHeight * 0.024),
              _bodyPart('локтевой левый', btnPath,
                  top: screenHeight * 0.26,
                  left: screenHeight * 0.328,
                  height: screenHeight * 0.024),
              _bodyPart('локтевой правый', btnPath,
                  top: screenHeight * 0.26,
                  left: screenHeight * 0.143,
                  height: screenHeight * 0.024),
              _bodyPart('паховый левый', btnPath,
                  top: screenHeight * 0.38,
                  left: screenHeight * 0.252,
                  height: screenHeight * 0.024),
              _bodyPart('паховый правый', btnPath,
                  top: screenHeight * 0.38,
                  left: screenHeight * 0.22,
                  height: screenHeight * 0.024),
              _bodyPart('подколенный левый', btnPath,
                  top: screenHeight * 0.55,
                  left: screenHeight * 0.276,
                  height: screenHeight * 0.024),
              _bodyPart('подколенный правый', btnPath,
                  top: screenHeight * 0.55,
                  left: screenHeight * 0.195,
                  height: screenHeight * 0.024),
            ],
          );
        },
      ),
    );
  }

  void _togglePart(String part) {
    setState(() {
      if (part != 'body')
        {
          Syssind? syssind = _listSyssind.firstWhereOrNull((item) => item.name == part);
          if (syssind == null) return;
          if (syssind.isActive) {
            syssind.isActive = false;
          } else {
            syssind.isActive = true;
          }
        }
    });
  }

  bool partActive(String part) {
    if (part == 'body') {
      return false;
    }
    Syssind? syssind = _listSyssind.firstWhereOrNull((item) => item.name == part);
    if (syssind == null) {
      return false;
    } else {
      return syssind.isActive;
    }
  }

  Widget _bodyPart(
      String part,
      String imagePath, {
        double? top,
        double? bottom,
        double? left,
        double? right,
        double? width,
        double? height,
      }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: () => !widget.viewRegime ? _togglePart(part) : null,
        child: ColorFiltered(
          colorFilter: partActive(part)
              ? ColorFilter.mode(Colors.red.shade300, BlendMode.srcATop)
              : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
          child: SvgPicture.asset(
            imagePath,
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}





