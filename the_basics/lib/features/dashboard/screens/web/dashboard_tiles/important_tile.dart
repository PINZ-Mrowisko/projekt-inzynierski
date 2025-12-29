// TILE WITH SCHEDULE WARNINGS
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:the_basics/features/dashboard/screens/web/dashboard_tiles/base_tile.dart';
import 'package:the_basics/utils/app_colors.dart';
import 'package:the_basics/utils/common_widgets/generic_list.dart';

Widget importantTile() {
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

    return baseTile(
      title: "Ważne",
      child: warnings.isEmpty
          ? Center(
                child: Text("Brak ostrzeżeń",
                style: TextStyle(color: AppColors.textColor2),
                ),
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