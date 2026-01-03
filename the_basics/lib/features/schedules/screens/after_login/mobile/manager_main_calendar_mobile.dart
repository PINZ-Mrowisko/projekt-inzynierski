import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
import 'package:the_basics/features/schedules/usecases/show_employee_search_dialog_mobile.dart';
import 'package:the_basics/features/schedules/usecases/show_tags_filtering_dialog_mobile.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';


import '../../../controllers/schedule_controller.dart';
import '../../../models/schedule_model.dart';

class ManagerMainCalendarMobile extends StatefulWidget {
  const ManagerMainCalendarMobile({super.key});

  @override
  State<ManagerMainCalendarMobile> createState() => _ManagerMainCalendarMobileState();
}

class _ManagerMainCalendarMobileState extends State<ManagerMainCalendarMobile> {
  final RxInt _currentMenuIndex = 0.obs;
  final RxList<String> _selectedTags = <String>[].obs;
  DateTime? _lastBackPressTime;

  DateTime _visibleStartDate = DateTime.now();
  final int _visibleDays = 3;
  
  final CalendarController _calendarController = CalendarController();
  final SpecialRegionsBuilder _regionsBuilder = SpecialRegionsBuilder();

  final LeaveController _leaveController = Get.find<LeaveController>();
  final TagsController _tagsController = Get.find<TagsController>();
 
  @override
  void initState() {
    super.initState();
    _calendarController.displayDate =
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 7);

    final userController = Get.find<UserController>();
    final scheduleController = Get.find<SchedulesController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.resetFilters();

