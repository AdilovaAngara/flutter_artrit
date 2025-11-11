import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';

class AnimatedColorScaleWidget extends StatefulWidget {
  final double value;
  final String labelStart;
  final String labelEnd;
  final ValueChanged<double> onChanged;
  final int? role;
  final List<int>? listRoles;

  const AnimatedColorScaleWidget({
    super.key,
    required this.value,
    required this.labelStart,
    required this.labelEnd,
    required this.onChanged,
    this.role,
    required this.listRoles,
  });

  @override
  AnimatedColorScaleWidgetState createState() => AnimatedColorScaleWidgetState();
}

class AnimatedColorScaleWidgetState extends State<AnimatedColorScaleWidget> {
  late double value; // Используем late для инициализации значения

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedColorScaleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != value) {
      setState(() {
        value = widget.value; // Обновляем значение, если widget.value изменился
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width - 40; // Получаем ширину экрана
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 70),
          Stack(
            children: [
              // Фон шкалы
              Container(
                width: screenWidth,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Анимированное заполнение шкалы
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: (screenWidth / 100) * value, // Динамическая ширина заливки
                height: 30,
                decoration: BoxDecoration(
                  color: getColor(value),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          SizedBox(height: 60),
          // Текущее значение на шкале
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          // Ползунок для изменения значения
          Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: getColor(value),
            onChanged: widget.listRoles == Roles.all || widget.listRoles!.contains(widget.role) ? (newValue) {
              setState(() {
                value = newValue;
              });
              widget.onChanged(value); // Вызов колбэка для передачи нового значения
            } : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(widget.labelStart, style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),),
              // Text(widget.labelEnd, style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),),
              Text('0-29', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),),
              Text('30-69', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
              Text('70-100', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../my_functions.dart';
// import '../theme.dart';
//
// class AnimatedColorScale extends StatefulWidget {
//   final double value;
//
//   const AnimatedColorScale({
//     super.key,
//     required this.value,
//   });
//
//   @override
//   AnimatedColorScaleState createState() => AnimatedColorScaleState();
// }
//
// class AnimatedColorScaleState extends State<AnimatedColorScale> {
//   double _value = 0; // Начальное значение
//
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width - 40; // Получаем ширину экрана
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Укажите уровень боли',
//               style: labelStyle,
//             ),
//             SizedBox(width: 10),
//             Icon(
//               FontAwesomeIcons.bolt,
//               color: Colors.red.shade300,
//               size: 20,
//             ),
//           ],
//         ),
//         SizedBox(height: 60,),
//         Stack(
//           children: [
//             // Фон шкалы
//             Container(
//               width: screenWidth,
//               height: 30,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             SizedBox(height: 60),
//             // Анимированное заполнение шкалы
//             AnimatedContainer(
//               duration: Duration(milliseconds: 500),
//               width: (screenWidth / 100) * _value, // Динамическая ширина заливки
//               height: 30,
//               decoration: BoxDecoration(
//                 color: getColor(_value),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 60),
//         // Текущее значение на шкале
//         Text(
//           '${_value.toStringAsFixed(0)}%',
//           style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 60),
//         // Ползунок для изменения значения
//         Slider(
//           value: _value,
//           min: 0,
//           max: 100,
//           divisions: 100,
//           activeColor: getColor(_value),
//           onChanged: (newValue) {
//             setState(() {
//               _value = newValue;
//             });
//           },
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('0-30', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),),
//             Text('30-70', style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),),
//             Text('70-100', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),),
//           ],
//         ),
//       ],
//     );
//   }
//
// }