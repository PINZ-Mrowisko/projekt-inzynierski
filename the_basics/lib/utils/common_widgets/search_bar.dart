import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final double height;
  final double minWidth;
  final double maxWidth;
  final double? widthPercentage; 

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.height = 56,
    this.minWidth = 200,
    this.maxWidth = 360,
    this.widthPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedWidth = widthPercentage != null 
        ? screenWidth * widthPercentage!
        : maxWidth;
    
    final constrainedWidth = calculatedWidth.clamp(minWidth, maxWidth);

    return SizedBox(
      width: constrainedWidth,
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: TextField(
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hoverColor: AppColors.transparent,
            prefixIcon: Icon(Icons.search, color: AppColors.textColor2),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16, 
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }
}