// dialog_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class DialogActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String confirmText;
  final bool isConfirmEnabled;

  const DialogActionButtons({
    Key? key,
    required this.onCancel,
    required this.onConfirm,
    this.confirmText = 'Dodaj zmiany',
    this.isConfirmEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 127,
          height: 56,
          child: ElevatedButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Anuluj',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 150,
          height: 56,
          child: ElevatedButton(
            onPressed: isConfirmEnabled ? onConfirm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isConfirmEnabled ? AppColors.blue : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              confirmText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}