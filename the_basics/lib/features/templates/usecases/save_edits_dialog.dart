import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';

Future<String?> showEditOptionsDialog() async {
  return await Get.dialog<String>(
    BaseDialog(
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Zakończyć edycję?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Wybierz co chcesz zrobić ze zmianami:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 127,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: 'cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Text(
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
                width: 160,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(result: 'saveAsNew'),
                  icon: const Icon(Icons.add, color: AppColors.textColor2),
                  label: const Text(
                    'Zapisz jako nowy',
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
              const SizedBox(width: 40),
              SizedBox(
                width: 150,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Get.back(result: 'save'),
                  icon: const Icon(Icons.save, color: AppColors.textColor2),
                  label: const Text(
                    'Zapisz zmiany',
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
            ],
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}
