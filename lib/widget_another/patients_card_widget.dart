import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../theme.dart';
import '../widgets/text_view_widget.dart';

class PatientsCardWidget extends StatelessWidget {
  final String lastName;
  final String firstName;
  final String? patronymic;
  final String gender;
  final int? birthDate;
  final dynamic invalid;
  final String? mkbCode;
  final String? mkbName;
  final bool? uveit;
  final int? lastInspectionUveit;



  const PatientsCardWidget({
    super.key,
    required this.lastName,
    required this.firstName,
    required this.patronymic,
    required this.gender,
    required this.birthDate,
    required this.invalid,
    required this.mkbCode,
    required this.mkbName,
    this.uveit,
    this.lastInspectionUveit,
  });

  @override
  Widget build(BuildContext context) {
    bool invalidValue = invalid == 1 ? true : false;
    String uveitValue = uveit == null ? 'Не указан\n' : uveit! ? 'Да\n' : 'Нет\n';
    String lastInspectionUveitValue = lastInspectionUveit == null ? uveitValue : lastInspectionUveit == 1 ? 'Да\n' : 'Нет\n';

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextViewWidget(
                text:
                    '$lastName $firstName ${patronymic ?? ''}',
                style: captionMenuTextStyle,
              ),
            ),
            Icon(
              (gender == 'Мужской' || gender == 'Мужчина')
                  ? Icons.person
                  : Icons.person_2_sharp,
              color: (gender == 'Мужской' || gender == 'Мужчина')
                  ? Colors.blueAccent.shade200
                  : Colors.purple.shade200,
              size: 40,
            ),
          ],
        ),
        Container(
          height: 2,
          color: Colors.grey.shade300,
        ),
        SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Возраст: ',
                style: subtitleTextStyle,
              ),
              TextSpan(
                text: calculateAge(
                    convertTimestampToDate(birthDate), getFullAge: false, getDoubleAge: false),
                style: listLabelStyle,
              ),
              TextSpan(
                text: '   ${convertTimestampToDate(birthDate)} \n',
                style: captionMenuTextStyle,
              ),
              const TextSpan(
                text: 'Инвалидность: ',
                style: subtitleTextStyle,
              ),
              TextSpan(
                text: invalidValue ? 'Да\n' : 'Нет\n',
                style: listLabelStyle,
              ),
              if (uveit != null)
              const TextSpan(
                text: 'Увеит: ',
                style: subtitleTextStyle,
              ),
              if (uveit != null)
              TextSpan(
                text: lastInspectionUveitValue,
                style: listLabelStyle,
              ),
              const TextSpan(
                text: 'Диагноз: ',
                style: subtitleTextStyle,
              ),
              TextSpan(
                text: mkbCode?.trim().replaceAll('\n', ''),
                style: listLabelStylePurple,
              ),
              TextSpan(
                text: ' ${mkbName?.trim().replaceAll('\n', '')}',
                style: listLabelStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
