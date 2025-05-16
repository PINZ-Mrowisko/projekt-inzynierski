import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:the_basics/utils/app_colors.dart';

import 'confirmation_dialog.dart';
import 'multi_select_dropdown.dart';

class CustomFormDialog extends StatefulWidget {
  final String title;
  final List<DialogInputField> fields;
  final List<DialogActionButton> actions;
  final VoidCallback? onClose;
  final double? width;
  final double? height;

  const CustomFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.actions,
    this.onClose,
    this.width = 547,
    this.height = 463,
  });

  @override
  State<CustomFormDialog> createState() => _CustomFormDialogState();
}

class _CustomFormDialogState extends State<CustomFormDialog> {
  final ValueNotifier<bool> hasChanges = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    void processField(DialogInputField field) {
      if (field is DropdownDialogField) {
        field.onInternalChanged = () => hasChanges.value = true;
      } else if (field is MultiSelectDialogField) {
        field.onInternalChanged = () => hasChanges.value = true;
      } else if (field is RowDialogField) {
        for (var child in field.children) {
          processField(child);
        }
      } else if (field.controller != null) {
        field.controller?.addListener(() => hasChanges.value = true);
      }
    }

    for (var field in widget.fields) {
      processField(field);
    }
  }

  @override
  void dispose() {
    hasChanges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              if (widget.onClose != null)
                Positioned(
                  right: 16,
                  top: 16,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: hasChanges,
                    builder: (context, changed, _) {
                      return IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () {
                          if (changed) {
                            _showExitConfirmationDialog(widget.onClose!);
                          } else {
                            widget.onClose!();
                          }
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 40),
                              ...widget.fields.map((field) => _buildInputField(field)),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: widget.actions
                                    .map((action) => Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: SizedBox(
                                            width: 109,
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                action.onPressed();
                                                hasChanges.value = false;
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: action.backgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(100),
                                                ),
                                              ),
                                              child: Text(
                                                action.label,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: action.textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(DialogInputField field) {
    switch (field.type) {
      case DialogInputType.text:
        return _buildTextField(field);
      case DialogInputType.dropdown:
        return _buildDropdownField(field as DropdownDialogField);
      case DialogInputType.multiSelect:
        return _buildMultiSelectField(field as MultiSelectDialogField);
      case DialogInputType.row:
        return _buildRowField(field as RowDialogField);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(DialogInputField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColor1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            controller: field.controller,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hoverColor: AppColors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildDropdownField(DropdownDialogField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColor1,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: DropdownButtonFormField<String>(
            value: field.selectedValue,
            hint: Text(
              field.hintText,
              style: const TextStyle(
                color: AppColors.textColor2,
                fontSize: 16,
              ),
            ),
            items: field.items
                .map((item) => DropdownMenuItem(
                      value: item.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor1,
                          ),
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              field.onChanged(value);
              field.onInternalChanged?.call();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hoverColor: AppColors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              height: 1.0,
              color: AppColors.textColor1,
            ),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 4,
            menuMaxHeight: 300,
            itemHeight: 48,
          ),
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  void _showExitConfirmationDialog(VoidCallback onConfirmExit) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Czy na pewno chcesz wyjść?',
        subtitle: 'Twój progres nie zostanie zapisany.',
        confirmText: 'Wyjdź',
        cancelText: 'Anuluj',
        onConfirm: onConfirmExit,
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildMultiSelectField(MultiSelectDialogField field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textColor1,
          ),
        ),
        const SizedBox(height: 8),
        CustomMultiSelectDropdown(
          items: field.items,
          selectedItems: field.selectedItems,
          onSelectionChanged: (selected) {
            field.onSelectionChanged(selected);
            field.onInternalChanged?.call();
          },
          hintText: field.hintText,
          width: field.width,
          height: field.height,
        ),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _buildRowField(RowDialogField field) {
    return Column(
      children: [
        Row(
          children: field.children
              .map((child) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _buildInputField(child),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

enum DialogInputType { text, dropdown, multiSelect, row }

class DialogInputField {
  final String label;
  final TextEditingController? controller;
  final DialogInputType type;

  DialogInputField({
    required this.label,
    this.controller,
    this.type = DialogInputType.text,
  });
}

class DropdownDialogField extends DialogInputField {
  String? selectedValue;
  final List<DropdownItem> items;
  final String hintText;
  ValueChanged<String?> onChanged;
  VoidCallback? onInternalChanged;

  DropdownDialogField({
    required String label,
    required this.items,
    required this.onChanged,
    this.selectedValue,
    this.hintText = 'Wybierz opcję',
    this.onInternalChanged,
  }) : super(
          label: label,
          type: DialogInputType.dropdown,
        );
}

class DropdownItem {
  final String value;
  final String label;

  DropdownItem({
    required this.value,
    required this.label,
  });
}

class DialogActionButton {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  DialogActionButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.blue,
    this.textColor = AppColors.textColor2,
  });
}

class MultiSelectDialogField extends DialogInputField {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String hintText;
  final double width;
  final double height;
  VoidCallback? onInternalChanged;

  MultiSelectDialogField({
    required String label,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.hintText = 'Wybierz tagi',
    this.width = 360,
    this.height = 56,
    this.onInternalChanged,
  }) : super(
          label: label,
          type: DialogInputType.multiSelect,
        );
}

class RowDialogField extends DialogInputField {
  final List<DialogInputField> children;
  
  RowDialogField({
    required this.children,
  }) : super(
    label: '',
    type: DialogInputType.row,
  );
}