import 'package:flutter/material.dart';
import '../theme.dart';

class LabelJoinWidget extends StatefulWidget {
  final String labelText;
  final dynamic value;
  final String? unit;
  final bool? isNorma;
  final bool isColumn;
  final VoidCallback? onPressed;
  final VoidCallback? onPressedView;
  final bool showValue;

  const LabelJoinWidget({
    super.key,
    required this.labelText,
    required this.value,
    this.unit,
    this.isNorma = true,
    this.isColumn = true,
    this.onPressed,
    this.onPressedView,
    this.showValue = true,
  });

  @override
  LabelJoinWidgetState createState() => LabelJoinWidgetState();
}

class LabelJoinWidgetState extends State<LabelJoinWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.isColumn
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              labelText(),
              const SizedBox(height: 2.0),
              if (widget.showValue) valueText(),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
        if (widget.onPressedView != null)
          IconButton(
            alignment: Alignment.centerRight,
            icon: Icon(
              Icons.visibility_rounded,
              color: Colors.blueAccent.shade100,
            ),
            onPressed: widget.onPressedView,
          ),
        if (widget.onPressed != null)
          IconButton(
            alignment: Alignment.centerRight,
          icon: Icon(
            Icons.bar_chart_outlined,
            color: Colors.deepPurple.shade100,
          ),
          onPressed: widget.onPressed,
        ),
      ],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelText(),
        const SizedBox(width: 2.0),
        if (widget.showValue) valueText(),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget labelText() {
    return Text(
      '${widget.labelText}: ',
      style: widget.isColumn ? subtitleMiniTextStyle : labelStyle,
    );
  }

  Widget valueText() {
    return Text(
      widget.unit != null &&
          widget.value != null &&
          widget.unit!.isNotEmpty &&
          widget.value.toString().isNotEmpty
          ? '${widget.value} ${widget.unit}'
          : widget.value != null && widget.value.toString().isNotEmpty
          ? widget.value.toString()
          : '-',
      style: widget.isNorma ?? true ? inputTextStyle : inputTextStyleRed,
    );
  }
}