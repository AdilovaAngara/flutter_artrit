import 'package:flutter/material.dart';

import '../theme.dart';

class TooltipWidget extends StatefulWidget {
  final RichText richText;

  const TooltipWidget({
    super.key,
    required this.richText,
  });

  @override
  State<TooltipWidget> createState() => _TooltipWidgetState();
}

class _TooltipWidgetState extends State<TooltipWidget> {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Нажмите, чтобы посмотреть информацию',
      child: IconButton(
        icon: const Icon(
          Icons.info,
          size: 35,
        ),
        onPressed: () {
          // Действие при нажатии на иконку
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Информация', style: formHeaderStyle,),
                content: widget.richText,
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}


