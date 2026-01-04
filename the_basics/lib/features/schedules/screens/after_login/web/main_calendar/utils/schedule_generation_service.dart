import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/choose_month.dart';
import 'package:the_basics/features/schedules/screens/after_login/web/main_calendar/utils/generation_overlay.dart';
import 'package:the_basics/features/schedules/usecases/choose_existing_schedule.dart';
import 'package:the_basics/features/schedules/usecases/choose_schedule_generation_type.dart';
import 'package:the_basics/features/schedules/usecases/choose_template.dart';
import '../../../../../../employees/controllers/user_controller.dart';
import '../../../../../controllers/schedule_controller.dart';

class ScheduleGenerationService {
  String? _selectedMethod;
  String? _selectedSourceId;
  String? _selectedSourceName;
  bool _isGenerating = false;

  bool get isGenerating => _isGenerating;
  String? get selectedMethod => _selectedMethod;

  Future<void> startGenerationFlow(BuildContext context) async {
    if (_isGenerating) return;

    try {
      // 1. Wybór metody generowania
      showGenerationMethodDialog(context, (method) async {
        if (method == null) return;

        _selectedMethod = method;

        // 2. Wybór źródła
        if (method == 'template') {

          showChooseMonth(context, (selectedTargetMonth) {

            if (selectedTargetMonth == null) return;

            showChooseTemplateDialog(context, (selectedTemplate) async {
              if (selectedTemplate != null) {

                _selectedSourceId = selectedTemplate;
                _selectedSourceName = selectedTemplate;

                await _generateAndNavigate(context, 'template', targetDate: selectedTargetMonth);
              }
            });
          });

        } else if (method == 'existing_schedule') {
          showChooseExistingScheduleDialog(context, (selectedSchedule) async {
            if (selectedSchedule != null) {
              _selectedSourceId = selectedSchedule;
              _selectedSourceName = selectedSchedule;
              await _generateAndNavigate(context, 'existing_schedule');
            }
          });
        }
      });

    } catch (e) {
      _showError(context, 'Błąd podczas generowania: ${e.toString()}');
    }
  }


  Future<void> _generateAndNavigate(
      BuildContext context,
      String sourceType,
      {String? targetDate}
      ) async {
        SimpleLoadingOverlay.show(context, message: 'Generowanie grafiku...');
    try {
      _isGenerating = true;

      final scheduleController = Get.find<SchedulesController>();

      final userController = Get.find<UserController>();
      final marketId = userController.employee.value.marketId;

      if (marketId.isEmpty) {
        throw Exception('Brak marketId');
      }

      if (sourceType == 'template') {
        final result = await scheduleController.generateScheduleFromTemplate(
          templateId: _selectedSourceId!,
          targetDate: targetDate!,
          marketId: marketId,
        );

          final newScheduleId = result;

          // after we get the ID of the schedule we will be generating, let's move onto editing

          // 1. fetch into our controller the ID of the new schedule
          // the publishedID still remains the same, but lets change the displayed

        scheduleController.displayedScheduleID.value = newScheduleId;
        scheduleController.fetchAndParseGeneratedSchedule(marketId: marketId, scheduleId: scheduleController.displayedScheduleID.value);

        // 2. proceed onto editing screen, where we wish to display our schedule.

          // hide overlay
          SimpleLoadingOverlay.hide();

          Navigator.of(context).pushNamed(
            '/grafik-ogolny-kierownik/edytuj-grafik',
            arguments: {
              'scheduleId': newScheduleId,
              'sourceType': sourceType,
              'sourceName': _selectedSourceName,
              'marketId': marketId,
            },
          );


      } else if (sourceType == 'existing_schedule') {
        // TODO: Implement dla istniejącego grafiku
        await Future.delayed(const Duration(seconds: 1));

        // final newScheduleId = await _generateFromExistingSchedule(
        //   sourceId: _selectedSourceId!,
        //   marketId: marketId,
        // );


        // Navigator.of(context).pushNamed(
        //   '/grafik-ogolny-kierownik/edytuj-grafik',
        //   arguments: {
        //     'scheduleId': newScheduleId,
        //     'sourceType': sourceType,
        //     'sourceName': _selectedSourceName,
        //   },
        // );
      }

    } catch (e) {
      _showError(context, 'Błąd podczas generowania: ${e.toString()}');
    } finally {
      _isGenerating = false;
    }
  }


  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void reset() {
    _selectedMethod = null;
    _selectedSourceId = null;
    _selectedSourceName = null;
    _isGenerating = false;
  }
}

// class _SelectionItem {
//   final String id;
//   final String name;

//   _SelectionItem({required this.id, required this.name});
// }