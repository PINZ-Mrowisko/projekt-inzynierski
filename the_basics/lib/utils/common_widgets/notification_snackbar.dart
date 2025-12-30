import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

// UPDATED to overlay so that it always appears in the top layer
void showCustomSnackbar(BuildContext context, String message) {
  final screenWidth = MediaQuery.of(context).size.width;
  final snackbarWidth = screenWidth * 0.6;

  final overlay = Overlay.of(context);
  if (overlay == null) return;

  late OverlayEntry overlayEntry;
  
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Material(
        color: AppColors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: snackbarWidth,
            margin: const EdgeInsets.symmetric(horizontal: 20),
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
                Icon(Icons.info_outline, color: AppColors.textColor2, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor2,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.textColor2, size: 24),
                  onPressed: () {
                    overlayEntry.remove();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}