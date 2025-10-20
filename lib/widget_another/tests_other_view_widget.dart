import 'package:flutter/material.dart';
import '../data/data_dynamic.dart';
import '../data/data_tests_other.dart';
import '../my_functions.dart';
import 'label_join_widget.dart';

class TestsOtherViewWidget extends StatefulWidget {
  final DataTestsOther thisData;
  final List<DataTestsOther> allData;

  const TestsOtherViewWidget({
    super.key,
    required this.thisData,
    required this.allData,
  });

  @override
  TestsOtherViewWidgetState createState() => TestsOtherViewWidgetState();
}

class TestsOtherViewWidgetState extends State<TestsOtherViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: widget.thisData.analys ?? '',
          value: formatDouble(widget.thisData.znach.num),
          unit: widget.thisData.znach.sel,
          isNorma: widget.thisData.norma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.analys ?? '',
              thisData: widget.allData.where((e) => e.analys == widget.thisData.analys).map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.date!)),
                    value: item.znach.num,
                    unit: item.znach.sel,
                    isNorma: item.norma
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}