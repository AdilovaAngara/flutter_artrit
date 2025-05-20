import 'package:flutter/material.dart';

import '../roles.dart';
import '../theme.dart';


/// Виджет баннера статуса чата
class ChatStatusBanner extends StatelessWidget {
  final bool isChatClosed;
  final bool allowByDoctor;
  final bool allowByPatient;
  final int role;

  const ChatStatusBanner({
    super.key,
    required this.isChatClosed,
    required this.allowByDoctor,
    required this.allowByPatient,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    /// Если чат закрыт
    if (isChatClosed) {
      return _buildBanner(context, 'Доктор закрыл чат');
    }
    /// Если кто-то из собеседников не подтвердил согласие с политикой чата и чат не закрыт
    else if ((!allowByPatient && allowByDoctor && !Roles.asPatient.contains(role)) ||
        (allowByPatient && !allowByDoctor && !Roles.asDoctor.contains(role))) {
      return _buildBanner(context, '${!allowByPatient ? 'Пациент' : 'Доктор'} еще не принял политику чата');
    }
    return const SizedBox.shrink();
  }

  Widget _buildBanner(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 40.0),
      child: RichText(
        softWrap: true,
        strutStyle: const StrutStyle(height: 1.8),
        text: TextSpan(
          children: [
            WidgetSpan(child: Icon(Icons.block, color: Colors.red, size: 22)),
            TextSpan(text: '  $message', style: captionTextStyle),
          ],
        ),
      ),
    );
  }
}