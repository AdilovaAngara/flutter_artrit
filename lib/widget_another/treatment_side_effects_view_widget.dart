import 'package:artrit/data/data_treatment_side_effects.dart';
import 'package:flutter/material.dart';
import 'label_join_widget.dart';

class TreatmentSideEffectsViewWidget extends StatefulWidget {
  final DataTreatmentSideEffects thisData;

  const TreatmentSideEffectsViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  State<TreatmentSideEffectsViewWidget> createState() =>
      TreatmentSideEffectsViewWidgettState();
}

class TreatmentSideEffectsViewWidgettState
    extends State<TreatmentSideEffectsViewWidget> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Лечение нежелательного явления',
          value: widget.thisData.treatAdvEv,
        ),
        LabelJoinWidget(
          labelText: 'Исход лечения',
          value: widget.thisData.treatOut,
        ),
        LabelJoinWidget(
          labelText: 'Комментарий',
          value: widget.thisData.comment,
        ),
      ],
    );
  }
}
