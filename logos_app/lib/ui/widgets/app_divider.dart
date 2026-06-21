import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  final Color color;
  const AppDivider({super.key, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: color,
    );
  }
}
