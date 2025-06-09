// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:the_basics/utils/common_widgets/custom_button.dart';
// import '../../../../utils/common_widgets/side_menu.dart';
// import '../../../employees/controllers/user_controller.dart';
// import '../../../../utils/app_colors.dart';
// import 'package:the_basics/features/employees/screens/employee_management.dart';
// import '../../../tags/controllers/tags_controller.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:the_basics/utils/common_widgets/base_dialog.dart';
// import 'package:the_basics/utils/common_widgets/notification_snackbar.dart';

// class MainCalendar extends StatelessWidget {
//   const MainCalendar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<UserController>();
//     final tagsController = Get.find<TagsController>();
//     final selectedTags = <String>[].obs;

//     return Scaffold(
//       backgroundColor: AppColors.pageBackground,
//       body: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
//             child: const SideMenu(),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 80,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Grafik ogólny',
//                           style: TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.logo,
//                           ),
//                         ),
//                         const Spacer(),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10.0),
//                           child: buildTagFilterDropdown(
//                             tagsController,
//                             selectedTags,
//                           ),
//                         ),

//                         const SizedBox(width: 16),
//                         buildSearchBar(),
//                         const SizedBox(width: 16),

//                         CustomButton(
//                           onPressed: () {},
//                           text: "Generuj grafik",
//                           width: 155,
//                           icon: Icons.edit,
//                         ),
//                         const SizedBox(width: 10),

//                         CustomButton(
//                           onPressed: () {
//                             showDialog(
//                               context: context,
//                               builder:
//                                   (context) => BaseDialog(
//                                     width: 551,
//                                     showCloseButton: true,
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         const SizedBox(height: 32),
//                                         Text(
//                                           "Wybierz opcję eksportu grafiku.",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(
//                                             fontSize: 32,
//                                             fontWeight: FontWeight.w400,
//                                             color: AppColors.textColor2,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 48),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             SizedBox(
//                                               width: 160,
//                                               height: 56,
//                                               child: ElevatedButton.icon(
//                                                 onPressed: () {
//                                                   // dodać logikę drukowania
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.print,
//                                                   color: AppColors.textColor2,
//                                                 ),
//                                                 label: const Text(
//                                                   "Drukuj",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                     color: AppColors.textColor2,
//                                                   ),
//                                                 ),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       AppColors.lightBlue,
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           100,
//                                                         ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(width: 32),
//                                             SizedBox(
//                                               width: 160,
//                                               height: 56,
//                                               child: ElevatedButton.icon(
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop();
//                                                   // dodać logikę zapisu do PDF
//                                                   showCustomSnackbar(context, "Grafik został pomyślnie zapisany.");
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.download,
//                                                   color: AppColors.textColor2,
//                                                 ),
//                                                 label: const Text(
//                                                   "Zapisz jako PDF",
//                                                   style: TextStyle(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                     color: AppColors.textColor2,
//                                                   ),
//                                                 ),
//                                                 style: ElevatedButton.styleFrom(
//                                                   backgroundColor:
//                                                       AppColors.lightBlue,
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           100,
//                                                         ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 32),
//                                       ],
//                                     ),
//                                   ),
//                             );
//                           },
//                           text: "Eksportuj",
//                           width: 125,
//                           icon: Icons.download,
//                         ),
//                       ],
//                     ),
//                   ),

//                   Expanded(
//                     child: SfCalendar(
//                       view: CalendarView.timelineWeek,
//                       firstDayOfWeek: 1,
//                       timeSlotViewSettings: TimeSlotViewSettings(
//                         startHour: 8, // początek dnia 
//                         endHour: 15, // koniec dnia 
//                         //timeIntervalHeight: 60,
//                       ),
//                       todayHighlightColor: AppColors.logo,
//                     ),
                    
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





















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

class MainCalendar extends StatelessWidget {
  const MainCalendar({super.key});

  // Przykładowe dane pracowników
  List<Employee> getSampleEmployees() {
    return [
      Employee(id: '1', name: 'Agata Zaparucha', isActive: true),
      Employee(id: '2', name: 'Julia Osińska', isActive: false),
      Employee(id: '3', name: 'Robert Piłat', isActive: true),
      Employee(id: '4', name: 'Zofia L', isActive: false),
    ];
  }

  // Opcjonalna funkcja - możesz usunąć jeśli nie chcesz wizualnie wyróżniać przerw
  List<TimeRegion> getSpecialTimeRegions() {
    // Zwracamy pustą listę, jeśli nie chcemy specjalnych regionów
    return [];
  }

