import 'package:flutter/material.dart';

import '../theme.dart';

class MessageWidget extends StatefulWidget {
  final TextSpan text;

  const MessageWidget({
    super.key,
    required this.text,
  });

  @override
  State<MessageWidget> createState() => MessageWidgetState();
}

class MessageWidgetState extends State<MessageWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Информация', style: formHeaderStyle,),
      content: RichText(
        text: widget.text,
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}



