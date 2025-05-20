import 'package:flutter/material.dart';
import '../my_functions.dart';

class ColorScaleIndicator extends StatefulWidget {
  final int value; // Значение от 0 до 100

  const ColorScaleIndicator({super.key, required this.value});

  @override
  State<ColorScaleIndicator> createState() => _ColorScaleIndicatorState();
}

class _ColorScaleIndicatorState extends State<ColorScaleIndicator> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Получаем ширину экрана
    return Column(
      children: [
        Stack(
          children: [
            // Фон шкалы
            Container(
              alignment: Alignment.center,
              width: screenWidth,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Заполненная часть шкалы
            Container(
              alignment: Alignment.center,
              width: (screenWidth / 100) * widget.value, // Динамическая ширина заливки
              height: 35,
              decoration: BoxDecoration(
                color: getColor(widget.value),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: 35,
              child: Text(
                '${widget.value.toStringAsFixed(0)} %',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ],
    );
  }
}





