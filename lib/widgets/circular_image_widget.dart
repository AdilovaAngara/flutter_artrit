import 'package:flutter/material.dart';

class CircularImageWidget extends StatelessWidget {
  final String imagePath;
  final double size;

  const CircularImageWidget({
    super.key,
    required this.imagePath,
    this.size = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        //border: Border.all(color: Colors.grey.shade300, width: 4), // Рамка
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}




