// TAB WITH SCHEDULE WARNINGS
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';

Widget importantTab() {
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