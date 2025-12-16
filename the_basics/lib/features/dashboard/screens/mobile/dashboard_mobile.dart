import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/bottom_menu_mobile/bottom_menu_mobile.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';
import '../../../employees/controllers/user_controller.dart';

class ManagerDashboardMobileScreen extends StatefulWidget {
  const ManagerDashboardMobileScreen({super.key});

  @override
  State<ManagerDashboardMobileScreen> createState() => _ManagerDashboardMobileScreenState();
}

class _ManagerDashboardMobileScreenState extends State<ManagerDashboardMobileScreen> {
  final UserController userController = Get.find<UserController>();
  final LeaveController leaveController = Get.find<LeaveController>();
  final isLoading = true.obs;
  final readyToShow = false.obs;

  final RxInt selectedTab = 0.obs;
  final RxInt currentMenuIndex = 2.obs;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      readyToShow.value = false;
      
      try {
        await userController.fetchAllEmployees();
        await leaveController.fetchLeaves();
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

      final tabs = [
        "Aktualna zmiana",
        "Wnioski",
        "Ważne",
      ];

      if (isLoading.value || !readyToShow.value) {
        return Scaffold(
          backgroundColor: AppColors.pageBackground,
          appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
            color: AppColors.pageBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Dashboard',
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
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.logo)
        ),
      );
    }

      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 14),
            color: AppColors.pageBackground,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      'Dashboard',
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
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 26),
                      color: AppColors.logo,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // TABS
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    for (int i = 0; i < tabs.length; i++)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => selectedTab.value = i,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: selectedTab.value == i
                                      ? AppColors.lightBlue
                                      : AppColors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tabs[i],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selectedTab.value == i
                                      ? AppColors.logolighter
                                      : AppColors.textColor2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // TAB CONTENT
            Expanded(
              child: Obx(() {
                switch (selectedTab.value) {
                  case 0:
                    return _shiftTab(userController);

                  case 1:
                    return _leavesTab(leaveController);

                  case 2:
                    return _importantTab();

                  default:
                    return Container();
                }
              }),
            )
          ],
        ),
        bottomNavigationBar: MobileBottomMenu(currentIndex: currentMenuIndex),
      );
    });
  }

  // TAB WITH CURRENT SHIFT
  Widget _shiftTab(UserController userController) {
    // for now: all employees are on the current shift, to change when schedules are available
    final currentShiftEmployees = userController.allEmployees
      .toList()
      ..sort((a, b) => (a.firstName ?? '').compareTo(b.firstName ?? ''));
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: currentShiftEmployees.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateTimeWidget(),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("Brak pracowników na zmianie"),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateTimeWidget(),
                const SizedBox(height: 16),
                Flexible(
                  child: GenericList<UserModel>(
                    items: currentShiftEmployees,
                    itemBuilder: (context, employee) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          '${employee.firstName} ${employee.lastName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor1,
                          ),
                        ),
                        subtitle: _buildEmployeeTags(employee.tags),
                      );
                    },
                  ),
                ),
              ],
            ),
    );

  }

  Widget _buildDateTimeWidget() {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
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

  // TAB WITH LEAVES TO APPROVE
  Widget _leavesTab(LeaveController leaveController) {
    final pending = leaveController.allLeaveRequests
        .where((l) => l.status.toLowerCase() == 'oczekujący')
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: pending.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("Brak wniosków oczekujących"),
              )
            : Flexible(
                child: GenericList<LeaveModel>(
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
              ),
    );
  }

  // TAB WITH SCHEDULE WARNINGS
  Widget _importantTab() {
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

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: warnings.isEmpty
            ? const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("Brak ostrzeżeń"),
              )
            : Flexible(
                child: GenericList<Map<String, dynamic>>(
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
              ),
    );
  }

  // HELPERS
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