      await _leaveController.fetchLeaves();
      await scheduleController.validateShiftsAgainstLeaves();
    });
    ever(_selectedTags, (tags) {
      userController.filterEmployees(tags);
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final mustWait = _lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2);
    if (mustWait) {
      _lastBackPressTime = now;
      Get.snackbar(
        'Naciśnij ponownie, aby wyjść',
        'Naciśnij jeszcze raz, aby zamknąć aplikację',
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  // handling global calendar view change
  void _goToPreviousRange() {
    setState(() {
      _visibleStartDate =
          _visibleStartDate.subtract(Duration(days: _visibleDays));
      _calendarController.displayDate =
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 7);
    });
  }

  void _goToNextRange() {
    setState(() {
      _visibleStartDate = _visibleStartDate.add(Duration(days: _visibleDays));
    _calendarController.displayDate =
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 7);
    });
  }

  String _getDateRangeText() {
    final endDate = _visibleStartDate.add(Duration(days: _visibleDays - 1));
    
    if (_visibleStartDate.month == endDate.month) {
      return '${_visibleStartDate.day}.${_visibleStartDate.month} - '
            '${endDate.day}.${endDate.month}';
    } else {
      return '${_visibleStartDate.day}.${_visibleStartDate.month} - '
            '${endDate.day}.${endDate.month}';
    }
  }

  List<Appointment> _getAppointments(String userID) {
    final scheduleController = Get.find<SchedulesController>();
    final allLeaves = _leaveController.allLeaveRequests;

    List<Appointment> baseAppointments = [];

    List<ScheduleModel> myShifts = scheduleController.getShiftsForEmployee(userID);

    baseAppointments = myShifts.map((shift) {
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

      final tagNames = _convertTagIdsToNames(shift.tags);
      final displayTags = tagNames.isNotEmpty 
          ? tagNames.join(', ')
          : 'Brak tagów';

      return Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: displayTags,
        resourceIds: <Object>[shift.employeeID],
        color: _getAppointmentColor(shift),
        notes: displayTags,
        id: '${shift.employeeID}_${shift.shiftDate.day}_${shift.start.hour}:${shift.start.minute}_${shift.end.hour}:${shift.end.minute}',
      );
    }).toList();

    final userLeaves = allLeaves.where((leave) =>
        leave.userId == userID &&
        (leave.status.toLowerCase() == 'zaakceptowany' ||
         leave.status.toLowerCase() == 'mój urlop')).toList();

    for (final leave in userLeaves) {
      final startDateTime = DateTime(
        leave.startDate.year,
        leave.startDate.month,
        leave.startDate.day,
        8,
        0,
      );

      final endDateTime = DateTime(
        leave.endDate.year,
        leave.endDate.month,
        leave.endDate.day,
        16,
        0,
      );

      baseAppointments.add(
        Appointment(
          startTime: startDateTime,
          endTime: endDateTime,
          subject: 'Urlop',
          color: Colors.orangeAccent,
          notes: leave.comment?.isNotEmpty == true 
              ? leave.comment!
              : 'Urlop',
        ),
      );
    }

    return baseAppointments;
  }

  List<String> _convertTagIdsToNames(List<String> tagIds) {
    final List<String> tagNames = [];
    
    for (final tagId in tagIds) {
      try {
        final foundTags = _tagsController.allTags.where((t) => t.id == tagId).toList();
        
        if (foundTags.isNotEmpty) {
          final tag = foundTags.first;
          if (tag.tagName != null && tag.tagName!.isNotEmpty) {
            tagNames.add(tag.tagName!);
          } else {
            tagNames.add(tagId);
          }
        } else {
          tagNames.add(tagId);
        }
      } catch (e) {
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

  Widget _buildEmployeeCalendar(UserModel employee, List<UserModel> filteredEmployees) {
    final appointments = _getAppointments(employee.id);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            '${employee.firstName ?? ''} ${employee.lastName ?? ''}',
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        SizedBox(
          height: 130,
          child: SfCalendar(
            backgroundColor: AppColors.pageBackground,
            controller: _calendarController,
            view: CalendarView.timelineWeek,
            showDatePickerButton: false,
            showNavigationArrow: false,
            headerHeight: 0,
            firstDayOfWeek: 1,
            dataSource: _CalendarDataSource(appointments),
            specialRegions: _regionsBuilder.getSpecialRegions(),
            appointmentBuilder: buildAppointmentWidget,
            allowedViews: const [],
            allowViewNavigation: true,
            viewHeaderHeight: 30,
            todayHighlightColor: AppColors.logo,
            showCurrentTimeIndicator: true,
            timeSlotViewSettings: TimeSlotViewSettings(
              startHour: 7,
              endHour: 21,
              timeInterval: const Duration(hours: 1),
              timeIntervalWidth: screenWidth / (3 * 14),
              timeTextStyle: const TextStyle(color: AppColors.transparent, fontSize: 0),
              numberOfDaysInView: 3,
                minimumAppointmentDuration: Duration(hours: 8, minutes: 0)
            ),
          ),
        ),

        Divider(height: 1, color: AppColors.divider),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _onWillPop(),
      child: Obx(() => Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: AppColors.pageBackground,
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Grafik ogólny',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                showTagsFilterDialog(context, _selectedTags);
                              },
                              icon: const Icon(Icons.filter_alt_outlined, size: 30),
                              color: AppColors.logo,
                            ),
                            IconButton(
                              onPressed: () {
                                showEmployeeSearchDialog(context, _selectedTags);
                              },
                              icon: const Icon(Icons.search_outlined, size: 30),
                              color: AppColors.logo,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                color: AppColors.pageBackground,
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        DateFormat('MMM yyyy', 'pl').format(_visibleStartDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 22),
                      color: AppColors.logo,
                      onPressed: _goToPreviousRange,
                    ),
                    Text(
                      _getDateRangeText(),
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 22),
                      color: AppColors.logo,
                      onPressed: _goToNextRange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Obx(() {
          if (userController.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.logo));
          }
          final employees = userController.filteredEmployees;
          if (employees.isEmpty) {
            return const Center(
              child: Text(
                'Brak dopasowań',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) =>
                _buildEmployeeCalendar(employees[index], employees),
          );
        }),
        bottomNavigationBar: MobileBottomMenu(currentIndex: _currentMenuIndex),
      ),
      )
    );
  }
}
  
class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
