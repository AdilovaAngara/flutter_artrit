import 'package:flutter/material.dart';
import '../roles.dart';
import '../theme.dart';
import '../widgets/switch_widget.dart';
import '../widgets/tooltip_widget.dart';

class PhotoRegimeWidget extends StatelessWidget {
  final bool isPhotoRegime;
  final String label;
  final ValueChanged<bool> onChanged;

  const PhotoRegimeWidget({
    super.key,
    required this.isPhotoRegime,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    RichText infoIconText = RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(
              Icons.looks_one_rounded,
              size: 17,
              color: Colors.green,
            ),
          ),
          if (label == 'Сыпь' ) const TextSpan(
            text: ' Нельзя удалить сыпь с участка кожи, к которому привязана хотя бы одна фотография.\n\n',
            style: labelStyle,
          ),
          if (label == 'Суставы' ) const TextSpan(
            text: ' Нельзя снять все галочки с сустава, к которому привязана хотя бы одна фотография.\n\n',
            style: labelStyle,
          ),
          WidgetSpan(
            child: Icon(
              Icons.looks_two_rounded,
              size: 17,
              color: Colors.green,
            ),
          ),
          if (label == 'Сыпь' ) const TextSpan(
            text: ' Добавление фотографий доступно только для участков кожи, покрытых сыпью.\n\n',
            style: labelStyle,
          ),
          if (label == 'Суставы' ) const TextSpan(
            text: ' Добавление фотографий доступно только для суставов, которые имеют галочку хотя бы в одном из пунктов (болезненные, припухшие и ограниченные в движении).\n\n',
            style: labelStyle,
          ),
          WidgetSpan(
            child: Icon(
              Icons.looks_3_rounded,
              size: 17,
              color: Colors.green,
            ),
          ),
          const TextSpan(
            text: ' Удаление фотографии доступно в течение суток с момента ее добавления.',
            style: labelStyle,
          ),
        ],
      ),
    );



    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 0.0),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            color: isPhotoRegime
                ? Colors.grey
                : Colors.purple.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchWidget(
            labelTextFirst:
            isPhotoRegime ? 'Режим "Фото"' : 'Режим "$label"',
            labelTextLast: '',
            value: isPhotoRegime,
            style: inputTextStyleWhite,
            listRoles: Roles.all,
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ),
        TooltipWidget(
            richText: infoIconText,
        ),
      ],
    );
   }

}


