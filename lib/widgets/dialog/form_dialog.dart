import 'package:flutter/material.dart';

import 'footer.dart';
import 'header.dart';

class FormDialog extends StatelessWidget {
  final String title;
  final List<Widget> inputFields;
  final VoidCallback onSubmit;
  final String submitButtonText;
  final double inputFieldsGap;
  final GlobalKey<FormState> formKey;

  const FormDialog({
    super.key,
    required this.title,
    required this.inputFields,
    required this.onSubmit,
    required this.submitButtonText,
    required this.formKey,
    this.inputFieldsGap = 20,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> gappedInputFields = [];

    for (var field in inputFields) {
      gappedInputFields.add(field);
      gappedInputFields.add(SizedBox(height: inputFieldsGap));
    }

    if (gappedInputFields.isNotEmpty) {
      gappedInputFields.removeLast();
    }

    return Dialog.fullscreen(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(title: title),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      ...gappedInputFields,
                      const SizedBox(height: 20),
                      DialogFooter(
                        onCancel: () => Navigator.pop(context),
                        onSubmit: onSubmit,
                        buttonTitle: submitButtonText,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
