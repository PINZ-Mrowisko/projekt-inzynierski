import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
import 'package:the_basics/features/schedules/usecases/confirm_schedule_publish_dialog.dart';
import 'package:the_basics/features/schedules/usecases/show_confirmations.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';
import '../../../../../../utils/common_widgets/side_menu.dart';
import '../../../../../auth/models/user_model.dart';
import '../../../../../employees/controllers/user_controller.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../tags/controllers/tags_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import '../../../../models/schedule_model.dart';

class MainCalendarEdit extends StatefulWidget {
  const MainCalendarEdit({super.key});

  @override
  State<MainCalendarEdit> createState() => _MainCalendarEditState();
}

class _MainCalendarEditState extends State<MainCalendarEdit> {
  late DateTime initialDate;
  late String scheduleId;
  late String marketId;
  final CalendarController _calendarController = CalendarController();
  final RxList<String> _selectedTags = <String>[].obs;

  final SpecialRegionsBuilder _regionsBuilder = SpecialRegionsBuilder();


  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    scheduleId = args['scheduleId'] ?? '';
    marketId = args['marketId'] ?? '';
    initialDate = args['initialDate'] ?? DateTime.now();

    _calendarController.displayDate = initialDate;

    final userController = Get.find<UserController>();
    final scheduleController = Get.find<SchedulesController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.resetFilters();

      if (scheduleController.individualShifts.isEmpty && scheduleId.isNotEmpty && marketId.isNotEmpty) {
        await scheduleController.fetchAndParseGeneratedSchedule(
          marketId: marketId,
          scheduleId: scheduleId,
        );
      }
    });

    ever(_selectedTags, (tags) {
      userController.filterEmployees(tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final totalHours = 14;
    final visibleDays = 8.5;
    
    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final userController = Get.find<UserController>();
    final scheduleController = Get.find<SchedulesController>();
    final tagsController = Get.find<TagsController>();

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Obx(() {
        // Pokaż ładowanie jeśli schedule się ładuje
        if (scheduleController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: SideMenu(
                onNavigation: (route) {
                  showLeaveConfirmationDialog(() {
                    Get.toNamed(route);
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, size: 28, color: AppColors.logo),
                            onPressed: () {
                              showLeaveConfirmationDialog(() {
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Edycja grafiku',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.logo,
                                  ),
                                ),

                              ],
                            ),
                          ),
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
                                    onPressed: () => showPublishConfirmationDialog(_handlePublishSchedule),
                                    text: "Opublikuj grafik",
                                    width: 155,
                                    icon: Icons.publish,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // INFO PANEL
                    if (scheduleController.individualShifts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Wyświetlono ${scheduleController.individualShifts.length} zmian',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Spacer(),
                            Text(
                              'Załadowany grafik',
                              style: TextStyle(
                                color: AppColors.logo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // CALENDAR
                    Expanded(
                      child: _buildCalendarBody(
                        intervalWidth: dynamicIntervalWidth,
                        scheduleController: scheduleController,
                        userController: userController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCalendarBody({
    required double intervalWidth,
    required SchedulesController scheduleController,
    required UserController userController,
  }) {
    // Jeśli nie ma załadowanych zmian
    if (scheduleController.individualShifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Brak załadowanego grafiku'),
            SizedBox(height: 8),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await scheduleController.fetchAndParseGeneratedSchedule(
                  marketId: marketId,
                  scheduleId: scheduleId,
                );
              },
              child: Text('Załaduj ponownie'),
            ),
          ],
        ),
      );
    }

    // Stwórz appointments z rzeczywistych danych
    final appointments = _getAppointmentsFromSchedule(
      scheduleController.individualShifts,
      userController.filteredEmployees,
    );

    if (appointments.isEmpty) {
      return Center(child: Text('Brak zmian do wyświetlenia'));
    }

    return SfCalendar(
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
        appointments,
        userController.filteredEmployees,
      ),
      specialRegions: _regionsBuilder.getSpecialRegions(),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 7,
        endHour: 21,
        timeIntervalHeight: 40,
        timeIntervalWidth: intervalWidth,
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
      appointmentBuilder: buildAppointmentWidget,
    );
  }

  /// Konwertuj ScheduleModel na Appointment
  List<Appointment> _getAppointmentsFromSchedule(
      List<ScheduleModel> shifts,
      List<UserModel> filteredEmployees,
      ) {
    final filteredEmployeeIds = filteredEmployees.map((e) => e.id).toSet();

    final tagsController = Get.find<TagsController>();

    return shifts.where((shift) => filteredEmployeeIds.contains(shift.employeeID)).map((shift) {
      final startDateTime = DateTime(
        shift.shiftDate.year,
        shift.shiftDate.month,
        shift.shiftDate.day,
        shift.start.hour,
        shift.start.minute,
      );

      final endDateTime = DateTime(
        shift.shiftDate.year,
        shift.shiftDate.month,
        shift.shiftDate.day,
        shift.end.hour,
        shift.end.minute,
      );

      // making sure tiles in every screen look the same
      final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
      final displayTags = tagNames.isNotEmpty 
          ? tagNames.join(', ')
          : 'Brak tagów';

      return Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: displayTags,
        color: _getAppointmentColor(shift),
        resourceIds: <Object>[shift.employeeID],
        id: '${shift.employeeID}_${shift.shiftDate.day}_'
            '${shift.start.hour}:${shift.start.minute}_'
            '${shift.end.hour}:${shift.end.minute}',
        notes: displayTags,
      );
    }).toList();
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

  List<String> _convertTagIdsToNames(List<String> tagIds, TagsController tagsController) {
    final List<String> tagNames = [];
    
    for (final tagId in tagIds) {
      final tag = tagsController.allTags.firstWhere(
        (t) => t.id == tagId,
      );
      
      if (tag != null && tag.tagName != null && tag.tagName!.isNotEmpty) {
        tagNames.add(tag.tagName!);
      } else {
        tagNames.add(tagId);
      }
    }
    
    return tagNames;
  }

Color _getAppointmentColor(ScheduleModel shift) {
  if (shift.start.hour >= 12) {
    return AppColors.logolighter;
  } else {
    return AppColors.logo;
  }
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

  void _handlePublishSchedule() {
    final scheduleController = Get.find<SchedulesController>();

    scheduleController.publishSchedule(marketId: marketId, scheduleId: scheduleId);

    showCustomSnackbar(
      context,
      'Grafik został opublikowany!',
    );

    final routeName = '/grafik-ogolny-kierownik';

    Get.offAllNamed(
      routeName,
      arguments: {},
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