import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/appointment_builder.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/special_regions_builder.dart';
import 'package:the_basics/features/schedules/usecases/confirm_schedule_publish_dialog.dart';
import 'package:the_basics/features/schedules/usecases/show_confirmations.dart';
import 'package:the_basics/features/schedules/widgets/shift_edit_dialog.dart';
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

  void _handleDragEnd(
      AppointmentDragEndDetails details,
      SchedulesController scheduleController,
      UserController userController,
      ) {
    if (details.appointment == null || details.droppingTime == null) {
      return;
    }

    final Appointment appointment = details.appointment as Appointment;
    final DateTime dropDate = details.droppingTime!;

    // Szukamy ORYGINALNEJ zmiany
    final String appointmentId = appointment.id.toString();
    final originalShift = scheduleController.individualShifts.firstWhereOrNull((s) {
      final idToCheck = '${s.employeeID}_${s.shiftDate.day}_${s.start.hour}:${s.start.minute}_${s.end.hour}:${s.end.minute}';
      return idToCheck == appointmentId;
    });

    if (originalShift == null) {
      return;
    }

    // Sprawdź pracownika docelowego
    final CalendarResource? targetResource = details.targetResource;
    String? newResourceId;
    UserModel? newEmployeeData;

    if (targetResource != null) {
      newResourceId = targetResource.id.toString();
      newEmployeeData = userController.allEmployees.firstWhereOrNull(
            (u) => u.id == newResourceId,
      );
    }

    // Walidacja duplikatów
    final String targetEmployeeId = newResourceId ?? originalShift.employeeID;

    final bool hasCollision = scheduleController.individualShifts.any((shift) {
      if (shift == originalShift) return false;
      if (shift.employeeID != targetEmployeeId) return false;
      return shift.shiftDate.year == dropDate.year &&
          shift.shiftDate.month == dropDate.month &&
          shift.shiftDate.day == dropDate.day;
    });

    if (hasCollision) {
      showCustomSnackbar(context, "Ten pracownik ma już inną zmianę w tym dniu!");

      // --- DODANO: Wymuszenie odświeżenia widoku ---
      // To sprawi, że GetX przebuduje kalendarz używając starych danych,
      // co wizualnie cofnie kafelek na miejsce startowe.
      scheduleController.individualShifts.refresh();
      // ---------------------------------------------

      return;
    }

    // Obliczanie nowego czasu (zachowanie godziny)
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

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Obx(() {
        // Pokaż ładowanie jeśli schedule się ładuje
        if (scheduleController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Row(
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
                            Icon(Icons.info, size: 16, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Wyświetlono ${scheduleController.individualShifts.length} zmian',
                              style: TextStyle(color: Colors.grey),
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
        );
      }),
    );
  }

  // 2. Zaktualizuj widget _buildCalendarBody
  Widget _buildCalendarBody({
    required double intervalWidth,
    required SchedulesController scheduleController,
    required UserController userController,
  }) {
    // ... (początek funkcji bez zmian - obsługa pustej listy)
    if (scheduleController.individualShifts.isEmpty) {
      // ... (kod wyświetlania pustego stanu bez zmian)
      return Center(
        // ...
      );
    }

    // Stwórz appointments z rzeczywistych danych (kod bez zmian)
    final appointments = _getAppointmentsFromSchedule(
      scheduleController.individualShifts,
      userController.filteredEmployees,
    );

    // UWAGA: Usuwamy if (appointments.isEmpty), bo chcemy widzieć puste wiersze pracowników, żeby móc dodać zmianę!

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


      // --- SEKCJA DRAG AND DROP ---
      allowDragAndDrop: true, // 1. Włączamy drag and drop
      dragAndDropSettings: const DragAndDropSettings(
        allowNavigation: true,
        allowScroll: true,
        showTimeIndicator: true,
      ),
      onDragEnd: (details) { // 2. Obsługa upuszczenia
        _handleDragEnd(details, scheduleController, userController);
      },

      // DODANO OBSŁUGĘ KLIKNIĘCIA
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
        appointments,
        userController.filteredEmployees,
        scheduleController,                // <--- Przekazujemy kontroler
        _currentViewDate.value,
      ),
      specialRegions: _regionsBuilder.getSpecialRegions(),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 7,
        endHour: 21,
        timeIntervalHeight: 70,
        timeIntervalWidth: intervalWidth,
        timeInterval: const Duration(hours: 1),
        timeFormat: 'HH:mm',
        timeTextStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      todayHighlightColor: AppColors.logo,
      resourceViewSettings: const ResourceViewSettings(
        visibleResourceCount: 10,
        size: 170,
        showAvatar: false, // Avatar wyłączony, bo zrobimy własny układ w builderze
      ),

      // NOWY BUILDER NAGŁÓWKA PRACOWNIKA
      resourceViewHeaderBuilder: (BuildContext context, ResourceViewHeaderDetails details) {
        // Rozdzielamy nazwę od godzin (zakładamy format "Imię Nazwisko\n(32/40h)")
        final parts = details.resource.displayName.split('\n');
        final name = parts.isNotEmpty ? parts[0] : '';
        final info = parts.length > 1 ? parts[1] : '';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.blue,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Imię i Nazwisko (pogrubione)
              Text(
                name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // 2. Godziny (mniejsze, szare)
              if (info.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  info,
                  style: TextStyle(
                    color: Colors.grey.shade700,
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
    final filteredEmployeeIds = filteredEmployees.map((e) => e.id).toSet();

    final tagsController = Get.find<TagsController>();

    return shifts.where((shift) => filteredEmployeeIds.contains(shift.employeeID)).map((shift) {
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
        color: _getAppointmentColor(shift),
        resourceIds: <Object>[shift.employeeID],
        id: '${shift.employeeID}_${shift.shiftDate.day}_'
            '${shift.start.hour}:${shift.start.minute}_'
            '${shift.end.hour}:${shift.end.minute}',
        notes: displayTags,
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
      // Ustawiamy stan ładowania, aby zablokować UI
      scheduleController.isLoading(true);

      // KROK 1: Zapisz aktualny stan zmian (zmienne lokalne) do Firebase
      // Dzięki temu zaktualizowana lista individualShifts trafi do pola 'generated_schedule' w bazie
      await scheduleController.saveUpdatedScheduleDocument(
        marketId: marketId,
        scheduleId: scheduleId,
        updatedShifts: scheduleController.individualShifts,
      );

      // KROK 2: Dopiero teraz opublikuj grafik
      // Metoda ta zmienia status na published i pobiera świeże dane (które przed chwilą zapisaliśmy w kroku 1)
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

    // 2. DODAWANIE NOWEJ ZMIANY
    else if (details.targetElement == CalendarElement.calendarCell) {
      // ... Twoje zabezpieczenia (widma, index > 7) ...
      if (details.resource != null && details.date != null) {

        // Zabezpieczenie przed widmami
        final clickedResourceId = details.resource!.id.toString();
        final employee = userController.allEmployees.firstWhereOrNull((u) => u.id == clickedResourceId);

        if (employee == null) return; // Jeśli nie znaleziono pracownika

        // Normalizacja daty (jak ustaliliśmy wcześniej)
        final DateTime clickedDate = details.date!;
        final DateTime dayOnly = DateTime(clickedDate.year, clickedDate.month, clickedDate.day);

        // Pobieramy tagi pracownika
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
            employeeTags: currentEmployeeTags, // <--- PRZEKAZUJEMY TAGI
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
      SchedulesController scheduleController, // <--- Dodano
      DateTime currentWeekStart,              // <--- Dodano
      ) {
    this.appointments = appointments;

    // Budujemy zasoby (nagłówki wierszy) z dynamicznym licznikiem godzin
    this.resources = employees.map((employee) {

      // Obliczamy godziny dla tego konkretnego pracownika
      final workedHours = scheduleController.calculateWeeklyHours(
          employee.id,
          currentWeekStart
      );

      // Formatujemy tekst: "Jan Kowalski (32/40h)"
      // Jeśli maxWeeklyHours nie jest ustawione, pokazujemy samo przepracowane
      String hoursText = '${workedHours.toStringAsFixed(1)}h';
      if (employee.maxWeeklyHours != null && employee.maxWeeklyHours! > 0) {
        hoursText = '${workedHours.toStringAsFixed(1)} / ${employee.maxWeeklyHours}h';
      }

      // Kolorowanie na czerwono jeśli przekroczono normę (opcjonalny bajer)
      // final isOvertime = employee.maxWeeklyHours != null && workedHours > employee.maxWeeklyHours!;

      return CalendarResource(
        displayName: '${employee.firstName} ${employee.lastName}\n($hoursText)', // <--- Zmiana wyświetlania
        id: employee.id,
        color: AppColors.blue,
      );
    }).toList();
  }
}