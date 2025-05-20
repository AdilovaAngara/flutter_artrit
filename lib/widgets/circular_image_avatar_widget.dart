import 'package:flutter/material.dart';

class CircularImageAvatar extends StatelessWidget {
  final String imagePath;
  final double radius;

  const CircularImageAvatar({
    super.key,
    required this.imagePath,
    this.radius = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: AssetImage(imagePath),
      radius: radius,
    );
  }
}


