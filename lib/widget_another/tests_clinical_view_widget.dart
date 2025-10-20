import 'package:artrit/data/data_dynamic.dart';
import 'package:flutter/material.dart';
import '../data/data_tests_clinical_list.dart';
import '../my_functions.dart';
import 'label_join_widget.dart';

class TestsClinicalViewWidget extends StatefulWidget {
  final DataTestsClinicalList thisData;
  final List<DataTestsClinicalList> allData;

  const TestsClinicalViewWidget({
    super.key,
    required this.thisData,
    required this.allData,
  });

  @override
  TestsClinicalViewWidgetState createState() => TestsClinicalViewWidgetState();
}

class TestsClinicalViewWidgetState extends State<TestsClinicalViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelJoinWidget(
          labelText: widget.thisData.thrombocytesName ?? 'Тромбоциты',
          value: formatDouble(widget.thisData.thrombocytes),
          unit: widget.thisData.thrombocytesUnit,
          isNorma: widget.thisData.thrombocytesnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.thrombocytesName ?? 'Тромбоциты',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.thrombocytes,
                    unit: item.thrombocytesUnit,
                    isNorma: item.thrombocytesnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.soeName ?? 'СОЭ',
          value: formatDouble(widget.thisData.soe),
          unit: widget.thisData.soeUnit,
          isNorma: widget.thisData.soEnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.soeName ?? 'СОЭ',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.soe,
                    unit: item.soeUnit,
                    isNorma: item.soEnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.neutrophilsName ?? 'Нейтрофилы',
          value: formatDouble(widget.thisData.neutrophils),
          unit: widget.thisData.neutrophilsUnit,
          isNorma: widget.thisData.neutrophilsnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.neutrophilsName ?? 'Нейтрофилы',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.neutrophils,
                    unit: item.neutrophilsUnit,
                    isNorma: item.neutrophilsnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.monocytesName ?? 'Моноциты',
          value: formatDouble(widget.thisData.monocytes),
          unit: widget.thisData.monocytesUnit,
          isNorma: widget.thisData.monocytesnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.monocytesName ?? 'Моноциты',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.monocytes,
                    unit: item.monocytesUnit,
                    isNorma: item.monocytesnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.eosinophilsName ?? 'Эозинофилы',
          value: formatDouble(widget.thisData.eosinophils),
          unit: widget.thisData.eosinophilsUnit,
          isNorma: widget.thisData.eosinophilsnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.eosinophilsName ?? 'Эозинофилы',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.eosinophils,
                    unit: item.eosinophilsUnit,
                    isNorma: item.eosinophilsnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.erythrocytesName ?? 'Эритроциты',
          value: formatDouble(widget.thisData.erythrocytes),
          unit: widget.thisData.erythrocytesUnit,
          isNorma: widget.thisData.erythrocytesnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.erythrocytesName ?? 'Эритроциты',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.erythrocytes,
                    unit: item.erythrocytesUnit,
                    isNorma: item.erythrocytesnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.hemoglobinName ?? 'Гемоглобин',
          value: formatDouble(widget.thisData.hemoglobin),
          unit: widget.thisData.hemoglobinUnit,
          isNorma: widget.thisData.hemoglobinnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.hemoglobinName ?? 'Гемоглобин',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.hemoglobin,
                    unit: item.hemoglobinUnit,
                    isNorma: item.hemoglobinnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.leukocytesName ?? 'Лейкоциты',
          value: formatDouble(widget.thisData.leukocytes),
          unit: widget.thisData.leukocytesUnit,
          isNorma: widget.thisData.leukocytesnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.leukocytesName ?? 'Лейкоциты',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.leukocytes,
                    unit: item.leukocytesUnit,
                    isNorma: item.leukocytesnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.lymphocytesName ?? 'Лимфоциты',
          value: formatDouble(widget.thisData.lymphocytes),
          unit: widget.thisData.lymphocytesUnit,
          isNorma: widget.thisData.lymphocytesnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.lymphocytesName ?? 'Лимфоциты',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.lymphocytes,
                    unit: item.lymphocytesUnit,
                    isNorma: item.lymphocytesnorma
                );
              }).toList(),
            );
          },
        ),
        LabelJoinWidget(
          labelText: widget.thisData.basophilsName ?? 'Базофилы',
          value: formatDouble(widget.thisData.basophils),
          unit: widget.thisData.basophilsUnit,
          isNorma: widget.thisData.basophilsnorma,
          onPressed: () {
            navigateToPageDynamic(
              context,
              title: widget.thisData.basophilsName ?? 'Базофилы',
              thisData: widget.allData.map((item) {
                return DataDynamic(
                    date: convertStrToDateTime(convertTimestampToDateTime(item.dateNew!)),
                    value: item.basophils,
                    unit: item.basophilsUnit,
                    isNorma: item.basophilsnorma
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
