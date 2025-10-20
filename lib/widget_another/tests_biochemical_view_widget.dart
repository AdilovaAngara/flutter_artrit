import 'package:flutter/material.dart';
import '../data/data_dynamic.dart';
import '../data/data_tests_biochemical_list.dart';
import '../my_functions.dart';
import 'label_join_widget.dart';


class TestsBiochemicalViewWidget extends StatefulWidget {
  final DataTestsBiochemicalList thisData;
  final List<DataTestsBiochemicalList> allData;

  const TestsBiochemicalViewWidget({
    super.key,
    required this.thisData,
    required this.allData,
  });

  @override
  TestsBiochemicalViewWidgetState createState() => TestsBiochemicalViewWidgetState();
}

class TestsBiochemicalViewWidgetState extends State<TestsBiochemicalViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: widget.thisData.astName ?? 'АСТ',
          value: formatDouble(widget.thisData.ast),
          unit: widget.thisData.astUnit,
          isNorma: widget.thisData.asTnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.astName ?? 'АСТ',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.ast,
                    unit: item.astUnit,
                    isNorma: item.asTnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.altName ?? 'АЛТ',
          value: formatDouble(widget.thisData.alt),
          unit: widget.thisData.altUnit,
          isNorma: widget.thisData.alTnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.altName ?? 'АЛТ',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.alt,
                    unit: item.altUnit,
                    isNorma: item.alTnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.bilirubinTotalName ?? 'Общий билирубин',
          value: formatDouble(widget.thisData.bilirubinTotal),
          unit: widget.thisData.bilirubinTotalUnit,
          isNorma: widget.thisData.bilirubinTotalnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.bilirubinTotalName ?? 'Общий билирубин',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.bilirubinTotal,
                    unit: item.bilirubinTotalUnit,
                    isNorma: item.bilirubinTotalnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.mochevinaName ?? 'Мочевина',
          value: formatDouble(widget.thisData.mochevina),
          unit: widget.thisData.mochevinaUnit,
          isNorma: widget.thisData.mochevinanorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.mochevinaName ?? 'Мочевина',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.mochevina,
                    unit: item.mochevinaUnit,
                    isNorma: item.mochevinanorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.creatinineName ?? 'Креатинин',
          value: formatDouble(widget.thisData.creatinine),
          unit: widget.thisData.creatinineUnit,
          isNorma: widget.thisData.creatininenorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.creatinineName ?? 'Креатинин',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.creatinine,
                    unit: item.creatinineUnit,
                    isNorma: item.creatininenorma
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
