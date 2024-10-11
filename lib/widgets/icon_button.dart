import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AppIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
