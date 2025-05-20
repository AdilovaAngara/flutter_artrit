import 'package:artrit/data/data_researches_tuberculin.dart';
import 'package:flutter/material.dart';
import '../my_functions.dart';
import 'label_join_widget.dart';

class TuberculinViewWidget extends StatefulWidget {
  final DataResearchesTuberculin thisData;

  const TuberculinViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  TuberculinViewWidgetState createState() => TuberculinViewWidgetState();
}

class TuberculinViewWidgetState extends State<TuberculinViewWidget> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Результат',
          value: widget.thisData.result != null ? widget.thisData.result!.name ?? '' : '',
        ),
        if (widget.thisData.result != null && ['Гиперемия', 'Папула', 'Положительный'].contains(widget.thisData.result!.name))
          LabelJoinWidget(
          labelText: 'Значение',
          value: formatDouble(widget.thisData.value),
          unit: 'мм',
        ),
      ],
    );
  }
}
