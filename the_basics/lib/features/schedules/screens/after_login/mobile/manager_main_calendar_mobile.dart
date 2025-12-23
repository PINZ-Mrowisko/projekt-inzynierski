import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/usecases/show_employee_search_dialog_mobile.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog_mobile.dart';
import 'package:the_basics/features/schedules/usecases/show_tags_filtering_dialog_mobile.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _calendarController.displayDate =
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 8);

    final userController = Get.find<UserController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.resetFilters();
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
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 8);
    });
  }

  void _goToNextRange() {
    setState(() {
      _visibleStartDate = _visibleStartDate.add(Duration(days: _visibleDays));
    _calendarController.displayDate =
        DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day, 8);
    });
  }

  List<Appointment> _getAppointments(List<UserModel> filteredEmployees) {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<Appointment> appointments = [];
    for (final employee in filteredEmployees) {
      for (int day = 0; day < 5; day++) {
        final isMorningShift = day % 2 == 0;
        final startHour = isMorningShift ? 8 : 12;
        final endHour = isMorningShift ? 16 : 20;

        appointments.add(
          Appointment(
            startTime: DateTime(monday.year, monday.month, monday.day + day, startHour, 0),
            endTime: DateTime(monday.year, monday.month, monday.day + day, endHour, 0),
            subject: 'Zmiana ${isMorningShift ? 'poranna' : 'popołudniowa'}',
            color: isMorningShift ? AppColors.logo : AppColors.logolighter,
            resourceIds: <Object>[employee.id],
          ),
        );
      }
    }

    return appointments;
  }

  List<TimeRegion> _getSpecialRegions() {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(30, (index) {
      final day = monday.add(Duration(days: index));
      return TimeRegion(
        startTime: DateTime(day.year, day.month, day.day, 8, 0),
        endTime: DateTime(day.year, day.month, day.day, 20, 0),
        enablePointerInteraction: false,
        color: day.weekday.isEven
            ? AppColors.lightBlue.withOpacity(0.2)
            : AppColors.transparent,
      );
    });
  }

  Widget _buildAppointmentWidget(
    BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails,
  ) {
    final appointment = calendarAppointmentDetails.appointments.first;
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - '
            '${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (appointment.subject.isNotEmpty)
            Text(
              appointment.subject.replaceAll(' - ', ' '),
              style: TextStyle(
                color: AppColors.white,
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCalendar(UserModel employee, List<UserModel> filteredEmployees) {
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
            dataSource: _CalendarDataSource(_getAppointments([employee])),
            specialRegions: _getSpecialRegions(),
            appointmentBuilder: _buildAppointmentWidget,
            allowedViews: const [],
            allowViewNavigation: true,
            viewHeaderHeight: 30,
            todayHighlightColor: AppColors.logo,
            showCurrentTimeIndicator: true,
            timeSlotViewSettings: const TimeSlotViewSettings(
              startHour: 8,
              endHour: 21,
              timeInterval: Duration(hours: 1),
              timeIntervalWidth: 12,
              timeTextStyle: TextStyle(color: AppColors.transparent, fontSize: 0),
              numberOfDaysInView: 3,
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
                        left: 0,
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

                      Positioned(
                        right: 0,
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                Get.toNamed('/grafik-ogolny-kierownik/edytuj-grafik', arguments: {'initialDate': _calendarController.displayDate});
                              },
                              icon: const Icon(Icons.edit_outlined, size: 30),
                              color: AppColors.logo,
                            ),
                            IconButton(
                              onPressed: () {
                                showExportDialogMobile(context);
                              },
                              icon: const Icon(Icons.download_outlined, size: 30),
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
