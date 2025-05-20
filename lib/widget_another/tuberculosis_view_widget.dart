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


    String comma = '';
    if (widget.thisData.drugs != null) {
      for (int i = 0; i < widget.thisData.drugs!.length; i++) {
        comma = i > 0 ? ', ' : '';
        if (widget.thisData.drugs![i].name != null) {
          drugs += comma + widget.thisData.drugs![i].name!.replaceAll('\n', '').trim();
        }
      }
    }

    if (widget.thisData.sideEffects != null) {
      for (int i = 0; i < widget.thisData.sideEffects!.length; i++) {
        comma = i > 0 ? ', ' : '';
        if (widget.thisData.sideEffects![i].name != null) {
          sideEffects += comma + widget.thisData.sideEffects![i].name!.replaceAll('\n', '').trim();
        }
      }
      if (widget.thisData.customSideEffects != null &&
          widget.thisData.customSideEffects!.isNotEmpty) {
        customSideEffects = widget.thisData.customSideEffects![0];
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
