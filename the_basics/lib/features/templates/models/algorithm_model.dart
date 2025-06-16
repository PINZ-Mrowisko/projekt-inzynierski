class Worker {
  final String firstname;
  final String lastname;
  final String role;

  Worker({required this.firstname, required this.lastname, required this.role});

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
    firstname: json['firstname'],
    lastname: json['lastname'],
    role: json['role'],
  );
}

class Shift {
  final int shift;
  final List<Worker> workers;

  Shift({required this.shift, required this.workers});

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    shift: json['shift'],
    workers: List<Worker>.from(json['workers'].map((w) => Worker.fromJson(w))),
  );
}

class DaySchedule {
  final int day;
  final List<Shift> shifts;

  DaySchedule({required this.day, required this.shifts});

  factory DaySchedule.fromJson(Map<String, dynamic> json) => DaySchedule(
    day: json['day'],
    shifts: List<Shift>.from(json['shifts'].map((s) => Shift.fromJson(s))),
  );
}
