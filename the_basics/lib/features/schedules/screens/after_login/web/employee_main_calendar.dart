import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_converter.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/schedule_exporter.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/schedule_type.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
import 'package:the_basics/features/schedules/usecases/show_main_calendar_export_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';
import '../../../../../utils/common_widgets/side_menu.dart';
import '../../../../../utils/platform_controller.dart';
import '../../../../employees/controllers/user_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../tags/controllers/tags_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../controllers/schedule_controller.dart';
import 'main_calendar/utils/appointment_builder_employee.dart';
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

  final CalendarStateManager _stateManager = CalendarStateManager();

  final LeaveController _leaveController = Get.find<LeaveController>(); 

  final GlobalKey mainCalendarKey = GlobalKey();
  final isExporting = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _stateManager.initialize();
      await _loadSchedule();
    });

    ever(_selectedTags, (tags) {
      final userController = Get.find<UserController>();
      userController.filterEmployees(tags);
    });
  }

  Future<void> _loadSchedule() async {
    final userController = Get.find<UserController>();
    final schedulesController = Get.find<SchedulesController>();

    if (schedulesController.publishedScheduleID.value.isEmpty) {
      print('Brak opublikowanego grafiku');
      return;
    }

     await _stateManager.loadSchedule(
      marketId: userController.employee.value.marketId,
      scheduleId: schedulesController.publishedScheduleID.value,
    );

    await _leaveController.fetchLeaves();

    Get.find<SchedulesController>().validateShiftsAgainstLeaves();
  }

  Future<void> _exportCalendar() async {
    isExporting.value = true;
  try {
    await Future.delayed(const Duration(milliseconds: 300));
    final visibleDate = _calendarController.displayDate;
    
    await ScheduleExporter.exportToPdf(
      type: ScheduleType.mainCalendar,
      chartKey: mainCalendarKey,
      title: 'Grafik ogólny - ${_formatWeekTitle(visibleDate!)}',
      visibleDate: visibleDate,
    );
    
    if (mounted && context.mounted) {
      showCustomSnackbar(context, "Grafik został pomyślnie zapisany.");
    }
  } catch (e) {
    if (mounted && context.mounted) {
      showCustomSnackbar(context, "Wystąpił błąd podczas eksportu grafiku: $e");
    }
  } finally {
    isExporting.value = false;
  }
}

String _formatWeekTitle(DateTime date) {
  final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
  final endOfWeek = startOfWeek.add(Duration(days: 6));
  
  return '${startOfWeek.day}.${startOfWeek.month} - ${endOfWeek.day}.${endOfWeek.month}.${date.year}';
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final totalHours = 14;
    final visibleDays = 8.5;
    
    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final scheduleController = Get.find<SchedulesController>();

    return PopScope(
      canPop: false,
      child: Obx(() {
        return Stack(
          children: [
            Scaffold(
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
                                          onPressed: () => showMainCalendarExportDialog(context, _exportCalendar),
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
                              if (_stateManager.isLoading.value || _stateManager.isScheduleLoading.value) {
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
                              final allLeaves = _leaveController.allLeaveRequests;

                              // Get appointments from schedule
                              final appointments = _appointmentConverter.getAppointments(_stateManager.filteredEmployees, leaves: allLeaves);

                              if (appointments.isEmpty) {
                                return const Center(
                                  child: Text('Brak zmian do wyświetlenia'),
                                );
                              }

                              return Stack(
                                children: [
                                  RepaintBoundary(
                                    key: mainCalendarKey,
                                    child: SfCalendar(
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
                                        /// Use appointments from actual schedule
                                        appointments,
                                        _stateManager.filteredEmployees,
                                      ),
                                      specialRegions: _regionsBuilder.getSpecialRegions(),
                                      timeSlotViewSettings: TimeSlotViewSettings(
                                        startHour: 7,
                                        endHour: 21,
                                        timeIntervalHeight: 40,
                                        timeIntervalWidth: dynamicIntervalWidth,
                                        timeInterval: const Duration(hours: 1),
                                        timeFormat: 'HH:mm',
                                        timeTextStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        minimumAppointmentDuration: Duration(hours: 5, minutes: 15),
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
                                      appointmentBuilder: employeeBuildAppointmentWidget,
                                    ),
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
            ),
            
            // LOADING OVERLAY
            if (isExporting.value)
              Container(
                color: AppColors.pageBackground.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: AppColors.logo,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Eksportowanie grafiku...\n',
                                style: TextStyle(
                                  color: AppColors.logo,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: 'To może potrwać kilka sekund.\nProszę czekać.',
                                style: TextStyle(
                                  color: AppColors.textColor2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
  @override
  void dispose() {
    _stateManager.dispose();
    super.dispose();
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