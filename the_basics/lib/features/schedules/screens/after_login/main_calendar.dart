import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import '../../../../utils/common_widgets/side_menu.dart';
import '../../../employees/controllers/user_controller.dart';
import '../../../../utils/app_colors.dart';
import 'package:the_basics/features/employees/screens/employee_management.dart';
import '../../../tags/controllers/tags_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: const SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Grafik ogólny',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logo,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: buildTagFilterDropdown(
                            tagsController,
                            selectedTags,
                          ),
                        ),

                        const SizedBox(width: 16),
                        buildSearchBar(),
                        const SizedBox(width: 16),

                        CustomButton(
                          onPressed: () {},
                          text: "Generuj grafik",
                          width: 155,
                          icon: Icons.edit,
                        ),
                        const SizedBox(width: 10),

                        CustomButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => BaseDialog(
                                    width: 551,
                                    showCloseButton: true,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 32),
                                        Text(
                                          "Wybierz opcję eksportu grafiku.",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textColor2,
                                          ),
                                        ),
                                        const SizedBox(height: 48),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 160,
                                              height: 56,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  // dodać logikę drukowania
                                                },
                                                icon: const Icon(
                                                  Icons.print,
                                                  color: AppColors.textColor2,
                                                ),
                                                label: const Text(
                                                  "Drukuj",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textColor2,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.lightBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 32),
                                            SizedBox(
                                              width: 160,
                                              height: 56,
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  // dodać logikę zapisu do PDF
                                                  showCustomSnackbar(context, "Grafik został pomyślnie zapisany.");
                                                },
                                                icon: const Icon(
                                                  Icons.download,
                                                  color: AppColors.textColor2,
                                                ),
                                                label: const Text(
                                                  "Zapisz jako PDF",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textColor2,
                                                  ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.lightBlue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 32),
                                      ],
                                    ),
                                  ),
                            );
                          },
                          text: "Eksportuj",
                          width: 125,
                          icon: Icons.download,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.timelineWeek,
                      firstDayOfWeek: 1,
                      timeSlotViewSettings: TimeSlotViewSettings(
                        startHour: 8, // początek dnia 
                        endHour: 15, // koniec dnia 
                        //timeIntervalHeight: 60,
                      ),
                      todayHighlightColor: AppColors.logo,
                    ),
                    
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


