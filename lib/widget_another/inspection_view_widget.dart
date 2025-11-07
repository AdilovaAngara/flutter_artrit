import 'package:artrit/widgets/scale.dart';
import 'package:flutter/material.dart';
import '../data/data_dynamic.dart';
import '../data/data_inspections.dart';
import '../data/data_inspections_photo.dart';
import '../my_functions.dart';
import '../pages/page_inspections_angles_photo_view.dart';
import '../pages/page_inspections_joint_syndrome.dart';
import '../pages/page_inspections_limph.dart';
import '../pages/page_inspections_rash.dart';
import '../pages/page_inspections_uveit.dart';
import 'label_join_widget.dart';


class InspectionViewWidget extends StatefulWidget {
  final DataInspections thisData;
  final List<DataInspections> allData;
  final List<DataInspectionsPhoto>? allDataPhoto;
  final double doubleAge;
  final int role;

  const InspectionViewWidget({
    super.key,
    required this.thisData,
    required this.allData,
    required this.allDataPhoto,
    required this.doubleAge,
    required this.role,
  });

  @override
  InspectionViewWidgetState createState() => InspectionViewWidgetState();
}


class NormaItem {
  double minAge;
  double maxAge;
  dynamic minValue;
  dynamic maxValue;

  NormaItem({
    required this.minAge,
    required this.maxAge,
    required this.minValue,
    required this.maxValue,
  });
}



class InspectionViewWidgetState extends State<InspectionViewWidget> {

  final List<NormaItem> _chssNormaItem = [
    NormaItem(minAge: 0.0, maxAge: 0.6, minValue: 140, maxValue: 160),
    NormaItem(minAge: 0.6, maxAge: 1.0, minValue: 130, maxValue: 135),
    NormaItem(minAge: 1, maxAge: 2, minValue: 120, maxValue: 125),
    NormaItem(minAge: 2, maxAge: 3, minValue: 110, maxValue: 115),
    NormaItem(minAge: 3, maxAge: 5, minValue: 105, maxValue: 110),
    NormaItem(minAge: 5, maxAge: 8, minValue: 100, maxValue: 105),
    NormaItem(minAge: 8, maxAge: 10, minValue: 90, maxValue: 100),
    NormaItem(minAge: 10, maxAge: 12, minValue: 80, maxValue: 85),
    NormaItem(minAge: 12, maxAge: 100, minValue: 70, maxValue: 75),
  ];

  final List<NormaItem> _artDavSisNormaItem = [
    NormaItem(minAge: 0.2, maxAge: 1.0, minValue: 100, maxValue: 112),
    NormaItem(minAge: 1, maxAge: 6, minValue: 100, maxValue: 116),
    NormaItem(minAge: 6, maxAge: 10, minValue: 100, maxValue: 122),
    NormaItem(minAge: 10, maxAge: 13, minValue: 110, maxValue: 126),
    NormaItem(minAge: 13, maxAge: 16, minValue: 110, maxValue: 136),
  ];

  final List<NormaItem> _artDavDiaNormaItem = [
    NormaItem(minAge: 0.2, maxAge: 1.0, minValue: 60, maxValue: 74),
    NormaItem(minAge: 1, maxAge: 6, minValue: 60, maxValue: 76),
    NormaItem(minAge: 6, maxAge: 10, minValue: 60, maxValue: 78),
    NormaItem(minAge: 10, maxAge: 13, minValue: 70, maxValue: 82),
    NormaItem(minAge: 13, maxAge: 16, minValue: 70, maxValue: 86),
  ];



  bool _getNormaChss(int value) {
    double doubleAge = widget.doubleAge;
    return _chssNormaItem.any((e) => e.minAge <= doubleAge && e.maxAge >= doubleAge && e.minValue <= value && e.maxValue >= value);
  }

  bool _getNormaartDav(int sis, int dia) {
    double doubleAge = widget.doubleAge;
    return _artDavSisNormaItem.any((e) => e.minAge <= doubleAge && e.maxAge >= doubleAge && e.minValue <= sis && e.maxValue >= sis) &&
        _artDavDiaNormaItem.any((e) => e.minAge <= doubleAge && e.maxAge >= doubleAge && e.minValue <= dia && e.maxValue >= dia);
  }





