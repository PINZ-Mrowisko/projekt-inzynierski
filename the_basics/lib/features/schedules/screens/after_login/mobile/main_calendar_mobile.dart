import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/base_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/mobile_bottom_menu.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';

class MainCalendarMobile extends StatefulWidget {
  const MainCalendarMobile({super.key});

  @override
  State<MainCalendarMobile> createState() => _MainCalendarMobileState();
}

class _MainCalendarMobileState extends State<MainCalendarMobile> {
  final RxInt _currentMenuIndex = 0.obs;
  final RxList<String> _selectedTags = <String>[].obs;
  DateTime? _lastBackPressTime;

  DateTime _visibleStartDate = DateTime.now();
  final int _visibleDays = 3;

  @override
  void initState() {
    super.initState();
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
    });
  }

  void _goToNextRange() {
    setState(() {
      _visibleStartDate = _visibleStartDate.add(Duration(days: _visibleDays));
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
    final CalendarController controller = CalendarController()
      ..view = CalendarView.timelineDay
      ..displayDate = DateTime(_visibleStartDate.year, _visibleStartDate.month, _visibleStartDate.day);

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
            controller: controller,
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
      child: Scaffold(
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
                                _showTagsFilterDialog(context);
                              },
                              icon: const Icon(Icons.filter_alt_outlined, size: 30),
                              color: AppColors.logo,
                            ),
                            IconButton(
                              onPressed: () {
                                _showEmployeeSearchDialog(context);
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
                                // TODO: przejście do trybu edycji
                              },
                              icon: const Icon(Icons.edit_outlined, size: 30),
                              color: AppColors.logo,
                            ),
                            IconButton(
                              onPressed: () {
                                _showExportDialog(context);
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
            return const Center(child: CircularProgressIndicator());
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
    );
  }

  void _showExportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: BaseDialog(
        width: 551,
        showCloseButton: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Text(
              "Wybierz opcję eksportu grafiku.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w400,
                color: AppColors.textColor2,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.print, color: AppColors.textColor2),
                    label: Text(
                      "Drukuj",
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
                ),
                const SizedBox(width: 32),
                SizedBox(
                  width: 160,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showCustomSnackbar(
                        context,
                        "Grafik został pomyślnie zapisany.",
                      );
                    },
                    icon: Icon(Icons.download, color: AppColors.textColor2),
                    label: Text(
                      "Zapisz jako PDF",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textColor2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
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
    ),
  );
}

// dedicated pop up for mobile tag filtering 
void _showTagsFilterDialog(BuildContext context) {
  final tagsController = Get.find<TagsController>();
  final userController = Get.find<UserController>();

  final List<String> tempSelectedTags = List.from(_selectedTags);

  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = MediaQuery.of(context).size.height * 0.5;

          return BaseDialog(
            width: 551,
            showCloseButton: true,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 28),
                      Text(
                        "Filtruj po tagach",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor2,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: tagsController.allTags.map((tag) {
                              final tagName = tag.tagName;
                              final selected = tempSelectedTags.contains(tagName);
                              return CheckboxListTile(
                                value: selected,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      tempSelectedTags.add(tagName);
                                    } else {
                                      tempSelectedTags.remove(tagName);
                                    }
                                  });
                                },
                                title: Text(
                                  tagName,
                                  style: TextStyle(
                                    color: AppColors.textColor2,
                                    fontSize: 16,
                                  ),
                                ),
                                activeColor: AppColors.logo,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  tempSelectedTags.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                "Wyczyść",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SizedBox(
                            width: 140,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                _selectedTags.assignAll(tempSelectedTags);
                                userController.filterEmployees(_selectedTags);
                                Navigator.of(context).pop();
                                showCustomSnackbar(
                                  context,
                                  "Filtry zostały zastosowane.",
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: Text(
                                "Zastosuj",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

// dedicated pop up for mobile employee search
void _showEmployeeSearchDialog(BuildContext context) {
  final userController = Get.find<UserController>();
  final TextEditingController searchController =
      TextEditingController(text: userController.searchQuery.value);

  showDialog(
    context: context,
    builder: (context) => Transform.scale(
      scale: 0.85,
      child: BaseDialog(
        width: 500,
        showCloseButton: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Wyszukaj pracownika",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColor2,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomSearchBar(
                    hintText: 'Wpisz imię lub nazwisko',
                    widthPercentage: 1.0,
                    maxWidth: 400,
                    minWidth: 200,
                    onChanged: (query) {
                      userController.searchQuery.value = query;
                      userController.filterEmployees(_selectedTags);
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          searchController.clear();
                        });
                        userController.searchQuery.value = '';
                        userController.filterEmployees(_selectedTags);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        "Wyczyść",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor2,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

}
  
class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> appointments) {
    this.appointments = appointments;
  }
}
