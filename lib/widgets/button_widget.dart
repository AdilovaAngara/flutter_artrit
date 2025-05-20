import 'package:flutter/material.dart';
import '../my_functions.dart';
import '../roles.dart';
import '../theme.dart';

class ButtonWidget extends StatefulWidget {
  final String labelText;
  final VoidCallback onPressed;
  final bool enabled;
  final Color backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final double height;
  final double width;
  final IconAlignment iconAlignment;
  final bool onlyText;
  final bool dialogForm;
  final bool showProgressIndicator;
  final int? role;
  final List<int>? listRoles;

  const ButtonWidget({
    super.key,
    required this.labelText,
    required this.onPressed,
    this.enabled = true,
    this.icon,
    this.iconColor = btnColor,
    this.iconSize = 35,
    this.height = 45,
    this.width = 200,
    this.iconAlignment = IconAlignment.end,
    this.backgroundColor = btnColor,
    this.onlyText = false,
    this.dialogForm = false,
    this.showProgressIndicator = false,
    this.role,
    required this.listRoles,
  });

  @override
  ButtonWidgetState createState() => ButtonWidgetState();
}

class ButtonWidgetState extends State<ButtonWidget> {

  Color _getBackgroundColor(){
    if (widget.onlyText) {
      return Colors.transparent;
    } else if (!widget.enabled) {
      return widget.backgroundColor.withAlpha(80);
    } else {
      return widget.backgroundColor;
    }
  }

  Color _getTextColor() {
    if (widget.onlyText && widget.dialogForm) {
      return Colors.deepPurple;
    } else {
      return Colors.black45;
    }
  }


  @override
  Widget build(BuildContext context) {
    return widget.listRoles == Roles.all || widget.listRoles!.contains(widget.role) ? TextButton.icon(
      onPressed: widget.enabled && !widget.showProgressIndicator ? widget.onPressed : null,
      label: widget.showProgressIndicator
          ? showProgressIndicator()
          : Text(
        widget.labelText,
        style: (widget.onlyText) ? btnTextStyle(_getTextColor()) : btnTextStyle(Colors.white),
      ),
      icon: (widget.icon != null) ? Icon(widget.icon) : null,
      iconAlignment: widget.iconAlignment,
      style: TextButton.styleFrom(
        textStyle: (widget.onlyText) ? btnTextStyle(_getTextColor()) : btnTextStyle(Colors.white),
        iconSize: widget.iconSize,
        iconColor: widget.iconColor,
        padding: (widget.onlyText) ? const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0) : const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
        minimumSize: Size.square(20), // Задаём площадь
        //fixedSize: (widget.blackText) ? null : Size(widget.width, widget.height), // Задаём ширину и высоту
        backgroundColor: _getBackgroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ) : SizedBox(height: 0, width: 0,);
  }
}




