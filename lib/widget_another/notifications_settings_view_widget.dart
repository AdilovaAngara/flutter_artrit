import 'package:artrit/data/data_patients.dart';
import 'package:artrit/my_functions.dart';
import 'package:flutter/material.dart';
import '../data/data_notifications_settings.dart';
import '../data/data_spr_sections.dart';
import 'label_join_widget.dart';

class NotificationsSettingsViewWidget extends StatefulWidget {
  final DataNotificationsSettings thisData;
  final List<DataSprSections> thisSprDataSections;
  final List<DataPatients> thisDataPatients;

  const NotificationsSettingsViewWidget({
    super.key,
    required this.thisData,
    required this.thisSprDataSections,
    required this.thisDataPatients,
  });

  @override
  State<NotificationsSettingsViewWidget> createState() =>
      _AnamnesisConcomitantsViewWidgetState();
}

class _AnamnesisConcomitantsViewWidgetState
    extends State<NotificationsSettingsViewWidget> {
  @override
  Widget build(BuildContext context) {

    // Создаем Map для быстрого поиска
    final sectionMap = {
      for (final section in widget.thisSprDataSections)
        section.id: section.name.replaceAll('\n', '').trim()
    };

    String listSectionNames = widget.thisData.sectionIds!
        .map((sectionId) => sectionMap[sectionId] ?? 'Не указано')
        .where((name) => name.isNotEmpty)
        .join(', ');

    // Создаем Map для быстрого поиска
    final patientMap = {
      for (final p in widget.thisDataPatients)
        p.id: ('${p.lastName} ${p.firstName} ${p.patronymic ?? ''}').replaceAll('\n', '').trim()
    };

    String listPatients = widget.thisData.patientIds!
        .map((patientId) => patientMap[patientId] ?? 'Не указано')
        .where((name) => name.isNotEmpty)
        .join(',\n');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: 'Срок действия',
          value: '${dateFormat(widget.thisData.beginDate)} '
              '- ${dateFormat(widget.thisData.endDate)}',
        ),
        LabelJoinWidget(
          labelText: 'Статус',
          value: widget.thisData.isDisabled ? 'Выключено' : 'Активно'
        ),
        LabelJoinWidget(
          labelText: 'Список разделов',
          value: listSectionNames,
        ),
        LabelJoinWidget(
          labelText: 'Список пациентов',
          value: listPatients,
        ),
      ],
    );
  }
}
