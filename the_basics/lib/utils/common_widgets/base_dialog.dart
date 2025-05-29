import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class BaseDialog extends StatelessWidget {
  final double width;
  final Widget child;
  final bool showCloseButton;

  const BaseDialog({
    super.key,
    required this.width,
    required this.child,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: child,
              ),
              if (showCloseButton)
                Positioned(
                  right: 16,
                  top: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
