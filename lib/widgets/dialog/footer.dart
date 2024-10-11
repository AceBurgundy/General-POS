import 'package:flutter/material.dart';

class DialogFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String buttonTitle;

  const DialogFooter({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.buttonTitle = 'Submit'
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onSubmit,
            child: Text(buttonTitle),
          ),
        ]);
  }
}
