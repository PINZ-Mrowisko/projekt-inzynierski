import 'package:flutter/material.dart';

class CalendarLoadingState extends StatelessWidget {
  const CalendarLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}