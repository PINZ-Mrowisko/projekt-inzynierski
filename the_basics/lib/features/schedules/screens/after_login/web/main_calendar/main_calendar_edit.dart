import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
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
import '../../../../models/schedule_model.dart';

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
        // ...
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

    final shiftAppointments = _getAppointmentsFromSchedule(
      scheduleController.individualShifts,
      displayEmployees,
    );

    final leaveController = Get.find<LeaveController>();

    final leaveAppointments = _getAppointmentsFromLeaves(
      leaveController.allLeaveRequests,
      userController.filteredEmployees
    );

    final allAppointments = [...shiftAppointments, ...leaveAppointments];

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
      ),
      todayHighlightColor: AppColors.logo,
      resourceViewSettings: const ResourceViewSettings(
        visibleResourceCount: 5,
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

  /// Konwertuj ScheduleModel na Appointment
  List<Appointment> _getAppointmentsFromSchedule(
      List<ScheduleModel> shifts,
      List<UserModel> filteredEmployees,
      ) {
    final employeeMap = {for (var e in filteredEmployees) e.id: e};
    final tagsController = Get.find<TagsController>();

    return shifts.where((shift) => employeeMap.containsKey(shift.employeeID)).map((shift) {

      final employee = employeeMap[shift.employeeID]!;

      // KROK 1: Najpierw pobieramy NAZWY tagów dla tej zmiany
      // (Przesuwamy to wyżej, żeby użyć tego do porównania)
      final tagNames = _convertTagIdsToNames(shift.tags, tagsController);

      // KROK 2: LOGIKA OSTRZEGANIA
      bool hasMissingTags = false;

      if (shift.employeeID != 'Unknown' && shift.tags.isNotEmpty) {
        final employeeTagNames = employee.tags.toSet();

        hasMissingTags = tagNames.any((tagName) => !employeeTagNames.contains(tagName));
      }

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

      final displayTags = tagNames.isNotEmpty
          ? tagNames.join(', ')
          : 'Brak tagów';

      String displaySubject = displayTags;
      if (hasMissingTags) {
        displaySubject = '⚠️ $displayTags';
      }

      return Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: displayTags,
        color: _getAppointmentColor(shift),
        resourceIds: <Object>[shift.employeeID],
        id: '${shift.employeeID}_${shift.shiftDate.day}_'
            '${shift.start.hour}:${shift.start.minute}_'
            '${shift.end.hour}:${shift.end.minute}',
        notes: displaySubject,
      );
    }).toList();
  }

  List<Appointment> _getAppointmentsFromLeaves(
      List<LeaveModel> leaves,
      List<UserModel> filteredEmployees,
      ) {
    final filteredEmployeeIds = filteredEmployees.map((e) => e.id).toSet();

    return leaves.where((leave) => filteredEmployeeIds.contains(leave.userId)).map((leave) {

      return Appointment(
        startTime: leave.startDate,
        endTime: leave.endDate,
        subject: 'Urlop',
        color: Colors.grey.shade400,
        resourceIds: <Object>[leave.userId],
        id: 'leave_${leave.id}',
        notes:'Urlop',
        isAllDay: true,
      );
    }).toList();
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

  List<String> _convertTagIdsToNames(List<String> tagIds, TagsController tagsController) {
    final List<String> tagNames = [];

    for (final tagId in tagIds) {
      final tag = tagsController.allTags.firstWhere(
        (t) => t.id == tagId,
      );

      if (tag != null && tag.tagName != null && tag.tagName!.isNotEmpty) {
        tagNames.add(tag.tagName!);
      } else {
        tagNames.add(tagId);
      }
    }

    return tagNames;
  }

Color _getAppointmentColor(ScheduleModel shift) {
    if (shift.employeeID == 'Unknown') {
      return AppColors.warning;
    }
    if (shift.start.hour >= 12) {
      return AppColors.logolighter;
    } else {
      return AppColors.logo;
    }
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
        displayName: '${employee.firstName} ${employee.lastName}\n($hoursText)', // <--- Zmiana wyświetlania
        id: employee.id,
        color: AppColors.blue,
      );
    }).toList();
  }
}