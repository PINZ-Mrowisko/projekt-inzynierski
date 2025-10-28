import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';

void showWorkCodeRulesDialog(BuildContext context, Function(List<String>) onRulesSelected) async {

  // example rules hardcoded for now
  final List<String> workCodeRules = [
    'Maksymalny czas pracy w tygodniu',
    'Minimalny czas odpoczynku między zmianami',
    'Maksymalna liczba godzin nadliczbowych',
    'Obowiązkowa przerwa w pracy',
    'Ochrona pracy nocnej',
    'Urlopy i dni wolne',
    'Praca w niedziele i święta',
    'Ochrona pracowników młodocianych',
    'Bezpieczeństwo i higiena pracy',
    'Równe traktowanie w zatrudnieniu',
  ];

  List<String> tempSelected = [];

  final selected = await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final itemCount = workCodeRules.length;
          final maxDialogHeight = MediaQuery.of(context).size.height * 0.8;
          final contentHeight = 200.0 + (itemCount * 56.0);
          final dialogHeight = contentHeight.clamp(400.0, maxDialogHeight);

          final screenWidth = MediaQuery.of(context).size.width;
          final dialogWidth = (screenWidth * 0.5).clamp(400.0, 600.0);

          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Container(
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
                        children: [
                          Expanded(
                            child: Text(
                              'Wybierz, które zasady kodeksu pracy zastosować przy generowaniu grafiku',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto',
                                color: AppColors.textColor2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: workCodeRules.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tempSelected.contains(item)
                                      ? AppColors.lightBlue
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: tempSelected.contains(item)
                                        ? AppColors.logo
                                        : AppColors.divider,
                                    width: 1,
                                  ),
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
                                  activeColor: AppColors.logo,
                                  checkColor: AppColors.white,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      color: tempSelected.contains(item)
                                          ? AppColors.textColor2
                                          : AppColors.textColor1,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            onPressed: () => Navigator.pop(context, null),
                            text: "Anuluj",
                            width: 120,
                            backgroundColor: AppColors.lightBlue,
                            textColor: AppColors.textColor2,
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            onPressed: () => Navigator.pop(context, tempSelected),
                            text: "Dalej",
                            width: 120,
                            icon: Icons.arrow_forward,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  if (selected != null) {
    onRulesSelected(selected);
  }
}