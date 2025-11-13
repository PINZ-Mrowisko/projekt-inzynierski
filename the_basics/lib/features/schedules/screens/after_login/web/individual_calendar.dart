import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/side_menu.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../../employees/controllers/user_controller.dart';
import '../../../../tags/controllers/tags_controller.dart';
import '../../../../leaves/controllers/leave_controller.dart';

/// panel boczny
class SideInfoPanel extends StatelessWidget {
  final Appointment? todayShift;
  final Appointment? tomorrowShift;
  final LeaveModel? nextVacation;

  const SideInfoPanel({
    super.key,
    this.todayShift,
    this.tomorrowShift,
    this.nextVacation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            icon: Icons.today,
            title: "Dzisiaj",
            subtitle: todayShift?.subject ?? "Brak zmiany",
            time: todayShift != null
                ? "${todayShift!.startTime.hour.toString().padLeft(2, '0')}:${todayShift!.startTime.minute.toString().padLeft(2, '0')}"
                : "--",
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.calendar_today,
            title: "Jutro",
            subtitle: tomorrowShift?.subject ?? "Brak zmiany",
            time: tomorrowShift != null
                ? "${tomorrowShift!.startTime.hour.toString().padLeft(2, '0')}:${tomorrowShift!.startTime.minute.toString().padLeft(2, '0')}"
                : "--",
          ),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.flight_takeoff,
            title: "Najbliższy urlop",
            subtitle: nextVacation?.status ?? "Brak zaplanowanego urlopu",
            time: nextVacation != null
                ? "${nextVacation!.startDate.day.toString().padLeft(2, '0')}.${nextVacation!.startDate.month.toString().padLeft(2, '0')} - "
                    "${nextVacation!.endDate.day.toString().padLeft(2, '0')}.${nextVacation!.endDate.month.toString().padLeft(2, '0')}"
                : "--",
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.black),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.green),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: AppColors.black),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: TextStyle(color: AppColors.black, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}


class IndividualCalendar extends StatefulWidget {
  const IndividualCalendar({super.key});

  @override
  State<IndividualCalendar> createState() => _IndividualCalendarState();
}

class _IndividualCalendarState extends State<IndividualCalendar> {
  final CalendarController _calendarController = CalendarController();

  List<Appointment> _getAppointments(
      List<UserModel> filteredEmployees, List<LeaveModel> leaves) {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<Appointment> baseAppointments = [];

    // generuj 5 dni pracy
    for (final employee in filteredEmployees) {
      for (int day = 0; day < 5; day++) {
        final isMorningShift = day % 2 == 0;
        final startHour = isMorningShift ? 8 : 12;
        final endHour = isMorningShift ? 16 : 20;

        baseAppointments.add(
          Appointment(
            startTime: DateTime(
                monday.year, monday.month, monday.day + day, startHour, 0),
            endTime:
                DateTime(monday.year, monday.month, monday.day + day, endHour, 0),
            subject: 'Zmiana ${isMorningShift ? 'poranna' : 'popołudniowa'}',
            color: isMorningShift ? AppColors.logo : AppColors.logolighter,
            resourceIds: <Object>[employee.id],
          ),
        );
      }
    }

    // powiel 4 tygodnie
    List<Appointment> repeatedAppointments = [];
    for (int week = 0; week < 4; week++) {
      final Duration weekOffset = Duration(days: 7 * week);
      for (var appointment in baseAppointments) {
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

    // urlopy zaakceptowane
    for (final leave in leaves) {
      if (leave.status.toLowerCase() == 'zaakceptowany' || leave.status.toLowerCase() == 'mój urlop') {
        repeatedAppointments.add(
          Appointment(
            startTime: leave.startDate,
            endTime: leave.endDate.add(const Duration(hours: 23)),
            subject: "Urlop: ${leave.comment}",
            color: Colors.orangeAccent,
          ),
        );
      }
    }

    return repeatedAppointments;
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leaveController = Get.find<LeaveController>();
    final tagsController = Get.find<TagsController>();

    return Obx(() {
      final employee = userController.employee.value;

      final allLeaves = leaveController.allLeaveRequests;
      final userLeaves = allLeaves.where((l) =>
          l.userId == employee.id &&
          (l.status.toLowerCase() == 'zaakceptowany' ||
          l.status.toLowerCase() == 'mój urlop')
      ).toList();

      final appointments = _getAppointments([employee], userLeaves);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      Appointment? todayShift;
      Appointment? tomorrowShift;
      LeaveModel? nextVacation;

      for (final a in appointments) {
        if (a.subject.toLowerCase().contains('zmiana')) {
          final date = DateTime(a.startTime.year, a.startTime.month, a.startTime.day);
          if (date == today) todayShift = a;
          if (date == tomorrow) tomorrowShift = a;
        }
      }

      // znajdź najbliższy urlop
      final upcomingVacations = userLeaves
          .where((l) => l.startDate.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

      if (upcomingVacations.isNotEmpty) {
        nextVacation = upcomingVacations.first;
      }

    return Obx(() => Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SideMenu(),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Grafik indywidualny',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.logo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: SideInfoPanel(
                  todayShift: todayShift,
                  tomorrowShift: tomorrowShift,
                  nextVacation: nextVacation,
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        const Spacer(),
                        CustomButton(
                          onPressed: () => showExportDialog(context),
                          text: "Eksportuj",
                          width: 125,
                          icon: Icons.download,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SfCalendar(
                      controller: _calendarController,
                      view: CalendarView.month,
                      firstDayOfWeek: 1,
                      showNavigationArrow: true,
                      monthViewSettings: MonthViewSettings(
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.appointment,
                        appointmentDisplayCount: 2,
                      ),
                      todayHighlightColor: AppColors.logo,
                      dataSource: _CalendarDataSource(appointments, [employee]),
                      appointmentBuilder: _buildAppointmentWidget,
                      headerStyle: CalendarHeaderStyle(
                      backgroundColor: AppColors.pageBackground,),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
    );
    });
  }

Widget _buildAppointmentWidget(
    BuildContext context, CalendarAppointmentDetails details) {
  final appointment = details.appointments.first;

  // korekta przesunięcia kafelka
  const double horizontalOffsetFix = 3.0;

  return Transform.translate(
    offset: const Offset(horizontalOffsetFix, 0),
    child: Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height.clamp(20.0, 45.0), // zapobiega overflow
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: appointment.color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.white, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '${appointment.startTime.hour.toString().padLeft(2, '0')}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
                '${appointment.endTime.hour.toString().padLeft(2, '0')}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (appointment.subject.isNotEmpty)
              Flexible(
                child: Text(
                  appointment.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildExportButton(
      IconData icon, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 160,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textColor2),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments, List<UserModel> employees) {
    this.appointments = appointments;
    resources = employees
        .map((employee) => CalendarResource(
              displayName:
                  '${employee.firstName ?? ''} ${employee.lastName ?? ''}',
              id: employee.id ?? '',
              color: AppColors.blue,
            ))
        .toList();
  }
}


