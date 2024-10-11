import 'package:flutter/material.dart';

class DotIndicator extends StatelessWidget {
  final bool isActive;

  const DotIndicator({
    super.key, required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 16 / 2),
      height: 5,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : activeColor.withOpacity(0.25),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}
