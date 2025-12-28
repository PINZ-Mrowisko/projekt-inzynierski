import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog_mobile.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';

import '../../../controllers/schedule_controller.dart';
import '../../../models/schedule_model.dart';

class IndividualCalendarMobile extends StatefulWidget {
  const IndividualCalendarMobile({super.key});

  @override
  State<IndividualCalendarMobile> createState() =>
      _IndividualCalendarMobileState();
}

class _IndividualCalendarMobileState extends State<IndividualCalendarMobile> {
  final RxInt _currentMenuIndex = 1.obs;
  DateTime? _lastBackPressTime;
  final CalendarController _calendarController = CalendarController();

  DateTime _visibleStartDate = DateTime.now();
  final int _visibleDays = 7;

  final TagsController _tagsController = Get.find<TagsController>();
  final LeaveController _leaveController = Get.find<LeaveController>();


@override
void initState() {
  super.initState();

  // ustawiamy początek widoku na poniedziałek
  _visibleStartDate = _getMonday(DateTime.now());
  _calendarController.displayDate = _visibleStartDate;

  final userController = Get.find<UserController>();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    userController.resetFilters();
    await _leaveController.fetchLeaves();
  });
}

DateTime _getMonday(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
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

void _goToPreviousRange() {
  setState(() {
    _visibleStartDate = _getMonday(_visibleStartDate.subtract(const Duration(days: 7)));
    _calendarController.displayDate = _visibleStartDate;
  });
}

void _goToNextRange() {
  setState(() {
    _visibleStartDate = _getMonday(_visibleStartDate.add(const Duration(days: 7)));
    _calendarController.displayDate = _visibleStartDate;
  });
}


/// generowanie harmonogramu dla zalogowanego użytkownika
List<Appointment> _getAppointments(UserModel employee, List<LeaveModel> leaves) {
  final DateTime now = DateTime.now();

  final scheduleController = Get.find<SchedulesController>();
  final userController = Get.find<UserController>();

  List<ScheduleModel> myShifts = scheduleController.getShiftsForEmployee(userController.employee.value.id);

  List<Appointment> baseAppointments = [];

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
        resourceIds: <Object>[shift.employeeID],
        subject: displayTags,
        color: _getAppointmentColor(shift),
        notes: displayTags,
        id: '${shift.employeeID}_${shift.shiftDate.day}_${shift.start.hour}:${shift.start.minute}_${shift.end.hour}:${shift.end.minute}',
      );
    }).toList();


    for (final leave in leaves) {
      if (leave.status.toLowerCase() == 'zaakceptowany' ||
          leave.status.toLowerCase() == 'mój urlop') {
        DateTime current = leave.startDate;
        while (!current.isAfter(leave.endDate)) {
          baseAppointments.add(
            Appointment(
              startTime: DateTime(current.year, current.month, current.day, 8, 0),
              endTime: DateTime(current.year, current.month, current.day, 16, 0),
              subject: "Urlop",
              color: Colors.orangeAccent,
              notes: leave.comment?.isNotEmpty == true 
                  ? leave.comment!
                  : 'Urlop',
              resourceIds: <Object>[employee.id],
            ),
          );
          current = current.add(const Duration(days: 1));
        }
      }
    }

    // dodanie "Brak zmiany" dla pustych dni
    DateTime start = _visibleStartDate;
    for (int i = 0; i < _visibleDays; i++) {
      final date = start.add(Duration(days: i));

      bool hasEvent = baseAppointments.any((a) =>
          a.startTime.year == date.year &&
          a.startTime.month == date.month &&
          a.startTime.day == date.day);

      if (!hasEvent) {
        baseAppointments.add(
          Appointment(
            subject: "Brak zaplanowanej zmiany",
            startTime: DateTime(date.year, date.month, date.day, 8, 0),
            endTime: DateTime(date.year, date.month, date.day, 16, 0),
            color: Colors.grey,
            resourceIds: <Object>[employee.id],
            notes: 'Brak zaplanowanej zmiany',
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _onWillPop(),
      child: Obx(() {
        if (userController.isLoading.value) {
          return Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppColors.logo)));
        }

        final employee = userController.employee.value;

        // pobierz urlopy zalogowanego użytkownika
        final userLeaves = _leaveController.allLeaveRequests.where((l) =>
            l.userId == employee.id &&
            (l.status.toLowerCase() == 'zaakceptowany' ||
            l.status.toLowerCase() == 'mój urlop')
        ).toList();

                final appointments = _getAppointments(employee, userLeaves)
            .where((a) => a.subject.isNotEmpty) // filtrujemy tylko wydarzenia z nazwą
            .toList();

                return Scaffold(
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
                          'Grafik indywidualny',
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
                        child: IconButton(
                          onPressed: () => showExportDialogMobile(context),
                          icon: const Icon(Icons.download_outlined, size: 30),
                          color: AppColors.logo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // pasek z miesiącem i strzałkami do zmiany tygodnia
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
                      '${_visibleStartDate.day}.${_visibleStartDate.month} - '
                      '${_visibleStartDate.add(Duration(days: _visibleDays - 1)).day}.${_visibleStartDate.month}',
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



        body: Padding(
          padding: const EdgeInsets.all(12), 
          child: SfCalendar(
            allowViewNavigation: false,
            backgroundColor: AppColors.pageBackground,
            controller: _calendarController,
            view: CalendarView.schedule,
            showDatePickerButton: false,
            showNavigationArrow: false,
            headerHeight: 0,
            dataSource: _CalendarDataSource(appointments),
            appointmentBuilder: buildAppointmentWidget,
            firstDayOfWeek: 1,
            todayHighlightColor: AppColors.logo,
            minDate: _visibleStartDate,
            maxDate: _visibleStartDate.add(const Duration(days: 6)),
            scheduleViewSettings: ScheduleViewSettings(
              dayHeaderSettings: DayHeaderSettings(
                dateTextStyle: TextStyle(fontSize: 16),
              ),
              appointmentItemHeight: 60,
              monthHeaderSettings: MonthHeaderSettings(
                height: 0,
                backgroundColor: AppColors.pageBackground,
              ),
              hideEmptyScheduleWeek: false,
              

              weekHeaderSettings: WeekHeaderSettings(height: 0),
            ),
          ),
        ),

                  bottomNavigationBar: MobileBottomMenu(currentIndex: _currentMenuIndex),
                );
              }),
            );
          }
        }

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
