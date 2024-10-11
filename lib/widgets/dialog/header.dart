import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  final String title;

  const DialogHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: Colors.black),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w400
              ),
            ),
          ],
        ),
      ),
    );
  }
}
