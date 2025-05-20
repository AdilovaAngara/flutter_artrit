import 'package:flutter/material.dart';
import '../data/data_dynamic.dart';
import '../my_functions.dart';
import '../widgets/app_bar_widget.dart';

class PageDynamic extends StatefulWidget {
  final String title;
  final List<DataDynamic>? thisData;

  const PageDynamic({
    super.key,
    required this.title,
    required this.thisData,
  });

  @override
  State<PageDynamic> createState() => _PageDynamicState();
}

class _PageDynamicState extends State<PageDynamic> {
  @override
  Widget build(BuildContext context) {
    // Фильтруем записи, где value не null
    final filteredData = widget.thisData!.where((item) => item.value != null).toList();

    if (filteredData.isEmpty) {
      return notDataWidget;
    }

    // Находим максимальное значение value для масштабирования столбиков
    final maxValue = filteredData.map((e) => e.value!.toDouble()).reduce((a, b) => a > b ? a : b);

    // Вычисляем максимальную длину текста для каждой колонки
    final maxDateWidth = _calculateMaxTextWidth(
      filteredData.map((item) => dateTimeFormat(item.date) ?? ' - ').toList(),
      const TextStyle(fontSize: 14),
    );
    final maxValueWidth = _calculateMaxTextWidth(
      filteredData.map((item) => _getValueText(item)).toList(),
      const TextStyle(fontSize: 14),
    );
    final maxSecondValueWidth = _calculateMaxTextWidth(
      filteredData
          .where((item) => item.visibleValue != null && item.showBothValue)
          .map((item) => formatDouble(item.value!, fixedCount: 1).toString())
          .toList(),
      const TextStyle(fontSize: 14),
    );
    final maxUnitWidth = _calculateMaxTextWidth(
      filteredData.where((item) => item.unit != null).map((item) => item.unit!).toList(),
      const TextStyle(fontSize: 14),
    );

    // Вычисляем доступное пространство для столбиков
    final screenWidth = MediaQuery.of(context).size.width;
    final totalFixedWidth = maxDateWidth +
        maxValueWidth +
        (maxSecondValueWidth > 0 ? maxSecondValueWidth : 0) +
        (maxUnitWidth > 0 ? maxUnitWidth : 0) + 50; // Сумма отступов (10 между всеми элементами)
    final maxChartWidth = screenWidth - totalFixedWidth - 40; // Учитываем padding (20 слева + 20 справа)

    return Scaffold(
      appBar: AppBarWidget(
        title: widget.title,
        showMenu: false,
        showChat: false,
        showNotifications: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              if (widget.thisData!.first.info != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    widget.thisData!.first.info ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              // Список данных
            ...filteredData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              // Вычисляем ширину столбика пропорционально maxValue
              final barWidth = (item.value!.toDouble() / maxValue) * maxChartWidth;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Дата
                    SizedBox(
                      width: maxDateWidth + 20,
                      child: Text(
                        dateTimeFormat(item.date) ?? ' - ',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    // Значение
                    SizedBox(
                      width: maxValueWidth + 10,
                      child: Text(
                        _getValueText(item),
                        style: TextStyle(fontSize: 14,
                            color: item.isNorma == null ? Colors.blueGrey : item.isNorma! ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    // Второе значение (если есть)
                    if (item.visibleValue != null && item.showBothValue)
                      SizedBox(
                        width: maxSecondValueWidth + 10,
                        child: Text(
                          formatDouble(item.value!, fixedCount: 1),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    // Единицы измерения (если есть)
                    if (item.unit != null)
                      SizedBox(
                        width: maxUnitWidth + 10,
                        child: Text(
                          item.unit!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    const SizedBox(width: 10), // Отступ перед столбиком
                    // Столбик с шириной, зависящей от value
                    Container(
                      height: 12,
                      width: barWidth.clamp(0, maxChartWidth), // Ограничиваем максимальной шириной
                      decoration: BoxDecoration(
                        color: item.isNorma == null ? Colors.blueGrey : item.isNorma! ? Colors.green : Colors.red,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ]
          ),
        ),
      ),
    );
  }

  // Вспомогательная функция для получения текста значения
  String _getValueText(DataDynamic item) {
    return (item.visibleValue != null)
        ? item.visibleValue!
        : formatDouble(item.value!, fixedCount: 1);
  }

  // Функция для вычисления максимальной ширины текста в колонке
  double _calculateMaxTextWidth(List<String> texts, TextStyle style) {
    if (texts.isEmpty) return 0.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.of(context).textScaler,
    );

    double maxWidth = 0.0;
    for (final text in texts) {
      textPainter.text = TextSpan(text: text, style: style);
      textPainter.layout();
      maxWidth = maxWidth > textPainter.width ? maxWidth : textPainter.width;
    }

    return maxWidth;
  }











// import 'package:flutter/material.dart';
// import '../data/data_dynamic.dart';
// import '../my_functions.dart';
// import '../widgets/app_bar_widget.dart';
//
// class PageDynamic extends StatefulWidget {
//   final String title;
//   final List<DataDynamic>? thisData;
//
//   const PageDynamic({
//     super.key,
//     required this.title,
//     required this.thisData,
//   });
//
//   @override
//   State<PageDynamic> createState() => _PageDynamicState();
// }
//
// class _PageDynamicState extends State<PageDynamic> {
//
//   @override
//   Widget build(BuildContext context) {
//     // Фильтруем записи, где value не null
//     final filteredData = widget.thisData!.where((item) => item.value != null).toList();
//
//     // Если после фильтрации данных нет, возвращаем пустой виджет
//     if (filteredData.isEmpty) {
//       return notDataWidget;
//     }
//     // Находим максимальное значение value в отфильтрованном списке
//     final maxValue = filteredData.map((e) => e.value!.toDouble()).reduce((a, b) => a > b ? a : b);
//
//     return Scaffold(
//       appBar: AppBarWidget(
//         title: widget.title,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: filteredData.asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//               // Масштабируем длину столбика: максимальное значение = максимальная длина (в пикселях)
//               final maxChartWidth = 100.0; // Максимальная ширина области графика
//               final barWidth = (item.value!.toDouble() / maxValue) * maxChartWidth;
//
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Дата слева
//                     SizedBox(
//                       width: 120, // Зарезервировано для даты
//                       child: Text(
//                         dateTimeFormat(item.date) ?? ' - ',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     // Значение рядом со столбиком
//                     SizedBox(
//                       width: 60, // Зарезервировано для значения
//                       child: (item.visibleValue != null)
//                           ? Text(item.visibleValue!)
//                           : Text(formatDouble(item.value!, fixedCount: 1),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     if (item.visibleValue != null && item.showBothValue)
//                     SizedBox(
//                       width: 20, // Зарезервировано для значения
//                       child: Text(formatDouble(item.value!, fixedCount: 1),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     if (item.visibleValue != null && item.showBothValue)
//                       const SizedBox(width: 10),
//                     if (item.unit != null)
//                     SizedBox(
//                       width: 80, // Зарезервировано для единиц измерения
//                       child: Text(item.unit ?? '', // Теперь value точно не null
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     // Столбик, растущий вправо
//                     Container(
//                       height: 12, // Высота столбика
//                       width: barWidth, // Длина столбика пропорциональна значению
//                       decoration: BoxDecoration(
//                         color: item.isNorma ?? true ? Colors.green : Colors.red,
//                         borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
// }
//
//


//
// import 'package:flutter/material.dart';
// import '../data/data_dynamic.dart';
// import '../my_functions.dart';
// import '../widgets/app_bar_widget.dart';
//
// class PageDynamic extends StatefulWidget {
//   final String title;
//   final List<DataDynamic>? thisData;
//
//   const PageDynamic({
//     super.key,
//     required this.title,
//     required this.thisData,
//   });
//
//   @override
//   State<PageDynamic> createState() => _PageDynamicState();
// }
//
// class _PageDynamicState extends State<PageDynamic> {
//   @override
//   Widget build(BuildContext context) {
//     // Фильтруем записи, где value не null
//     final filteredData = widget.thisData!.where((item) => item.value != null).toList();
//
//     if (filteredData.isEmpty) {
//       return notDataWidget;
//     }
//
//     // Находим максимальное значение value для масштабирования столбиков
//     final maxValue = filteredData.map((e) => e.value!.toDouble()).reduce((a, b) => a > b ? a : b);
//
//
//     // Вычисляем максимальную длину текста для каждой колонки
//     final maxDateWidth = _calculateMaxTextWidth(
//       filteredData.map((item) => dateTimeFormat(item.date) ?? ' - ').toList(),
//       const TextStyle(fontSize: 14),
//     );
//     final maxValueWidth = _calculateMaxTextWidth(
//       filteredData.map((item) => _getValueText(item)).toList(),
//       const TextStyle(fontSize: 14),
//     );
//     final maxSecondValueWidth = _calculateMaxTextWidth(
//       filteredData
//           .where((item) => item.visibleValue != null && item.showBothValue)
//           .map((item) => formatDouble(item.value!, fixedCount: 1).toString())
//           .toList(),
//       const TextStyle(fontSize: 14),
//     );
//     final maxUnitWidth = _calculateMaxTextWidth(
//       filteredData.where((item) => item.unit != null).map((item) => item.unit!).toList(),
//       const TextStyle(fontSize: 14),
//     );
//
//     return Scaffold(
//       appBar: AppBarWidget(
//         title: widget.title,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: filteredData.asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Дата
//                     SizedBox(
//                       width: maxDateWidth + 10, // Добавляем отступ
//                       child: Text(
//                         dateTimeFormat(item.date) ?? ' - ',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     // Значение
//                     SizedBox(
//                       width: maxValueWidth + 10,
//                       child: Text(
//                         _getValueText(item),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     // Второе значение (если есть)
//                     if (item.visibleValue != null && item.showBothValue)
//                       SizedBox(
//                         width: maxSecondValueWidth + 10,
//                         child: Text(
//                           formatDouble(item.value!, fixedCount: 1),
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     // Единицы измерения (если есть)
//                     if (item.unit != null)
//                       SizedBox(
//                         width: maxUnitWidth + 10,
//                         child: Text(
//                           item.unit!,
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     const SizedBox(width: 10), // Отступ перед столбиком
//                     // Столбик занимает оставшееся пространство
//                     Expanded(
//                       child: Container(
//                         height: 12,
//                         width: (item.value!.toDouble() / maxValue) * double.infinity, // Масштабируем относительно максимума
//                         decoration: BoxDecoration(
//                           color: item.isNorma ?? true ? Colors.green : Colors.red,
//                           borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Вспомогательная функция для получения текста значения
//   String _getValueText(DataDynamic item) {
//     return (item.visibleValue != null)
//         ? item.visibleValue!
//         : formatDouble(item.value!, fixedCount: 1);
//   }
//
//   // Функция для вычисления максимальной ширины текста в колонке
//   double _calculateMaxTextWidth(List<String> texts, TextStyle style) {
//     if (texts.isEmpty) return 0.0;
//
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       textScaler: MediaQuery.of(context).textScaler,
//     );
//
//     double maxWidth = 0.0;
//     for (final text in texts) {
//       textPainter.text = TextSpan(text: text, style: style);
//       textPainter.layout();
//       maxWidth = maxWidth > textPainter.width ? maxWidth : textPainter.width;
//     }
//
//     return maxWidth;
//   }
// }







}