  @override
  Widget build(BuildContext context) {
    int acheLevel = widget.thisData.ocbol;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Уровень боли',
          value: acheLevel,
          showValue: false,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Уровень боли',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.ocbol,
                    unit: '%',
                    isNorma: item.ocbol < 30 ? true : false
                );
              }).toList(),
            );
          },
        ),
        ColorScaleIndicator(value: acheLevel),
        SizedBox(height: 15),
        LabelJoinWidget(
          labelText: 'Температура',
          value: widget.thisData.tem,
          unit: '\u00B0C',
          isNorma: widget.thisData.tem == null ? true : widget.thisData.tem! >= 35.5 && widget.thisData.tem! <= 37.5 ? true : false,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Температура',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.tem,
                    unit: '\u00B0C',
                    isNorma: item.tem == null ? true : item.tem! >= 35.5 && item.tem! <= 37.5 ? true : false,
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: 'ЧСС',
          value: widget.thisData.chss,
          unit: 'уд./мин.',
          isNorma: widget.thisData.chss == null ? true : _getNormaChss(widget.thisData.chss!),
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'ЧСС',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.chss,
                    unit: 'уд./мин.',
                    isNorma: item.chss == null ? true : _getNormaChss(item.chss!),
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: 'Давление',
          value: formatArdavSisDia(widget.thisData.ardav),
          unit: 'мм.рт.ст.',
          isNorma: (widget.thisData.ardav.sis == null || widget.thisData.ardav.dia == null || widget.thisData.ardav.sis == 0) ? true : _getNormaartDav(widget.thisData.ardav.sis ?? 0, widget.thisData.ardav.dia ?? 0),
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Давление',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.ardav.sis == 0 ? null : item.ardav.sis,
                    visibleValue: formatArdavSisDia(item.ardav),
                    unit: 'мм.рт.ст.',
                    isNorma: (item.ardav.sis == null || item.ardav.dia == null || item.ardav.sis == 0) ? true : _getNormaartDav(item.ardav.sis ?? 0, item.ardav.dia ?? 0),
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: 'Уренняя скованность',
          value: widget.thisData.utscov,
          unit: 'мин.',
          isNorma: widget.thisData.utscov == null ? true : widget.thisData.utscov! < 15 ? true : false,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Уренняя скованность',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.utscov,
                    unit: 'мин.',
                    isNorma: item.utscov == null ? true : item.utscov! < 15 ? true : false
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: 'Увеит',
          value: widget.thisData.uveit != null ? 'Присутствует' : 'Отсутствует',
          isNorma: widget.thisData.uveit != null ? false : true,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Увеит',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                  date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                  value: 1.0,
                  visibleValue: item.uveit != null ? 'Присутствует' : 'Отсутствует',
                  unit: null,
                  isNorma: item.uveit != null ? false : true,
                );
              }).toList(),
            );
          },
          onPressedView: widget.thisData.uveit != null ? () {
            navigateToPage(
              context,
              PageInspectionsUveit(
                uveit: widget.thisData.uveit,
                role: widget.role,
                viewRegime: true,
              ),
            );
          }  : null,
        ),
        LabelJoinWidget(
          labelText: 'Сыпь',
          value: widget.thisData.sip != null && widget.thisData.sip! > 0 ? 'Присутствует' : 'Отсутствует',
          isNorma: widget.thisData.sip != null && widget.thisData.sip! > 0 ? false : true,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Сыпь',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                  date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                  value: item.sip!,
                  visibleValue: item.sip != null && item.sip! > 0 ? 'Присутствует' : 'Отсутствует',
                  showBothValue: true,
                  unit: null,
                  isNorma: item.sip != null && item.sip! > 0 ? false : true,
                  info: 'Числовое значение отображает количество участков кожи, покрытых сыпью',
                );
              }).toList(),
            );
          },
          onPressedView: widget.thisData.sip != null && widget.thisData.sip! > 0 ? () {
            navigateToPage(
              context,
              PageInspectionsRash(
                siplist: widget.thisData.siplist,
                inspectionsId: widget.thisData.id ?? '',
                viewRegime: true,
              ),
            );
          }  : null,
        ),
        LabelJoinWidget(
          labelText: 'Увеличенные лимфоузлы',
          value: widget.thisData.uvellim != null && widget.thisData.uvellim! > 0 ? 'Присутствуют' : 'Отсутствуют',
          isNorma: widget.thisData.uvellim != null && widget.thisData.uvellim! > 0 ? false : true,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Увеличенные лимфоузлы',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                  date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                  value: item.uvellim!,
                  visibleValue: item.uvellim != null && item.uvellim! > 0 ? 'Присутствуют' : 'Отсутствуют',
                  showBothValue: true,
                  unit: null,
                  isNorma: item.uvellim != null && item.uvellim! > 0 ? false : true,
                  info: 'Числовое значение отображает количество увеличенных лимфоузлов',
                );
              }).toList(),
            );
          },
          onPressedView: widget.thisData.uvellim != null && widget.thisData.uvellim! > 0 ? () {
            navigateToPage(
              context,
              PageInspectionsLimph(
                listSyssind: widget.thisData.syssind2,
                viewRegime: true,
                role: widget.role,
              ),
            );
          }  : null,
        ),
        LabelJoinWidget(
          labelText: 'Суставной синдром',
          value: widget.thisData.joints.isNotEmpty ? 'Присутствует' : 'Отсутствует',
          isNorma: widget.thisData.joints.isNotEmpty ? false : true,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Суставной синдром',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                  date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                  value: item.joints.length,
                  visibleValue: item.joints.isNotEmpty ? 'Присутствует' : 'Отсутствует',
                  showBothValue: true,
                  unit: null,
                  isNorma: item.joints.isNotEmpty ? false : true,
                  info: 'Числовое значение отображает количество болезненных, припухших или ограниченных в движении суставов',
                );
              }).toList(),
            );
          },
          onPressedView: widget.thisData.joints.isNotEmpty ? () {
            navigateToPage(
              context,
              PageInspectionsJointSyndrome(
                joints: widget.thisData.joints,
                inspectionsId: widget.thisData.id ?? '',
                viewRegime: true,
              ),
            );
          }  : null,
        ),
        LabelJoinWidget(
          labelText: 'Измерение углов',
          value: widget.allDataPhoto != null ? widget.allDataPhoto!.where((e) => e.inspectionId == widget.thisData.id).length : 0,
          unit: 'фото',
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: 'Измерение углов',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                  date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                  value: widget.allDataPhoto != null ? widget.allDataPhoto!.where((e) => e.inspectionId == item.id).length : 0,
                  unit: 'фото',
                  isNorma: null,
                );
              }).toList(),
            );
          },
          onPressedView: widget.allDataPhoto != null && widget.allDataPhoto!.where((e) => e.inspectionId == widget.thisData.id).isNotEmpty ? () {
            navigateToPage(
              context,
              PageInspectionsAnglesPhotoView(
                cornersTitle: 'Измерение углов',
                thisData: widget.allDataPhoto != null ? widget.allDataPhoto!.where((e) => e.inspectionId == widget.thisData.id).toList() : [],
              ),
            );
          }  : null,
        ),

      ],
    );
  }


}
