import 'package:flutter/material.dart';
import 'package:the_basics/features/schedules/widgets/base_dialog.dart';
import 'package:the_basics/utils/app_colors.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onSelectionChanged;
  final String hintText;
  final double width;
  final double height;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.hintText = 'Wybierz tagi',
    this.width = 360,
    this.height = 56,
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
            return BaseDialog(
              width: 400,
              height: 400,
              showCloseButton: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.hintText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: widget.items.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: tempSelected.contains(item)
                                    ? AppColors.blue.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: tempSelected.contains(item)
                                        ? AppColors.blue
                                        : AppColors.textColor1,
                                  ),
                                ),
                                trailing: Checkbox(
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
                                  activeColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    if (tempSelected.contains(item)) {
                                      tempSelected.remove(item);
                                    } else {
                                      tempSelected.add(item);
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, _selected),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Anuluj'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, tempSelected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Zatwierdź',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
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
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hoverColor: Colors.transparent,
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
    );
  }
}