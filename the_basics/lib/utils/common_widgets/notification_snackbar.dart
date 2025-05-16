import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

void showCustomSnackbar(BuildContext context, String message) {
  final screenWidth = MediaQuery.of(context).size.width;
  final snackbarWidth = screenWidth * 0.6;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(
        bottom: 60,
        left: 20,
        right: 20,
      ),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: AppColors.transparent,
            child: Container(
              width: snackbarWidth,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textColor2, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
