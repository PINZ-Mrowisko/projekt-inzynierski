import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/features/schedules/widgets/base_dialog.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String confirmText;
  final String cancelText;
  final Color confirmButtonColor;
  final Color confirmTextColor;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmButtonColor = AppColors.blue,
    this.confirmTextColor = AppColors.textColor2,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      width: 551,
      height: subtitle != null ? 301 : 285,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor2,
              ),
            ),
          ],
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: confirmTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}