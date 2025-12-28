import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/schedule_exporter.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/schedule_type.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/side_menu.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../../employees/controllers/user_controller.dart';
import '../../../../leaves/controllers/leave_controller.dart';
import '../../../controllers/schedule_controller.dart';

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
  final GlobalKey individualCalendarKey = GlobalKey();
  final isExporting = false.obs;

  List<Appointment> _getAppointments(List<UserModel> filteredEmployees, List<LeaveModel> leaves) {

    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    List<Appointment> baseAppointments = [];

    final scheduleController = Get.find<SchedulesController>();
    final userController = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();

    List<ScheduleModel> myShifts = scheduleController.getShiftsForEmployee(userController.employee.value.id);

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

      // making sure tiles in every screen look the same
      final tagNames = _convertTagIdsToNames(shift.tags, tagsController);
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

    for (final leave in leaves) {
      if (leave.status.toLowerCase() == 'zaakceptowany' ||
          leave.status.toLowerCase() == 'mój urlop') {
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
            subject: "Urlop",
            color: Colors.orangeAccent,
            notes: leave.comment?.isNotEmpty == true 
                ? leave.comment!
                : "Urlop",
          ),
        );
      }
    }

    return baseAppointments;
  }

  List<String> _convertTagIdsToNames(List<String> tagIds, TagsController tagsController) {
    final List<String> tagNames = [];
    
    for (final tagId in tagIds) {
      try {
        final foundTags = tagsController.allTags.where((t) => t.id == tagId).toList();
        
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

  Future<void> _exportCalendar() async {
  try {
    final visibleDate = _calendarController.displayDate;
    final monthName = _getPolishMonthName(visibleDate!.month);
    
    await ScheduleExporter.exportToPdf(
      type: ScheduleType.individualCalendar,
      chartKey: individualCalendarKey,
      title: 'Grafik indywidualny - $monthName ${visibleDate.year}',
      visibleDate: visibleDate,
    );
    
    if (mounted && context.mounted) {
      showCustomSnackbar(context, "Raport został pomyślnie zapisany.");
    }
  } catch (e) {
    if (mounted && context.mounted) {
      showCustomSnackbar(context, "Wystąpił błąd podczas eksportu raportu: $e");
    }
  } finally {
    isExporting.value = false;
  }
}

String _getPolishMonthName(int month) {
  switch (month) {
    case 1: return 'Styczeń';
    case 2: return 'Luty';
    case 3: return 'Marzec';
    case 4: return 'Kwiecień';
    case 5: return 'Maj';
    case 6: return 'Czerwiec';
    case 7: return 'Lipiec';
    case 8: return 'Sierpień';
    case 9: return 'Wrzesień';
    case 10: return 'Październik';
    case 11: return 'Listopad';
    case 12: return 'Grudzień';
    default: return '';
  }
}

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final leaveController = Get.find<LeaveController>();

    return Obx(() {
      final employee = userController.employee.value;

      // get all leave reqs
      final allLeaves = leaveController.allLeaveRequests;
      final userLeaves = allLeaves.where((l) =>
          l.userId == employee.id &&
          (l.status.toLowerCase() == 'zaakceptowany' ||
          l.status.toLowerCase() == 'mój urlop')
      ).toList();


      // get all shifts of employee from currently published schedule
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
                          onPressed: () => showExportDialog(context, _exportCalendar),
                          text: "Eksportuj",
                          width: 125,
                          icon: Icons.download,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RepaintBoundary(
                      key: individualCalendarKey,
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
                        appointmentBuilder: buildAppointmentWidget,
                        headerStyle: CalendarHeaderStyle(
                        backgroundColor: AppColors.pageBackground,),
                      ),
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
}

// same as in main calendar
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


