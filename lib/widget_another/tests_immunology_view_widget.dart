import 'package:artrit/data/data_tests_immunology_list.dart';
import 'package:flutter/material.dart';
import '../data/data_dynamic.dart';
import '../my_functions.dart';
import 'label_join_widget.dart';


class TestsImmunologyViewWidget extends StatefulWidget {
  final DataTestsImmunologyList thisData;
  final List<DataTestsImmunologyList> allData;

  const TestsImmunologyViewWidget({
    super.key,
    required this.thisData,
    required this.allData,
  });

  @override
  TestsImmunologyViewWidgetState createState() => TestsImmunologyViewWidgetState();
}

class TestsImmunologyViewWidgetState extends State<TestsImmunologyViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: widget.thisData.cReactiveProteinName ?? 'С-реактивный белок',
          value: formatDouble(widget.thisData.cReactiveProtein),
          unit: widget.thisData.cReactiveProteinUnit,
          isNorma: widget.thisData.cReactiveProteinnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.cReactiveProteinName ?? 'С-реактивный белок',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: converStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.cReactiveProtein,
                    unit: item.cReactiveProteinUnit,
                    isNorma: item.cReactiveProteinnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.antinuclearFactorName ?? 'Антинуклеарный фактор, 1',
          value: formatDouble(widget.thisData.antinuclearFactor),
          unit: widget.thisData.antinuclearFactorUnit,
          isNorma: widget.thisData.antinuclearFactornorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.antinuclearFactorName ?? 'Антинуклеарный фактор, 1',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: converStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.antinuclearFactor,
                    unit: item.antinuclearFactorUnit,
                    isNorma: item.antinuclearFactornorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.rheumatoidFactorName ?? 'Ревматоидный фактор',
          value: formatDouble(widget.thisData.rheumatoidFactor),
          unit: widget.thisData.rheumatoidFactorUnit,
          isNorma: widget.thisData.rheumatoidFactornorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.rheumatoidFactorName ?? 'Ревматоидный фактор',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: converStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.rheumatoidFactor,
                    unit: item.rheumatoidFactorUnit,
                    isNorma: item.rheumatoidFactornorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.antiCcpName ?? 'Антитела к циклическому цитруллинированному пептиду',
          value: formatDouble(widget.thisData.antiCcp),
          unit: widget.thisData.antiCcpUnit,
          isNorma: widget.thisData.antiCcPnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.antiCcpName ?? 'Антитела к циклическому цитруллинированному пептиду',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: converStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.antiCcp,
                    unit: item.antiCcpUnit,
                    isNorma: item.antiCcPnorma
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
