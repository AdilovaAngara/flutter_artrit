import 'package:artrit/my_functions.dart';
import 'package:flutter/material.dart';
import '../data/data_treatment_medicaments.dart';
import 'label_join_widget.dart';

class TreatmentMedicamentsViewWidget extends StatefulWidget {
  final DataTreatmentMedicaments thisData;

  const TreatmentMedicamentsViewWidget({
    super.key,
    required this.thisData,
  });

  @override
  State<TreatmentMedicamentsViewWidget> createState() =>
      _TreatmentMedicamentsViewWidgetState();
}

class _TreatmentMedicamentsViewWidgetState
    extends State<TreatmentMedicamentsViewWidget> {
  @override
  Widget build(BuildContext context) {
    List<Skipping>? skippings = widget.thisData.skippings;




    String skippingsText = '';

    String comma = '';
    if (skippings != null) {
      skippings.sort((a, b) {
        if (a.beginDate == null && b.beginDate == null) {
          return 0; // Оба значения null, считаем их равными
        }
        if (a.beginDate == null) {
          return -1; // a.treatmentBeginDate null, считаем его меньше
        }
        if (b.beginDate == null) {
          return 1; // b.treatmentBeginDate null, считаем его больше
        }
        return a.beginDate!.compareTo(b.beginDate!);
      });


      for (int i = 0; i < skippings.length; i++) {
        comma = i > 0 ? '\n' : '';
        if (skippings[i].beginDate != null) {
          skippingsText += '$comma${i+1}) ${dateFormat(skippings[i].beginDate!)}';
        }
        if (skippings[i].endDate != null) {
          skippingsText += ' - ${dateFormat(skippings[i].endDate!)}';
        }
        if (skippings[i].reasonName != null) {
          skippingsText += '\n${skippings[i].reasonName!}';
        }
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'МНН',
          value: widget.thisData.mnn != null ? widget.thisData.mnn! : '',
        ),
        LabelJoinWidget(
          labelText: 'Форма выпуска',
          value: widget.thisData.tlf,
        ),
        LabelJoinWidget(
          labelText: 'Дозировка',
          value: '${formatDouble(widget.thisData.srd)} ${widget.thisData.ei} ${widget.thisData.krat}',
        ),
        LabelJoinWidget(
          labelText: 'Путь введения',
          value: widget.thisData.pv,
        ),
        LabelJoinWidget(
          labelText: 'Причина окончания приема',
          value: widget.thisData.pop,
        ),
        LabelJoinWidget(
          labelText: 'Обеспечение лекарствами',
          value: widget.thisData.obesplek,
        ),
        LabelJoinWidget(
          labelText: 'Пропуск приема лекарства',
          value: skippingsText,
        ),
      ],
    );
  }
}
