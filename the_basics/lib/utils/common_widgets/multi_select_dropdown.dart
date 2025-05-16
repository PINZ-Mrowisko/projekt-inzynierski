import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String hintText;
  final double width;
  final double height;
  final IconData? leadingIcon;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.hintText = 'Wybierz tagi',
    this.width = 360,
    this.height = 56,
    this.leadingIcon,
  });

  @override
  State<CustomMultiSelectDropdown> createState() => _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedItems);
  }

  void _showMultiSelectDialog() async {
    List<String> tempSelected = List<String>.from(_selected);

    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final itemCount = widget.items.length;
            final maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
            final contentHeight = 150.0 + (itemCount * 56.0);
            final dialogHeight = contentHeight.clamp(300.0, maxDialogHeight);

            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: 547,
                height: dialogHeight,
                decoration: BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.hintText,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Roboto',
                              height: 40/32,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 24),
                            onPressed: () => Navigator.pop(context, _selected),
                            style: IconButton.styleFrom(
                              fixedSize: const Size(48, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: widget.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tempSelected.contains(item)
                                      ? AppColors.blue.withOpacity(0.2)
                                      : AppColors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CheckboxListTile(
                                  value: tempSelected.contains(item),
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        tempSelected.add(item);
                                      } else {
                                        tempSelected.remove(item);
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF2C2C2C),
                                  checkColor: AppColors.pageBackground,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  title: Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textColor1,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, tempSelected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            'Zapisz',
                            style: TextStyle(
                              color: AppColors.textColor2,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selected = selected;
        widget.onSelectionChanged(_selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = _selected.isEmpty ? widget.hintText : _selected.join(', ');

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            hoverColor: AppColors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.textColor2,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          child: GestureDetector(
            onTap: _showMultiSelectDialog,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                if (widget.leadingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(widget.leadingIcon, color: AppColors.textColor2),
                  ),
                Expanded(
                  child: Text(
                    selectedText,
                    style: TextStyle(
                      color: _selected.isEmpty ? AppColors.textColor2 : AppColors.textColor1,
                      fontSize: 16,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textColor2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}