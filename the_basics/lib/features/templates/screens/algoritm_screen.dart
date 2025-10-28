import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import '../../../utils/common_widgets/side_menu.dart';
import '../controllers/algorithm_controller.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleController = Get.find<ScheduleController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleController.loadSchedule(); // wywołanie tylko raz po starcie
    });

    return Obx(() {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
            child: SideMenu(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80, child: _Header()),
                  Expanded(
                    child: Obx(() {
                      if (scheduleController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (scheduleController.errorMessage.value.isNotEmpty) {
                        return Center(child: Text(scheduleController.errorMessage.value));
                      }
                      if (scheduleController.schedule.isEmpty) {
                        return const Center(child: Text('Brak dostępnych danych o grafiku'));
                      }
                      return _buildScheduleList(scheduleController);
                    }),
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

  Widget _buildScheduleList(ScheduleController controller) {
    return ListView.builder(
      itemCount: controller.schedule.length,
      itemBuilder: (context, index) {
        final day = controller.schedule[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ExpansionTile(
            title: Text(day.dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: day.shifts.map((shift) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zmiana ${shift.shift}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ...shift.workers.map((w) => ListTile(
                      title: Text('${w.firstname} ${w.lastname}'),
                      subtitle: Text(w.role),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    )),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Grafik',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.logo,
          ),
        ),
      ],
    );
  }
}