  // Zmodyfikowane dane harmonogramu - więcej realistycznych zmian
  List<Appointment> getSampleAppointments() {
    final DateTime now = DateTime.now();
    final DateTime monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    
    print('Debug - Current date: $now');
    print('Debug - Monday of this week: $monday');
    
    final appointments = [
      // Agata - poniedziałek 8-16 (cały dzień)
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day, 8, 0),
        endTime: DateTime(monday.year, monday.month, monday.day, 16, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['1'],
      ),
      
      // Julia - wtorek 8-16 i czwartek 8-16
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 1, 8, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 1, 16, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['2'],
      ),
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 3, 8, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 3, 16, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['2'],
      ),
      
      // Robert - środa 12-20 i sobota 12-20
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 2, 12, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 2, 20, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['3'],
      ),
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 5, 12, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 5, 20, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['3'],
      ),
      
      // Zofia - czwartek 8-16 i piątek 8-16
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 3, 8, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 3, 16, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['4'],
      ),
      Appointment(
        startTime: DateTime(monday.year, monday.month, monday.day + 4, 8, 0),
        endTime: DateTime(monday.year, monday.month, monday.day + 4, 16, 0),
        subject: 'Zaplanowana zmiana',
        color: Colors.blue.shade600,
        resourceIds: <Object>['4'],
      ),
    ];
    
    // Debug print dla każdego appointment
    for (int i = 0; i < appointments.length; i++) {
      print('Debug - Appointment $i: ${appointments[i].startTime} - ${appointments[i].endTime}, Resource: ${appointments[i].resourceIds}');
    }
    
    return appointments;
  }

  Widget buildTagFilterDropdown(TagsController tagsController, RxList<String> selectedTags) {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('Filtruj po tagach'),
          ),
          items: [],
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Wyszukaj pracownika',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    final tagsController = Get.find<TagsController>();
    final selectedTags = <String>[].obs;

    final employees = getSampleEmployees();
    final appointments = getSampleAppointments();
    final specialRegions = getSpecialTimeRegions();

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
                          'Grafik ogólny (8-10, 12-14)',
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
                            showDialog(
                              context: context,
                              builder: (context) => BaseDialog(
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
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                              // dodać logikę zapisu do PDF
                                              showCustomSnackbar(context, "Grafik został pomyślnie zapisany.");
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
                                              backgroundColor: AppColors.lightBlue,
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
                    child: SfCalendar(
                      view: CalendarView.timelineWeek,
                      firstDayOfWeek: 1,
                      dataSource: ScheduleDataSource(appointments, employees),
                      // Zakres godzin obejmuje oba interwały
                      timeSlotViewSettings: TimeSlotViewSettings(
                        startHour: 8,
                        endHour: 21, // Zwiększony do 21, żeby pokryć cały dzień roboczy
                        timeIntervalHeight: 40, // Zmniejszona wysokość dla kompaktowego widoku
                        timeInterval: Duration(hours: 2), // Interwały co godzinę
                        timeFormat: 'HH:mm',
                        timeTextStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // Usuń tę linię jeśli nie chcesz specjalnych regionów
                      // specialRegions: specialRegions,
                      todayHighlightColor: AppColors.logo,
                      resourceViewSettings: ResourceViewSettings(
                        visibleResourceCount: employees.length,
                        size: 120, // Zmniejszona szerokość kolumny z nazwiskami
                        displayNameTextStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      appointmentBuilder: (context, calendarAppointmentDetails) {
                        final appointment = calendarAppointmentDetails.appointments.first;
                        
                        // Różne kolory dla różnych zmian
                        Color backgroundColor;
                        if (appointment.subject.contains('Zmiana I')) {
                          backgroundColor = appointment.color;
                        } else {
                          backgroundColor = appointment.color.withOpacity(0.8);
                        }
                        
                        return Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.5,
                            ),
                          ),
                          margin: EdgeInsets.all(1),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  appointment.subject.replaceAll(' - ', ' '),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Klasa Employee (bez zmian)
class Employee {
  final String id;
  final String name;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.isActive,
  });
}

// Klasa ScheduleDataSource (bez zmian)
class ScheduleDataSource extends CalendarDataSource {
  ScheduleDataSource(List<Appointment> appointments, List<Employee> employees) {
    this.appointments = appointments;
    this.resources = employees.map((employee) => CalendarResource(
      displayName: employee.name,
      id: employee.id,
      color: employee.isActive ? Colors.blue : Colors.grey,
    )).toList();
    
    // Debug print
    print('Debug - ScheduleDataSource created with ${appointments.length} appointments and ${employees.length} resources');
    print('Debug - Resources: ${this.resources!.map((r) => '${r.id}: ${r.displayName}').toList()}');
  }
}