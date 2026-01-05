import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';

class NumberInputButtonsWidget extends StatefulWidget {
  final String label;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onValueChanged;
  final bool readOnly;

  const NumberInputButtonsWidget({
    Key? key,
    required this.label,
    required this.initialValue,
    this.minValue = 0,
    this.maxValue = 999,
    required this.onValueChanged,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<NumberInputButtonsWidget> createState() => _NumberInputButtonsWidgetState();
}

class _NumberInputButtonsWidgetState extends State<NumberInputButtonsWidget> {
  late RxInt _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = RxInt(widget.initialValue);
  }

  void _increment() {
    if (!widget.readOnly && _currentValue.value < widget.maxValue) {
      _currentValue.value++;
      widget.onValueChanged(_currentValue.value);
    }
  }

  void _decrement() {
    if (!widget.readOnly && _currentValue.value > widget.minValue) {
      _currentValue.value--;
      widget.onValueChanged(_currentValue.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 56,
      decoration: BoxDecoration(
        color: widget.readOnly ? AppColors.lightBlue.withOpacity(0.3) : AppColors.lightBlue,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Minus button
          if (!widget.readOnly)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _decrement,
                icon: Icon(Icons.remove, color: AppColors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

          // Value display
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.readOnly
                        ? AppColors.textColor2.withOpacity(0.6)
                        : AppColors.textColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                  '${_currentValue.value}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.readOnly
                        ? AppColors.textColor2.withOpacity(0.6)
                        : AppColors.textColor2,
                  ),
                )),
              ],
            ),
          ),

          // Plus button
          if (!widget.readOnly)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _increment,
                icon: Icon(Icons.add, color: AppColors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }
}