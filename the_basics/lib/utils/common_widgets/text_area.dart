import 'package:flutter/material.dart';

class TextAreaDialogField extends StatelessWidget {
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const TextAreaDialogField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.maxLines = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}