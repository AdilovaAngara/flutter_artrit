import 'package:flutter/material.dart';
import '../data/data_tuberculosis.dart';
import 'label_join_widget.dart';

class TuberculosisViewWidget extends StatefulWidget {
  final DataTuberculosis thisData;

  const TuberculosisViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  TuberculosisViewWidgetState createState() => TuberculosisViewWidgetState();
}

class TuberculosisViewWidgetState extends State<TuberculosisViewWidget> {
  @override
  Widget build(BuildContext context) {
    String drugs = '';
    String sideEffects = '';
    String? customSideEffects;

    drugs = widget.thisData.drugs!
        .map((drug) => drug.name.replaceAll('\n', '').trim())
        .join(', ');

    if (widget.thisData.sideEffects != null) {
      sideEffects = widget.thisData.sideEffects!
          .map((effect) => effect.name.replaceAll('\n', '').trim())
          .join(', ');

      if (widget.thisData.customSideEffects.isNotEmpty) {
        customSideEffects = widget.thisData.customSideEffects[0];
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Лекарственные препараты',
          value: drugs,
        ),
        LabelJoinWidget(
          labelText: 'Нежелательные явления',
          value: sideEffects,
        ),
        if (customSideEffects != null && customSideEffects.isNotEmpty)
          LabelJoinWidget(
          labelText: 'Другие нежелательные явления',
          value: customSideEffects,
        ),
      ],
    );
  }
}
