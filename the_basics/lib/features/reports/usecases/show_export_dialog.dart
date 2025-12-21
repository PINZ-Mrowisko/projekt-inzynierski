import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

void showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => BaseDialog(
      width: 551,
      showCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Text(
            "Czy chcesz eksportować raport?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 48),

          Center(
            child: SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  showCustomSnackbar(
                    context,
                    "Raport został pomyślnie zapisany.",
                  );
                },
                icon: Icon(Icons.download, color: AppColors.textColor2),
                label: Text(
                  "Zapisz jako PDF",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
