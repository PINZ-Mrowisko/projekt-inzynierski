// TAB WITH LEAVES TO APPROVE
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/leaves/controllers/leave_controller.dart';
import 'package:the_basics/features/leaves/models/leave_model.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';

Widget leavesTab(LeaveController leaveController) {
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