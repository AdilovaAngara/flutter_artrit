import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class WidgetInputVerificationCode extends StatefulWidget {
  final void Function(String)? onCompleted;

  const WidgetInputVerificationCode({super.key, this.onCompleted});

  @override
  State<WidgetInputVerificationCode> createState() => _WidgetInputVerificationCodeState();
}

class _WidgetInputVerificationCodeState extends State<WidgetInputVerificationCode> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.indigo,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.indigo.shade300, width: 2),
        ),
      ),
    );

    return Pinput(
      length: 4,
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultPinTheme,
      separatorBuilder: (index) => const SizedBox(width: 10),
      showCursor: true,
      onChanged: (value) {
        // Можно использовать для промежуточной проверки
      },
      onCompleted: widget.onCompleted,
    );
  }
}
