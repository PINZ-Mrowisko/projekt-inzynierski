// Update time_input_widget.dart
import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class TimeInputWidget extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> Function(String) filterTimeOptions;
  final Function(String) onTimeSelected;

  const TimeInputWidget({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.filterTimeOptions,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimeInputWidget> createState() => _TimeInputWidgetState();
}

class _TimeInputWidgetState extends State<TimeInputWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 56,
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return widget.filterTimeOptions(textEditingValue.text);
              },
              onSelected: (String selection) {
                _controller.text = selection;
                widget.onTimeSelected(selection);
              },
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                  ) {
                // Set initial value
                if (fieldTextEditingController.text.isEmpty) {
                  fieldTextEditingController.text = widget.initialValue;
                }

                fieldTextEditingController.addListener(() {
                  widget.onTimeSelected(fieldTextEditingController.text);
                });

                return TextField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    hintText: 'HH:MM lub wybierz',
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
                      onPressed: () {
                        fieldFocusNode.requestFocus();
                      },
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 2 && !value.contains(':')) {
                      fieldTextEditingController.text = '$value:';
                      fieldTextEditingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: fieldTextEditingController.text.length),
                      );
                    }
                  },
                );
              },
              optionsViewBuilder: (
                  BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options,
                  ) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      width: 200,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final option = options.elementAt(index);
                          return InkWell(
                            onTap: () {
                              onSelected(option);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              color: AppColors.white,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textColor2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}