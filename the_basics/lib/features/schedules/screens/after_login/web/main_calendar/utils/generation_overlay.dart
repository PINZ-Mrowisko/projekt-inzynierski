import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class SimpleLoadingOverlay {
  static OverlayEntry? _overlayEntry;
  
  static void show(BuildContext context, {String message = 'Generowanie grafiku...'}) {
    hide();
    
    final overlay = Overlay.of(context);
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.logo,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: AppColors.textColor2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    overlay.insert(_overlayEntry!);
  }
  
  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}