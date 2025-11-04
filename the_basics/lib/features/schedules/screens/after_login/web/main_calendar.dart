import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/schedules/usecases/choose_existing_schedule.dart';
import 'package:the_basics/features/schedules/usecases/choose_schedule_generation_type.dart';
import 'package:the_basics/features/schedules/usecases/choose_template.dart';
import 'package:the_basics/features/schedules/usecases/choose_work_code_rules_dialog.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';
import '../../../../../utils/common_widgets/side_menu.dart';
import '../../../../../utils/platform_controller.dart';
import '../../../../employees/controllers/user_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../tags/controllers/tags_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

class MainCalendar extends StatefulWidget {
  const MainCalendar({super.key});

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
  final CalendarController _calendarController = CalendarController();

  final platformController = Get.find<PlatformController>();
  // use method from this to detect device!

  DateTime? _lastBackPressTime;
  final RxList<String> _selectedTags = <String>[].obs;

  @override
  void initState() {
    super.initState();
    final userController = Get.find<UserController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.resetFilters();
    });

    ever(_selectedTags, (tags) {
      userController.filterEmployees(tags);
    });
  }

  // PLACEHOLDER to be implemented
void _handleRulesSelected(List<String> selectedRules) {
  print('Selected rules: $selectedRules');
  showGenerationMethodDialog(context, _handleMethodSelected); 
}

// PLACEHOLDER to be implemented
void _handleMethodSelected(String? selectedMethod) {
  print('Selected method: $selectedMethod');
  
  if (selectedMethod != null) {
    if (selectedMethod == 'template') {
      showChooseTemplateDialog(context, _handleTemplateSelected);
    } else if (selectedMethod == 'existing_schedule') {
      showChooseExistingScheduleDialog(context, _handleScheduleSelected);
    }
  }
}

// PLACEHOLDER to be implemented
void _handleTemplateSelected(String? selectedTemplate) {
  print('Selected template: $selectedTemplate');
  if (selectedTemplate != null) {
    _generateAndNavigateToEdit(selectedTemplate, 'template');
  }
}

// PLACEHOLDER to be implemented
void _handleScheduleSelected(String? selectedSchedule) {
  print('Selected schedule: $selectedSchedule');
  if (selectedSchedule != null) {
    _generateAndNavigateToEdit(selectedSchedule, 'existing_schedule');
  }
}

// PLACEHOLDER to be implemented
void _generateAndNavigateToEdit(String sourceId, String sourceType) {
  try {
    final newScheduleId = _generateNewSchedule(sourceId, sourceType);
    
    Get.toNamed('/grafik-ogolny/edytuj-grafik', arguments: {
      'scheduleId': newScheduleId,
      'sourceType': sourceType,
      'initialDate': _calendarController.displayDate
    });
    
    // Show success message
    showCustomSnackbar(
      context,
      sourceType == 'template' 
        ? "Wygenerowano nowy grafik z szablonu" 
        : "Wygenerowano nowy grafik z istniejącego grafiku",
    );
    
  } catch (e) {
    // Show error message if generation fails
    showCustomSnackbar(
      context,
      "Błąd podczas generowania grafiku: $e",
    );
  }
}

