import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class GenericList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final void Function(T)? onItemTap;
  final void Function(T)? onItemLongPress;
  final EdgeInsets? itemMargin;
  final Color? itemBackgroundColor;
  final double? itemBorderRadius;
  final Color? hoverColor;
  final Color? splashColor;

  const GenericList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onItemTap,
    this.onItemLongPress,
    this.itemMargin = const EdgeInsets.only(bottom: 16),
    this.itemBackgroundColor,
    this.itemBorderRadius = 15,
    this.hoverColor,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MouseRegion(
          cursor: onItemTap != null 
              ? SystemMouseCursors.click 
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: onItemTap != null ? () => onItemTap!(item) : null,
            onLongPress: onItemLongPress != null 
                ? () => onItemLongPress!(item) 
                : null,
            child: Container(
              margin: itemMargin,
              decoration: BoxDecoration(
                color: itemBackgroundColor ?? 
                    AppColors.lightBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(itemBorderRadius ?? 15),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(itemBorderRadius ?? 15),
                  hoverColor: hoverColor ?? AppColors.lightBlue,
                  splashColor: splashColor ?? AppColors.lightBlue,
                  onTap: onItemTap != null ? () => onItemTap!(item) : null,
                  child: itemBuilder(context, item),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}