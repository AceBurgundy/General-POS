import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchInputField({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: SizedBox(
        height: 50,
        child: TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xfff3f6f4),
            hintText: 'Search...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search),
            prefixIconColor: Colors.grey,
            contentPadding: EdgeInsets.all(10),
          ),
        ),
      ),
    );
  }
}
