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
import '../../../auth/models/user_model.dart';

class MainCalendar extends StatefulWidget {
  const MainCalendar({super.key});

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> {
List<Appointment> getSampleAppointments(List<UserModel> users) {
  final DateTime now = DateTime.now();
  final DateTime monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  final sampleUsers = users.take(4).toList();

  final List<Appointment> appointments = [];

  // Definicja bazowych zmian w 1 tygodniu
  final List<Map<String, dynamic>> baseShifts = [
    {
      "offsetDay": 0,
      "startHour": 8,
      "endHour": 16,
      "userIndex": 0,
    },
    {
      "offsetDay": 1,
      "startHour": 8,
      "endHour": 16,
      "userIndex": 1,
    },
    {
      "offsetDay": 3,
      "startHour": 8,
      "endHour": 16,
      "userIndex": 1,
    },
    {
      "offsetDay": 2,
      "startHour": 12,
      "endHour": 20,
      "userIndex": 2,
    },
    {
      "offsetDay": 5,
      "startHour": 12,
      "endHour": 20,
      "userIndex": 2,
    },
    {
      "offsetDay": 2,
      "startHour": 8,
      "endHour": 16,
      "userIndex": 3,
    },
    {
      "offsetDay": 4,
      "startHour": 8,
      "endHour": 16,
      "userIndex": 3,
    },
  ];

  // Powtórz przez 4 tygodnie
  for (int weekOffset = 0; weekOffset < 4; weekOffset++) {
    for (var shift in baseShifts) {
      final userIndex = shift['userIndex'] as int;
      if (sampleUsers.length > userIndex) {
        final day = monday
            .add(Duration(days: (weekOffset * 7) + shift['offsetDay'] as int));
        appointments.add(
          Appointment(
            startTime:
                DateTime(day.year, day.month, day.day, shift['startHour'], 0),
            endTime:
                DateTime(day.year, day.month, day.day, shift['endHour'], 0),
            subject: 'Zaplanowana zmiana',
            color: AppColors.logo,
            resourceIds: [sampleUsers[userIndex].id],
          ),
        );
      }
    }
  }

  return appointments;
}

  @override
  void initState() {
    super.initState();
    Get.find<UserController>().initialize();
  }

  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    final RxBool isDatePickerOpen = false.obs;

    final CalendarController calendarController = CalendarController();
    final Rx<DateTime> currentWeekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).obs;

    final List<UserModel> users = controller.allEmployees;
    final appointments = getSampleAppointments(users);

    final DateTime now = DateTime.now();
    final DateTime monday = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );

//do poprawienia podział kalendarza na kolory
    final List<TimeRegion> specialRegions = List.generate(730, (index) {
      final day = monday
          .subtract(const Duration(days: 180))
          .add(Duration(days: index));
      return TimeRegion(
        startTime: DateTime(day.year, day.month, day.day, 8, 0),
        endTime: DateTime(day.year, day.month, day.day, 20, 59),
        enablePointerInteraction: false,
        color:
            day.weekday.isEven
                ? const Color.fromARGB(107, 232, 102, 9).withOpacity(0.07)
                : Colors.transparent,
        text: '',
      );
    });
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: const SideMenu(),
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
                    child: Obx(() {
                      final users = controller.allEmployees;

                      return Stack(
                        children: [
                          SfCalendar(
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
                            dataSource: ScheduleDataSource(appointments, users),
                            specialRegions: specialRegions,
                            timeSlotViewSettings: TimeSlotViewSettings(
                              startHour: 8,
                              endHour: 21,
                              timeIntervalHeight: 40,
                              timeIntervalWidth: 14.8,
                              timeInterval: const Duration(hours: 1),
                              timeFormat: 'HH:mm',
                              timeTextStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            todayHighlightColor: AppColors.logo,
                            resourceViewSettings: ResourceViewSettings(
                              visibleResourceCount: 7,
                              size: 100,
                              showAvatar: false,
                              displayNameTextStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            appointmentBuilder: (
                              context,
                              calendarAppointmentDetails,
                            ) {
                              final appointment =
                                  calendarAppointmentDetails.appointments.first;
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
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
                                        appointment.subject.replaceAll(
                                          ' - ',
                                          ' ',
                                        ),
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
                            },
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
                                            icon: const Icon(Icons.arrow_left),
                                            onPressed: () {
                                              calendarController.backward!();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.arrow_right),
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
                    }),
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

class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> appointments, List<UserModel> users) {
    this.appointments = appointments;
    this.resources =
        users
            .map(
              (user) => CalendarResource(
                displayName: '${user.firstName} ${user.lastName}',
                id: user.id,
                color: AppColors.blue,
              ),
            )
            .toList();
  }
}
