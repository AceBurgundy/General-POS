import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final IconData? icon;

  const FormTextField({
    super.key,
    required this.controller,
    this.label = '',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.icon
  });

  @override
  Widget build(BuildContext context) {

    List<TextInputFormatter> allowOnlyDouble = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
    ];

    List<TextInputFormatter> allowOnlyInteger = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'^\d+'))
    ];

    List<TextInputFormatter> formatter = [
      if (keyboardType == TextInputType.number) ...allowOnlyInteger,
      if (keyboardType == const TextInputType.numberWithOptions(decimal: true)) ...allowOnlyDouble
    ];

    return SizedBox(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatter,
        decoration: InputDecoration(
          icon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
          labelText: label,
          enabledBorder: UnderlineInputBorder(
             borderSide: BorderSide(color: Theme.of(context).primaryColor)
          )
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }

          return null;
        },
      ),
    );
  }
}
