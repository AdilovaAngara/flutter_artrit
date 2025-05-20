import 'package:artrit/data/data_anamnesis_concomitants.dart';
import 'package:flutter/material.dart';

import 'label_join_widget.dart';

class AnamnesisConcomitantsViewWidget extends StatefulWidget {
  final DataAnamnesisConcomitants thisData;

  const AnamnesisConcomitantsViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  State<AnamnesisConcomitantsViewWidget> createState() =>
      _AnamnesisConcomitantsViewWidgetState();
}

class _AnamnesisConcomitantsViewWidgetState
    extends State<AnamnesisConcomitantsViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Комментарий',
          value: widget.thisData.comment ?? '',
        ),
      ],
    );
  }
}
