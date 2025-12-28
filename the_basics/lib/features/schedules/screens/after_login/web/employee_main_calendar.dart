import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_converter.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
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

import '../../../controllers/schedule_controller.dart';
import 'main_calendar/utils/calendar_state_manager.dart';

class EmployeeMainCalendar extends StatefulWidget {
  const EmployeeMainCalendar({super.key});

  @override
  State<EmployeeMainCalendar> createState() => _EmployeeMainCalendarState();
}

class _EmployeeMainCalendarState extends State<EmployeeMainCalendar> {
  final CalendarController _calendarController = CalendarController();
  final SpecialRegionsBuilder _regionsBuilder = SpecialRegionsBuilder();
  final AppointmentConverter _appointmentConverter = AppointmentConverter();
  
  final platformController = Get.find<PlatformController>();
  // use method from this to detect device!

  final RxList<String> _selectedTags = <String>[].obs;

  final RxBool _isScheduleLoading = false.obs;

  final CalendarStateManager _stateManager = CalendarStateManager();


  @override
  void initState() {
    super.initState();

    final userController = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.resetFilters();
      //await _loadSchedule();
    });

    ever(_selectedTags, (tags) {
      userController.filterEmployees(tags);
    });

  }

  // Future<void> _loadSchedule() async {
  //
  //   final userController = Get.find<UserController>();
  //   final schedulesController = Get.find<SchedulesController>();
  //
  //   if (schedulesController.publishedScheduleID.value.isEmpty) {
  //     print('Brak opublikowanego grafiku');
  //     return;
  //   }
  //
  //   await _stateManager.loadSchedule(
  //     marketId: userController.employee.value.marketId,
  //     scheduleId: schedulesController.publishedScheduleID.value,
  //   );
  // }

  List<Appointment> _getAppointments(List<UserModel> filteredEmployees) {
    final scheduleController = Get.find<SchedulesController>();
    List<Appointment> baseAppointments = [];

    baseAppointments = scheduleController.individualShifts.map((shift) {

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

      return Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: 'Zmiana',
        color: AppColors.logo,
        resourceIds: <Object>[shift.employeeID],
        notes: shift.tags.join(', '),
      );

    }).toList();

    return baseAppointments;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHours = 13;
    final visibleDays = 8.5;
    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final scheduleController = Get.find<SchedulesController>();

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
                          if (userController.isLoading.value || _isScheduleLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (scheduleController.individualShifts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Brak opublikowanego grafiku'),
                                  SizedBox(height: 16),

                                ],
                              ),
                            );
                          }

                          // Get appointments from schedule
                          final appointments = _appointmentConverter.getAppointments(userController.filteredEmployees);

                          if (appointments.isEmpty) {
                            return const Center(
                              child: Text('Brak zmian do wyświetlenia'),
                            );
                          }




                          return Stack(
                            children: [
                              SfCalendar(
                                controller: _calendarController,
                                view: CalendarView.timelineWeek,
                                showDatePickerButton: false,
                                showNavigationArrow: true,
                                // initialDisplayDate: DateTime(2026, 1, 5), // Set to your schedule start date
                                // initialSelectedDate: DateTime(2026, 1, 5), // Set to your schedule start date
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
                                  /// Use appointments from actual schedule
                                  appointments,
                                  userController.filteredEmployees,
                                ),
                                specialRegions: _regionsBuilder.getSpecialRegions(),
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  startHour: 5,
                                  endHour: 22,
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
                                appointmentBuilder: buildAppointmentWidget,
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
    resources = employees.map((employee) => CalendarResource(
      displayName: '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
      id: employee.id ?? '',
      color: AppColors.blue,
    )).toList() ?? [];
  }
}