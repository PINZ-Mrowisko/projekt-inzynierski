import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_converter_for_edit.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
import 'package:the_basics/features/schedules/usecases/confirm_schedule_publish_dialog.dart';
import 'package:the_basics/features/schedules/usecases/show_confirmations.dart';
import 'package:the_basics/features/schedules/usecases/shift_edit_dialog.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/utils/common_widgets/multi_select_dropdown.dart';
import 'package:the_basics/utils/common_widgets/search_bar.dart';
import '../../../../../../utils/common_widgets/side_menu.dart';
import '../../../../../auth/models/user_model.dart';
import '../../../../../employees/controllers/user_controller.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../tags/controllers/tags_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';

class MainCalendarEdit extends StatefulWidget {
  const MainCalendarEdit({super.key});

  @override
  State<MainCalendarEdit> createState() => _MainCalendarEditState();
}

class _MainCalendarEditState extends State<MainCalendarEdit> {
  late DateTime initialDate;
  late String scheduleId;
  late String marketId;
  late Rx<DateTime> _currentViewDate;
  final CalendarController _calendarController = CalendarController();
  final RxList<String> _selectedTags = <String>[].obs;

  final SpecialRegionsBuilderForEdit _regionsBuilder = SpecialRegionsBuilderForEdit();

  bool _isEmployeeOnLeave(String employeeId, DateTime date) {
    if (employeeId == 'Unknown') return false; // Nie sprawdzamy urlopów dla Unknown

    final leaveController = Get.find<LeaveController>();

    return leaveController.allLeaveRequests.any((leave) {
      if (leave.userId != employeeId) return false;

      final checkDate = DateTime(date.year, date.month, date.day);
      final start = DateTime(leave.startDate.year, leave.startDate.month, leave.startDate.day);
      final end = DateTime(leave.endDate.year, leave.endDate.month, leave.endDate.day);

      return (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
          (checkDate.isAtSameMomentAs(end) || checkDate.isBefore(end));
    });
  }

  void _handleDragEnd(
      AppointmentDragEndDetails details,
      SchedulesController scheduleController,
      UserController userController,
      ) {
    if (details.appointment == null || details.droppingTime == null) {
      return;
    }

    final Appointment appointment = details.appointment as Appointment;
    final String appointmentId = appointment.id.toString();

    if (appointmentId.startsWith('leave_')) {
      scheduleController.individualShifts.refresh();
      return;
    }

    final originalShift = scheduleController.individualShifts.firstWhereOrNull((s) {
      final idToCheck = '${s.employeeID}_${s.shiftDate.day}_${s.start.hour}:${s.start.minute}_${s.end.hour}:${s.end.minute}';
      return idToCheck == appointmentId;
    });

    if (originalShift == null) {
      scheduleController.individualShifts.refresh();
      return;
    }

    final CalendarResource? targetResource = details.targetResource;
    String? newResourceId;
    UserModel? newEmployeeData;

    if (targetResource != null) {
      newResourceId = targetResource.id.toString();

      if (newResourceId == 'Unknown') {
      } else {
        newEmployeeData = userController.allEmployees.firstWhereOrNull(
              (u) => u.id == newResourceId,
        );
      }
    }

    final DateTime dropDate = details.droppingTime!;

    final String targetEmployeeId = newResourceId ?? originalShift.employeeID;

    if (_isEmployeeOnLeave(targetEmployeeId, dropDate)) {
      scheduleController.individualShifts.refresh();
      return;
    }

    if (targetEmployeeId != 'Unknown') {
      final bool hasCollision = scheduleController.individualShifts.any((shift) {
        if (shift == originalShift) return false;
        if (shift.employeeID != targetEmployeeId) return false;
        return shift.shiftDate.year == dropDate.year &&
            shift.shiftDate.month == dropDate.month &&
            shift.shiftDate.day == dropDate.day;
      });

      if (hasCollision) {
        showCustomSnackbar(context, "Ten pracownik ma już inną zmianę w tym dniu!");
        scheduleController.individualShifts.refresh();
        return;
      }
    }

    final TimeOfDay originalTime = originalShift.start;
    final DateTime newStartTime = DateTime(
      dropDate.year,
      dropDate.month,
      dropDate.day,
      originalTime.hour,
      originalTime.minute,
    );

    scheduleController.handleDragAndDropUpdate(
      appointmentId: appointmentId,
      newStartTime: newStartTime,
      newResourceId: newResourceId,
      newEmployeeData: newEmployeeData,
    );
  }

  final RxInt _unknownShiftsCount = 0.obs;

  void _updateUnknownShiftsCount() {
    final scheduleController = Get.find<SchedulesController>();

    final count = scheduleController.individualShifts
        .where((shift) => shift.employeeID == 'Unknown')
        .length;

    _unknownShiftsCount.value = count;
  }

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};
    scheduleId = args['scheduleId'] ?? '';
    marketId = args['marketId'] ?? '';
    initialDate = args['initialDate'] ?? DateTime.now();

