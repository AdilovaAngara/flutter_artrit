import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';
import '../widget_another/animated_color_scale_widget.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/button_widget.dart';

class PageInspectionsPain extends StatefulWidget {
  final int ocbol;
  final int role;

  const PageInspectionsPain({
    super.key,
    required this.ocbol,
    required this.role
  });

  @override
  State<PageInspectionsPain> createState() => PageInspectionsPainState();
}

class PageInspectionsPainState extends State<PageInspectionsPain> {
  late int _ocbol;

  @override
  void initState() {
    _ocbol = widget.ocbol;
    super.initState();
  }

  bool _areDifferent() {
    if (widget.ocbol != _ocbol) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Оценка боли',
        showMenu: false,
        showChat: false,
        showNotifications: false,
        onPressed: () { onBack(context, (_areDifferent())); },
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Укажите уровень боли',
                  style: labelStyle,
                ),
                SizedBox(width: 10),
                Icon(
                  FontAwesomeIcons.bolt,
                  color: Colors.red.shade300,
                  size: 20,
                ),
              ],
            ),
            Expanded(
              child: AnimatedColorScaleWidget(
                value: _ocbol.toDouble(),
                listRoles: Roles.asPatient,
                role: widget.role,
                onChanged: (value) {
                  setState(() {
                    _ocbol = value.toInt();
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: ButtonWidget(
                labelText: 'Применить',
                listRoles: Roles.asPatient,
                role: widget.role,
                onPressed: () {
                  Navigator.pop(context, _ocbol); // Передача значения назад
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
