import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';

class ThreeColorScale extends StatefulWidget {
  const ThreeColorScale({super.key});

  @override
  ThreeColorScaleState createState() => ThreeColorScaleState();
}

class ThreeColorScaleState extends State<ThreeColorScale> {
  double _value = 50; // Начальное значение

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width-50; // Учитываем размер бегунка
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Укажите уровень боли',
              style: listLabelStyle,
            ),
            SizedBox(width: 10),
            Icon(
              FontAwesomeIcons.bolt,
              color: Colors.red.shade300,
              size: 20,
            ),
          ],
        ),
        SizedBox(height: 60,),
        Stack(
          children: [
            // Фон шкалы (трехцветный)
            Row(
              children: [
                Container(
                  width: screenWidth*30/100,
                  height: 30,
                  //color: Colors.green,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: screenWidth*40/100,
                  height: 30,
                  //color: Colors.orange,
                  decoration: BoxDecoration(
                    color: Colors.orange[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: screenWidth*30/100,
                  height: 30,
                  //color: Colors.red,
                  decoration: BoxDecoration(
                    color: Colors.red[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            // Бегунок
            Positioned(
              left: ((screenWidth) / 100) * _value,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    double newValue = _value + (details.primaryDelta! / screenWidth) * 100;
                    _value = newValue.clamp(0, 100);
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 60),
        // Текущее значение на шкале
        Text(
          '${_value.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 60),
      ],
    );
  }
}