    _currentViewDate = initialDate.obs;

    final userController = Get.find<UserController>();
    final scheduleController = Get.find<SchedulesController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userController.resetFilters();

      if (scheduleController.individualShifts.isEmpty && scheduleId.isNotEmpty && marketId.isNotEmpty) {
        await scheduleController.fetchAndParseGeneratedSchedule(
          marketId: marketId,
          scheduleId: scheduleId,
        );
      } else {
        scheduleController.createLocalSnapshot();
      }
    });

    ever(_selectedTags, (tags) {
      userController.filterEmployees(tags);
    });

    Get.find<SchedulesController>();
    ever(scheduleController.individualShifts, (_) {
      _updateUnknownShiftsCount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnknownShiftsCount();
    });
  }

  /// Pomocnicza metoda do polskiej odmiany
String _getPolishWordForm(int count) {
  if (count == 1) return 'zmiana';
  if (count >= 2 && count <= 4) return 'zmiany';
  return 'zmian';
}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final totalHours = 14;
    final visibleDays = 8.5;

    final dynamicIntervalWidth = screenWidth / (totalHours * visibleDays);

    final userController = Get.find<UserController>();
    final scheduleController = Get.find<SchedulesController>();
    final tagsController = Get.find<TagsController>();

    return Obx(() {
      if (scheduleController.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                child: SideMenu(
                  onNavigation: (route) {
                    showLeaveConfirmationDialog(() {
                      final controller = Get.find<SchedulesController>();
                      controller.discardLocalChanges();
                      Get.toNamed(route);
                    });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      SizedBox(
                        height: 80,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, size: 28, color: AppColors.logo),
                              onPressed: () {
                                showLeaveConfirmationDialog(() {
                                  final controller = Get.find<SchedulesController>();
                                  controller.discardLocalChanges();
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Edycja grafiku',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.logo,
                                    ),
                                  ),

                                ],
                              ),
                            ),
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
                                      onPressed: () => showPublishConfirmationDialog(_handlePublishSchedule),
                                      text: "Opublikuj grafik",
                                      width: 155,
                                      icon: Icons.publish,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // GLOBAL WARNING PANEL
                      Obx(() {
                        if (_unknownShiftsCount.value > 0) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              border: Border.all(color: AppColors.warning, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning, color: AppColors.warning, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'UWAGA: ${_unknownShiftsCount.value} ${_getPolishWordForm(_unknownShiftsCount.value)} bez obsady!',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),
                      // INFO PANEL
                      if (scheduleController.individualShifts.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.info, size: 16, color: AppColors.logo),
                              SizedBox(width: 8),
                              Text(
                                'Wyświetlono ${scheduleController.individualShifts.length} zmian',
                                style: TextStyle(color: AppColors.textColor2),
                              ),
                              Spacer(),
                              Text(
                                'Załadowany grafik',
                                style: TextStyle(
                                  color: AppColors.logo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // CALENDAR
                      Expanded(
                        child: _buildCalendarBody(
                          intervalWidth: dynamicIntervalWidth,
                          scheduleController: scheduleController,
                          userController: userController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    });
  }

  Widget _buildCalendarBody({
    required double intervalWidth,
    required SchedulesController scheduleController,
    required UserController userController,
  }) {
    if (scheduleController.individualShifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Brak załadowanego grafiku'),
            SizedBox(height: 8),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await scheduleController.fetchAndParseGeneratedSchedule(
                  marketId: marketId,
                  scheduleId: scheduleId,
                );
              },
              child: Text('Załaduj ponownie'),
            ),
          ],
        ),
      );
    }

    final unknownUser = UserModel.empty().copyWith(
      id: 'Unknown',
      firstName: '⚠️ Brak obsady',
      lastName: '⚠️',
      marketId: marketId,
    );

    final List<UserModel> displayEmployees = [
      unknownUser,
      ...userController.filteredEmployees
    ];

    final leaveController = Get.find<LeaveController>();
    final appointmentConverterForEdit = AppointmentConverterForEdit();

    final allAppointments= appointmentConverterForEdit.getAppointments(
      userController.filteredEmployees,
      leaves: leaveController.allLeaveRequests.where((l) =>
        l.status.toLowerCase() == 'zaakceptowany' ||
        l.status.toLowerCase() == 'mój urlop'
      ).toList(),
    );

    return SfCalendar(
      controller: _calendarController,
      view: CalendarView.timelineWeek,
      showDatePickerButton: false,
      showNavigationArrow: true,

      onViewChanged: (ViewChangedDetails details) {
        if (details.visibleDates.isNotEmpty) {
          // Pobieramy pierwszy widoczny dzień (zazwyczaj poniedziałek w widoku tygodniowym)
          // scheduler w microtask, aby uniknąć błędu "setState during build"
          Future.microtask(() {
            _currentViewDate.value = details.visibleDates.first;
          });
        }
      },


      allowDragAndDrop: true, // 1. Włączamy drag and drop
      dragAndDropSettings: const DragAndDropSettings(
        allowNavigation: true,
        allowScroll: true,
        showTimeIndicator: true,
      ),
      onDragEnd: (details) {
        _handleDragEnd(details, scheduleController, userController);
      },

      onTap: _handleCalendarTap,

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
        allAppointments,
        displayEmployees,
        scheduleController,
        _currentViewDate.value,
      ),
      specialRegions: _regionsBuilder.getSpecialRegions(),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 7,
        endHour: 21,
        timeIntervalHeight: 40,
        timeIntervalWidth: intervalWidth,
        timeInterval: const Duration(hours: 1),
        timeFormat: 'HH:mm',
        timeTextStyle: TextStyle(
          fontSize: 12,
          color: AppColors.textColor2,
        ),
        minimumAppointmentDuration: const Duration(hours: 5, minutes: 15),
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

      resourceViewHeaderBuilder: (BuildContext context, ResourceViewHeaderDetails details) {
        // Rozdzielamy nazwę od godzin (zakładamy format "Imię Nazwisko\n(32/40h)")
        final parts = details.resource.displayName.split('\n');
        final name = parts.isNotEmpty ? parts[0] : '';
        final info = parts.length > 1 ? parts[1] : '';

        Color infoColor = AppColors.textColor2;

        final resourceId = details.resource.id.toString();

        final bool isUnknown = resourceId == 'Unknown';
        final Color backgroundColor = isUnknown ? AppColors.warning : AppColors.blue;

        if (!isUnknown) {
          final employee = userController.allEmployees.firstWhereOrNull((u) => u.id == resourceId);

          if (employee != null) {
            final workedHours = scheduleController.calculateWeeklyHours(
                resourceId,
                _currentViewDate.value
            );

            if (employee.maxWeeklyHours != null &&
                employee.maxWeeklyHours! > 0 &&
                workedHours > employee.maxWeeklyHours!) {
              infoColor = AppColors.warning;
            }
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(
              right: BorderSide(color: AppColors.white, width: 1),
              bottom: BorderSide(color: AppColors.white, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (info.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  info,
                  style: TextStyle(
                    color: infoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },

      appointmentBuilder: buildAppointmentWidget,
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

  Future<void> _handlePublishSchedule() async {
    final scheduleController = Get.find<SchedulesController>();

    try {
      scheduleController.isLoading(true);

      await scheduleController.saveUpdatedScheduleDocument(
        marketId: marketId,
        scheduleId: scheduleId,
        updatedShifts: scheduleController.individualShifts,
      );

      await scheduleController.publishSchedule(
          marketId: marketId,
          scheduleId: scheduleId
      );

      if (mounted) {
        showCustomSnackbar(
          context,
          'Grafik został zapisany i opublikowany!',
        );
      }

      final routeName = '/grafik-ogolny-kierownik';

      Get.offAllNamed(
        routeName,
        arguments: {},
      );
    } finally {
      scheduleController.isLoading(false);
    }
  }

  void _handleCalendarTap(CalendarTapDetails details) {
    final scheduleController = Get.find<SchedulesController>();
    final userController = Get.find<UserController>(); // Potrzebujemy dostępu do listy pracowników

    // 1. EDYCJA ISTNIEJĄCEJ ZMIANY
    if (details.targetElement == CalendarElement.appointment) {
      final Appointment appointment = details.appointments!.first;

      if (appointment.id.toString().startsWith('leave_')) {
        return;
      }

      try {
        final shiftToEdit = scheduleController.individualShifts.firstWhere((s) {
          final apptId = '${s.employeeID}_${s.shiftDate.day}_${s.start.hour}:${s.start.minute}_${s.end.hour}:${s.end.minute}';
          return apptId == appointment.id;
        });

        // Pobierz aktualne tagi pracownika z UserController
        final employee = userController.allEmployees.firstWhereOrNull((u) => u.id == shiftToEdit.employeeID);
        final List<String> currentEmployeeTags = employee?.tags ?? []; // Zakładam, że user.tags to List<String> (nazwy tagów)

        showDialog(
          context: context,
          builder: (context) => ShiftEditDialog(
            shift: shiftToEdit,
            selectedDate: shiftToEdit.shiftDate,
            employeeId: shiftToEdit.employeeID,
            firstName: shiftToEdit.employeeFirstName,
            lastName: shiftToEdit.employeeLastName,
            employeeTags: currentEmployeeTags, // <--- PRZEKAZUJEMY TAGI
            onSave: (updatedShift) {
              scheduleController.updateLocalShift(shiftToEdit, updatedShift);
            },
            onDelete: (shiftToDelete) {
              scheduleController.deleteLocalShift(shiftToDelete);
            },
          ),
        );
      } catch (e) {
        print("Błąd dopasowania zmiany: $e");
      }
    }

    else if (details.targetElement == CalendarElement.calendarCell) {
      if (details.resource != null && details.date != null) {

        final clickedResourceId = details.resource!.id.toString();
        final employee = userController.allEmployees.firstWhereOrNull((u) => u.id == clickedResourceId);

        if (employee == null) return;

        final DateTime clickedDate = details.date!;
        final DateTime dayOnly = DateTime(clickedDate.year, clickedDate.month, clickedDate.day);

        final List<String> currentEmployeeTags = employee.tags;

        _calendarController.selectedDate = null;

        showDialog(
          context: context,
          builder: (context) => ShiftEditDialog(
            shift: null,
            selectedDate: dayOnly,
            employeeId: employee.id,
            firstName: employee.firstName,
            lastName: employee.lastName,
            employeeTags: currentEmployeeTags,
            onSave: (newShift) {
              scheduleController.addLocalShift(newShift);
            },
          ),
        );
      }
    }
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(
      List<Appointment> appointments,
      List<UserModel> employees,
      SchedulesController scheduleController,
      DateTime currentWeekStart,
      ) {

    this.appointments = appointments;

    this.resources = employees.map((employee) {
      final workedHours = scheduleController.calculateWeeklyHours(
          employee.id,
          currentWeekStart
      );

      String hoursText = '${workedHours.toStringAsFixed(1)}h';
      if (employee.maxWeeklyHours != null && employee.maxWeeklyHours! > 0) {
        hoursText = '${workedHours.toStringAsFixed(1)} / ${employee.maxWeeklyHours}h';
      }

      return CalendarResource(
        displayName: '${employee.firstName} ${employee.lastName}\n($hoursText)',
        id: employee.id,
        color: AppColors.blue,
      );
    }).toList();
  }

}