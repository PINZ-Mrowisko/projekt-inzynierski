// TAB WITH CURRENT SHIFT
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_basics/features/employees/controllers/user_controller.dart';
import 'package:the_basics/features/schedules/controllers/schedule_controller.dart';
import 'package:the_basics/features/schedules/models/schedule_model.dart';
import 'package:the_basics/features/tags/controllers/tags_controller.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';

Widget shiftTab(UserController userController, SchedulesController schedulesController, TagsController tagsController) {
    final now = DateTime.now();
    // use this to pass custom date to the datetime widget during testing
    //final now = DateTime(2026, 1, 6, 10, 0);
    final currentShifts = schedulesController.individualShifts
        .where((shift) => isShiftNow(shift, now))
        .toList()
      ..sort((a, b) =>
          a.employeeFirstName.compareTo(b.employeeFirstName));
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: currentShifts.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDateTimeWidget(),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text("Brak aktywnej zmiany"),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateTimeWidget(),
                const SizedBox(height: 16),
                Flexible(
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