// PLACEHOLDER to be implemented
String _generateNewSchedule(String sourceId, String sourceType) {
  print('Generating new schedule from $sourceType: $sourceId');
  
  return 'generated_${DateTime.now().millisecondsSinceEpoch}';
}

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final bool mustWait = _lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (mustWait) {
      _lastBackPressTime = now;
      Get.snackbar(
        'Naciśnij ponownie, aby wyjść',
        'Naciśnij przycisk "Wstecz" jeszcze raz, aby zamknąć aplikację',
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }


  List<Appointment> _getAppointments(List<UserModel> filteredEmployees) {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<Appointment> appointments = [];
    for (final employee in filteredEmployees) {
      for (int day = 0; day < 5; day++) {
        final isMorningShift = day % 2 == 0;
        final startHour = isMorningShift ? 8 : 12;
        final endHour = isMorningShift ? 16 : 20;

        appointments.add(
          Appointment(
            startTime: DateTime(monday.year, monday.month, monday.day + day, startHour, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + day, endHour, 0),
            subject: 'Zmiana ${isMorningShift ? 'poranna' : 'popołudniowa'}',
            color: isMorningShift ? AppColors.logo : AppColors.logolighter,
            resourceIds: <Object>[employee.id],
          ),
        );
      }
    }

    List<Appointment> repeatedAppointments = [];
    for (int week = 0; week < 4; week++) {
      Duration weekOffset = Duration(days: 7 * week);
      for (var appointment in appointments) {
        repeatedAppointments.add(
          Appointment(
            startTime: appointment.startTime.add(weekOffset),
            endTime: appointment.endTime.add(weekOffset),
            subject: appointment.subject,
            color: appointment.color,
            resourceIds: appointment.resourceIds,
          ),
        );
      }
    }

    return repeatedAppointments;
  }

  List<TimeRegion> _getSpecialRegions() {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(365, (index) {
      final day = monday.subtract(const Duration(days: 180)).add(Duration(days: index));
      return TimeRegion(
        startTime: DateTime(day.year, day.month, day.day, 8, 0),
        endTime: DateTime(day.year, day.month, day.day, 20, 59),
        enablePointerInteraction: false,
        color: day.weekday.isEven ? AppColors.lightBlue : Colors.transparent,
        text: '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHours = 13;
    final visibleDays = 8.5;
    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    
    return PopScope(
    canPop: false,
      child: Obx(() {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: SideMenu(),
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
                          Text(
                            'Grafik ogólny',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logo,
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: _buildTagFilterDropdown(tagsController),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: _buildSearchBar(),
                                ),
                                const SizedBox(width: 16),
                                Flexible(
                                  child: CustomButton(
                                    onPressed: () => showWorkCodeRulesDialog(context, _handleRulesSelected),
                                    text: "Generuj grafik",
                                    width: 155,
                                    icon: Icons.add,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: CustomButton(
                                    onPressed: () {
                                      Get.toNamed('/grafik-ogolny/edytuj-grafik', arguments: {'initialDate': _calendarController.displayDate});
                                    },
                                    text: "Edytuj grafik",
                                    width: 155,
                                    icon: Icons.edit,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: CustomButton(
                                    onPressed: () => showExportDialog(context),
                                    text: "Eksportuj",
                                    width: 125,
                                    icon: Icons.download,
                                    backgroundColor: AppColors.lightBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (userController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (userController.filteredEmployees.isEmpty) {
                          return const Center(child: Text('Brak dopasowań'));
                        }

                        return Stack(
                          children: [
                            SfCalendar(
                              controller: _calendarController,
                              view: CalendarView.timelineWeek,
                              showDatePickerButton: false,
                              showNavigationArrow: true,
                              headerStyle: CalendarHeaderStyle(
                                backgroundColor: AppColors.pageBackground,
                                textAlign: TextAlign.left,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              firstDayOfWeek: 1,
                              dataSource: _CalendarDataSource(
                                _getAppointments(userController.filteredEmployees),
                                userController.filteredEmployees,
                              ),
                              specialRegions: _getSpecialRegions(),
                              timeSlotViewSettings: TimeSlotViewSettings(
                                startHour: 8,
                                endHour: 21,
                                timeIntervalHeight: 40,
                                timeIntervalWidth: dynamicIntervalWidth,
                                timeInterval: const Duration(hours: 1),
                                timeFormat: 'HH:mm',
                                timeTextStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              todayHighlightColor: AppColors.logo,
                              resourceViewSettings: const ResourceViewSettings(
                                visibleResourceCount: 10,
                                size: 170,
                                showAvatar: false,
                                displayNameTextStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              appointmentBuilder: _buildAppointmentWidget,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      }),
    );
  }

  Widget _buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
  ) {
    final appointment = calendarAppointmentDetails.appointments.first;
    return Container(
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: Colors.white,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
            '${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (appointment.subject.isNotEmpty)
            Text(
              appointment.subject.replaceAll(' - ', ' '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }


  Widget _buildTagFilterDropdown(TagsController tagsController) {
    return Obx(() {
      return CustomMultiSelectDropdown(
        items: tagsController.allTags.map((tag) => tag.tagName).toList(),
        selectedItems: _selectedTags,
        onSelectionChanged: (selected) => _selectedTags.assignAll(selected),
        hintText: 'Filtruj po tagach',
        leadingIcon: Icons.filter_alt_outlined,
        widthPercentage: 0.2,
        maxWidth: 360,
        minWidth: 160,
      );
    });
  }

  Widget _buildSearchBar() {
    final userController = Get.find<UserController>();
    return CustomSearchBar(
      hintText: 'Wyszukaj pracownika',
      widthPercentage: 0.2,
      maxWidth: 360,
      minWidth: 160,
      onChanged: (query) {
        userController.searchQuery.value = query;
        userController.filterEmployees(_selectedTags);
      },
    );
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments, List<UserModel> employees) {
    this.appointments = appointments ?? [];
    this.resources = employees.map((employee) => CalendarResource(
      displayName: '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
      id: employee.id ?? '',
      color: AppColors.blue,
    )).toList() ?? [];
  }
}