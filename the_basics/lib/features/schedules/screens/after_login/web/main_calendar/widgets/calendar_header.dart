import 'package:flutter/material.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/custom_button.dart';
import 'package:the_basics/features/schedules/usecases/show_export_dialog.dart';
import '../widgets/calendar_filters.dart';

class CalendarHeader extends StatelessWidget {
  final VoidCallback onLoadSchedule;
  final bool isLoading;

  const CalendarHeader({
    Key? key,
    required this.onLoadSchedule,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Grafik ogólny',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildLoadScheduleButton(),
                const SizedBox(width: 16),
                const Flexible(child: CalendarFilters()),
                const SizedBox(width: 16),
                Flexible(
                  child: CustomButton(
                    onPressed: () => showExportDialog(context),
                    text: "Eksportuj",
                    width: 125,
                    icon: Icons.download,
                    backgroundColor: AppColors.lightBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadScheduleButton() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: CircularProgressIndicator(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: CustomButton(
        onPressed: onLoadSchedule,
        text: "Załaduj grafik",
        width: 140,
        icon: Icons.schedule,
        backgroundColor: AppColors.logo,
      ),
    );
  }
}