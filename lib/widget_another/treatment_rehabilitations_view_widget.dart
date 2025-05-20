import 'package:artrit/data/data_treatment_rehabilitations.dart';
import 'package:flutter/material.dart';
import 'label_join_widget.dart';

class TreatmentRehabilitationsViewWidget extends StatefulWidget {
  final DataTreatmentRehabilitations thisData;

  const TreatmentRehabilitationsViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  State<TreatmentRehabilitationsViewWidget> createState() =>
      TreatmentRehabilitationsViewWidgetState();
}

class TreatmentRehabilitationsViewWidgetState
    extends State<TreatmentRehabilitationsViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.thisData.typeRehabil!.type == 'Физиотерапия')
        LabelJoinWidget(
          labelText: 'Название процедуры',
          value: widget.thisData.typeRehabil != null ? widget.thisData.typeRehabil!.fizcomment ?? '' : '',
        ),
      ],
    );
  }
}
