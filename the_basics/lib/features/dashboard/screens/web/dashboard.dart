import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/important_tile.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/leaves_tile.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/shift_tile.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../employees/controllers/user_controller.dart';
import '../../../../utils/common_widgets/side_menu.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  final UserController userController = Get.find<UserController>();
  final LeaveController leaveController = Get.find<LeaveController>();
  final SchedulesController schedulesController =Get.find<SchedulesController>();

  final isLoading = true.obs;
  final readyToShow = false.obs;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      readyToShow.value = false;
      
      try {
        await userController.fetchAllEmployees();
        await leaveController.fetchLeaves();
        await schedulesController.initialize();

        await Future.delayed(const Duration(milliseconds: 50));
        
        readyToShow.value = true;
      } finally {
        isLoading.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = userController.employee.value;

      if (user == null) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.logo)),
        );
      }

      if (isLoading.value || !readyToShow.value) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                child: SideMenu(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 80,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Dashboard",
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
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.logo),
                            ],
                          ),
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

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
              child: SideMenu(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Dashboard",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: 300,
                                maxHeight: double.infinity,
                              ),
                              child: shiftTile(userController, schedulesController, tagsController),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: 300,
                                maxHeight: double.infinity,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: leavesTile(leaveController),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: importantTile(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  // TILE WITH CURRENT SHIFT
  Widget _shiftTile(UserController userController, SchedulesController schedulesController) {
    final now = DateTime.now();
    // use this to pass custom date to the datetime widget during testing
    //final now = DateTime(2026, 1, 6, 10, 0);
    final currentShifts = schedulesController.individualShifts
        .where((shift) => isShiftNow(shift, now))
        .toList()
      ..sort((a, b) =>
          a.employeeFirstName.compareTo(b.employeeFirstName));

    
    return _baseTile(
      title: "Aktualna zmiana",
      child: currentShifts.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDateTimeWidget(),
              const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Text("Brak aktywnej zmiany",
                    style: TextStyle(color: AppColors.textColor2),
                    ),
                  ),
                ),
            ],
          )
        : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateTimeWidget(),
                const SizedBox(height: 16),
                Expanded(
                  child: GenericList<ScheduleModel>(
                    items: currentShifts,
                    itemBuilder: (context, shift) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          '${shift.employeeFirstName} ${shift.employeeLastName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor1,
                          ),
                        ),
                        // we show tags assigned by the algorithm (so as which tag (role) is the employee working current shift)
                        subtitle: _buildEmployeeTags(_convertTagIdsToNames(shift.tags, tagsController)),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // for testing purposes - add an option to pass custom time to the widget
  Widget _buildDateTimeWidget([DateTime? customNow]) {
    return StreamBuilder<DateTime>(
      stream: customNow == null 
        ? Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now())
        : Stream.value(customNow),
      builder: (context, snapshot) {
        final now = snapshot.data ?? (customNow ?? DateTime.now());
        final formattedDate = DateFormat('dd.MM.yyyy').format(now);
        final formattedTime = DateFormat('HH:mm:ss').format(now);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 20, color: AppColors.logolighter),
              const SizedBox(width: 8),
              Text(
                "$formattedDate, $formattedTime",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool isShiftNow(ScheduleModel shift, DateTime now) {
    if (shift.shiftDate.year != now.year ||
        shift.shiftDate.month != now.month ||
        shift.shiftDate.day != now.day) {
      return false;
    }

    final startMinutes = shift.start.hour * 60 + shift.start.minute;
    final endMinutes = shift.end.hour * 60 + shift.end.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
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

  // TILE WITH LEAVES TO APPROVE
  Widget _leavesTile(LeaveController leaveController) {
    final pending = leaveController.allLeaveRequests
        .where((l) => l.status.toLowerCase() == 'oczekujący')
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return _baseTile(
      title: "Wnioski urlopowe do rozpatrzenia",
      child: pending.isEmpty
          ? Center(
              child: Text(
                "Brak wniosków oczekujących",
                style: TextStyle(color: AppColors.textColor2),
              ),
            )
          : GenericList<LeaveModel>(
                items: pending,
                onItemTap: (leave) => Get.offNamed('/wnioski-urlopowe-kierownik'),
                itemBuilder: (context, item) {
                  final formattedDate = item.startDate == item.endDate
                      ? DateFormat('dd.MM.yyyy').format(item.startDate)
                      : '${DateFormat('dd.MM.yyyy').format(item.startDate)} - ${DateFormat('dd.MM.yyyy').format(item.endDate)}';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(
                      (item.comment == "Brak komentarza" || item.comment == '')
                          ? item.name
                          : '${item.name} - ${item.comment}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor1,
                      ),
                    ),
                    subtitle: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor2,
                      ),
                    ),
                    trailing: _buildStatusChip(item.status),
                  );
                },
              ),
            
    );
  }

  // TILE WITH SCHEDULE WARNINGS
  Widget _importantTile() {
    // hardcoded warnings for demonstration purposes, to implement proper warnings pull when schedules are available
    final warnings = [
      {
        'title': 'Brakujące pokrycie',
        'description': 'Zmiana poranna bez przypisanego pracownika',
        'icon': Icons.warning,
        'color': AppColors.warning,
        'date': '15.12.2024',
      },
      {
        'title': 'Brakujące pokrycie',
        'description': 'Zmiana nocna bez przypisanego pracownika',
        'icon': Icons.warning,
        'color': AppColors.warning,
        'date': '20.12.2024',
      },
      {
        'title': 'Brakujące pokrycie',
        'description': 'Zmiana popołudniowa bez przypisanego pracownika',
        'icon': Icons.warning,
        'color': AppColors.warning,
        'date': 'Dzisiaj',
      },
    ];

    return _baseTile(
      title: "Ważne",
      child: warnings.isEmpty
          ? Center(
                child: Text("Brak ostrzeżeń",
                style: TextStyle(color: AppColors.textColor2),
                ),
              )
          : GenericList<Map<String, dynamic>>(
                items: warnings,
                onItemTap: (warning) => Get.offNamed('/grafik-ogolny-kierownik'),
                itemBuilder: (context, warning) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: warning['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        warning['icon'],
                        size: 20,
                        color: warning['color'],
                      ),
                    ),
                    title: Text(
                      warning['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor1,
                      ),
                    ),
                    subtitle: Text(
                      warning['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor2,
                      ),
                    ),
                    trailing: Text(
                      warning['date'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor2,
                      ),
                    ),
                  );
                },
              ),
          
    );
  }

  // HELPERS
  Widget _baseTile({required String title, Widget? child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.logolighter,
            ),
          ),

          if (child != null)
            Expanded(
              child: child,
            ),
        ],
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _buildStatusChip(String status) {
    IconData icon;

    switch (status.toLowerCase()) {
      case 'zaakceptowany':
        icon = Icons.check;
        break;
      case 'odrzucony':
        icon = Icons.close;
        break;
      case 'oczekujący':
        icon = Icons.access_time;
        break;
      default:
        icon = Icons.help_outline;
    }

    final fixStatus = capitalize(status);

    return RawChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textColor2,
          ),
          const SizedBox(width: 4),
          Text(
            fixStatus,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 1.33,
              letterSpacing: 0.5,
              color: AppColors.textColor2,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: const Color(0xFFCAC4D0),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmployeeTags(List<String> tags) {
    if (tags.isEmpty) {
      return Text(
        'Brak tagów',
        style: TextStyle(fontSize: 14, color: AppColors.textColor2),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          tags
              .map(
                (tag) => RawChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 1.33,
                      letterSpacing: 0.5,
                      color: AppColors.textColor2,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Color(0xFFCAC4D0), width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
    );
  }

}
