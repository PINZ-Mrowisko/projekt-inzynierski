import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:the_basics/features/auth/models/user_model.dart';
import 'package:the_basics/utils/app_colors.dart';

class CustomCalendarDataSource extends CalendarDataSource {
  CustomCalendarDataSource({
    required List<Appointment> appointments,
    required List<UserModel> employees,
  }) {
    this.appointments = appointments;
    resources = employees.map((employee) => CalendarResource(
      displayName: '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
      id: employee.id ?? '',
      color: AppColors.blue,
    )).toList();
  }
}