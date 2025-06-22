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

class MainCalendar extends StatefulWidget {
  const MainCalendar({super.key});

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

List<Employee> getSampleEmployees() {
  return [
    Employee(id: '1', name: 'Agata Zaparucha'),
    Employee(id: '2', name: 'Julia Osińska'),
    Employee(id: '3', name: 'Robert Piłat'),
    Employee(id: '4', name: 'Zofia Lorenc'),
    Employee(id: '5', name: 'Zofia Nowak'),
    Employee(id: '6', name: 'Agata Zaparucha'),
    Employee(id: '7', name: 'Julia Osińska'),
    Employee(id: '8', name: 'Robert Piłat'),
    Employee(id: '9', name: 'Zofia Lorenc'),
    Employee(id: '10', name: 'Zofia Nowak'),
    Employee(id: '11', name: 'Anna Nowak'),
  ];
}

List<Appointment> getSampleAppointments() {
  final DateTime now = DateTime.now();
  final DateTime monday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));

  List<Appointment> baseAppointments = [
    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day, 8, 0),
      endTime: DateTime(monday.year, monday.month, monday.day, 16, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['1'],
    ),

    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 1, 8, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 1, 16, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['2'],
    ),
    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 3, 8, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 3, 16, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['2'],
    ),

    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 2, 12, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 2, 20, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['3'],
    ),
    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 5, 12, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 5, 20, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['3'],
    ),

    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 2, 8, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 2, 16, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['4'],
    ),
    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 4, 8, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 4, 16, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['4'],
    ),

    Appointment(
      startTime: DateTime(monday.year, monday.month, monday.day + 2, 12, 0),
      endTime: DateTime(monday.year, monday.month, monday.day + 2, 20, 0),
      subject: 'Zaplanowana zmiana',
      color: AppColors.logo,
      resourceIds: <Object>['11'],
    ),
  ];

  List<Appointment> repeatedAppointments = [];

  for (int week = 0; week < 4; week++) {
    Duration weekOffset = Duration(days: 7 * week);
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

  return repeatedAppointments;
}

class _MainCalendarState extends State<MainCalendar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalHours = 13; 
    final visibleDays = 8.5; // 7 dni tygodnia + trochę zapasu
    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final controller = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    final RxBool isDatePickerOpen = false.obs;

    final CalendarController calendarController = CalendarController();
    final Rx<DateTime> currentWeekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;

    final employees = getSampleEmployees();
    final appointments = getSampleAppointments();

    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    final List<TimeRegion> specialRegions = List.generate(365, (index) {
      final day = monday
          .subtract(const Duration(days: 180))
          .add(Duration(days: index));
      return TimeRegion(
        startTime: DateTime(day.year, day.month, day.day, 8, 0),
        endTime: DateTime(day.year, day.month, day.day, 20, 59),
        enablePointerInteraction: false,
        color:
            day.weekday.isEven
                ? const Color.fromARGB(255,239, 232, 244)
                : Colors.transparent,
        text: '',
      );
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                            isDatePickerOpen.value = true;
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
                                                  showCustomSnackbar(
                                                    context,
                                                    "Grafik został pomyślnie zapisany.",
                                                  );
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {

                        return Stack(
                          children: [
                            SizedBox(
                              child: SfCalendar(
                                controller: calendarController,
                                view: CalendarView.timelineWeek,
                                showDatePickerButton: true,
                                headerStyle: CalendarHeaderStyle(
                                  backgroundColor: AppColors.pageBackground,
                                  textAlign: TextAlign.left,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                firstDayOfWeek: 1,
                                onTap: (CalendarTapDetails details) {
                                  if (details.targetElement ==
                                      CalendarElement.header) {
                                    isDatePickerOpen.value = true;
                                  } else {
                                    isDatePickerOpen.value = false;
                                  }
                                },
                                dataSource: ScheduleDataSource(
                                  appointments,
                                  employees,
                                ),
                                specialRegions: specialRegions,
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  startHour: 8,
                                  endHour: 21,
                                  timeIntervalHeight: 40,
                                  timeIntervalWidth: dynamicIntervalWidth,
                                  timeInterval: Duration(hours: 1),
                                  timeFormat: 'HH:mm',
                                  timeTextStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                todayHighlightColor: AppColors.logo,
                                resourceViewSettings: ResourceViewSettings(
                                  visibleResourceCount: 10,
                                  size: 145,
                                  showAvatar: false,
                                  displayNameTextStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                appointmentBuilder: (
                                  context,
                                  calendarAppointmentDetails,
                                ) {
                                  final appointment =
                                      calendarAppointmentDetails
                                          .appointments
                                          .first;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: appointment.color,
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 0.5,
                                      ),
                                    ),
                                    margin: EdgeInsets.all(1),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (appointment.subject.isNotEmpty)
                                          Text(
                                            appointment.subject.replaceAll(
                                              ' - ',
                                              ' ',
                                            ),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            Obx(
                              () =>
                                  isDatePickerOpen.value
                                      ? const SizedBox.shrink()
                                      : Positioned(
                                        top: 35,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.arrow_left,
                                              ),
                                              onPressed: () {
                                                calendarController.backward!();
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.arrow_right,
                                              ),
                                              onPressed: () {
                                                calendarController.forward!();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ],
                        );
                      },
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

class Employee {
  final String id;
  final String name;

  Employee({required this.id, required this.name});
}

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> appointments, List<Employee> employees) {
    this.appointments = appointments;
    this.resources =
        employees
            .map(
              (employee) => CalendarResource(
                displayName: employee.name,
                id: employee.id,
                color: AppColors.blue,
              ),
            )
            .toList();

    // specjalne regiony na tło dni
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));
  }
}
