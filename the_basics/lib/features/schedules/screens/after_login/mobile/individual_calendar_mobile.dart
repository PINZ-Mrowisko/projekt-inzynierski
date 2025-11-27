import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog_mobile.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';

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

@override
void initState() {
  super.initState();

  // ustawiamy początek widoku na poniedziałek
  _visibleStartDate = _getMonday(DateTime.now());
  _calendarController.displayDate = _visibleStartDate;

  final userController = Get.find<UserController>();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    userController.resetFilters();
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


  /// Generowanie harmonogramu dla zalogowanego użytkownika
  List<Appointment> _getAppointments(UserModel employee, List<LeaveModel> leaves) {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<Appointment> baseAppointments = [];

    // 5 dni pracy w tygodniu
    for (int day = 0; day < 5; day++) {
      final isMorningShift = day % 2 == 0;
      final startHour = isMorningShift ? 8 : 12;
      final endHour = isMorningShift ? 16 : 20;

      baseAppointments.add(Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + day, startHour, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + day, endHour, 0),
        subject: 'Zmiana ${isMorningShift ? 'poranna' : 'popołudniowa'}',
        color: isMorningShift ? AppColors.logo : AppColors.logolighter,
        resourceIds: <Object>[employee.id],
      ));
    }

    // powiel 4 tygodnie
    List<Appointment> repeatedAppointments = [];
    for (int week = 0; week < 4; week++) {
      final Duration weekOffset = Duration(days: 7 * week);
      for (var appointment in baseAppointments) {
        repeatedAppointments.add(Appointment(
          startTime: appointment.startTime.add(weekOffset),
          endTime: appointment.endTime.add(weekOffset),
          subject: appointment.subject,
          color: appointment.color,
          resourceIds: appointment.resourceIds,
        ));
      }
    }

// dodanie urlopów z godzinami 8-20
for (final leave in leaves) {
  if (leave.status.toLowerCase() == 'zaakceptowany' ||
      leave.status.toLowerCase() == 'mój urlop') {
    
    DateTime current = leave.startDate;
    while (!current.isAfter(leave.endDate)) {
      repeatedAppointments.add(
        Appointment(
          startTime: DateTime(current.year, current.month, current.day, 8, 0),
          endTime: DateTime(current.year, current.month, current.day, 20, 0),
          subject: "Urlop",
          color: Colors.orangeAccent,
        ),
      );
      current = current.add(const Duration(days: 1));
    }
  }
}

// USUŃ zmiany w dniach, w których pracownik ma urlop
for (final leave in leaves) {
  if (leave.status.toLowerCase() == 'zaakceptowany' ||
      leave.status.toLowerCase() == 'mój urlop') {
    
    repeatedAppointments.removeWhere((a) {
      final aDate = DateTime(a.startTime.year, a.startTime.month, a.startTime.day);
      final leaveStart = DateTime(leave.startDate.year, leave.startDate.month, leave.startDate.day);
      final leaveEnd = DateTime(leave.endDate.year, leave.endDate.month, leave.endDate.day);

      return a.subject.toLowerCase().contains("zmiana") &&
             (aDate.isAtSameMomentAs(leaveStart) ||
              (aDate.isAfter(leaveStart) && aDate.isBefore(leaveEnd)) ||
              aDate.isAtSameMomentAs(leaveEnd));
    });
  }
}


    return repeatedAppointments;
  }

  Widget _buildAppointmentWidget(
      BuildContext context, CalendarAppointmentDetails details) {
    final appointment = details.appointments.first;

    return Container(
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.white,
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.all(1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
            '${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (appointment.subject.isNotEmpty)
            Text(
              appointment.subject,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leaveController = Get.find<LeaveController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => _onWillPop(),
      child: Obx(() {
        if (userController.isLoading.value) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final employee = userController.employee.value;

        // pobierz urlopy zalogowanego użytkownika
final userLeaves = leaveController.allLeaveRequests.where((l) =>
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
      // Główny tytuł i przycisk eksportu
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

      // Pasek z miesiącem i strzałkami do zmiany tygodnia
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
    backgroundColor: AppColors.pageBackground,
    controller: _calendarController,
    view: CalendarView.schedule,
    showDatePickerButton: false,
    showNavigationArrow: false,
    headerHeight: 0,
    dataSource: _CalendarDataSource(appointments),
    appointmentBuilder: _buildAppointmentWidget,
    firstDayOfWeek: 1,
    todayHighlightColor: AppColors.logo,
    minDate: _visibleStartDate,
    maxDate: _visibleStartDate.add(const Duration(days: 6)),
    scheduleViewSettings: ScheduleViewSettings(
      dayHeaderSettings: DayHeaderSettings(
        dateTextStyle: TextStyle(fontSize: 16),
      ),
      appointmentItemHeight: 65,
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
