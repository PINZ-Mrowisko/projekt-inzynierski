import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'schedule_type.dart';

class ScheduleExporter {
  ScheduleExporter._();

  static String _removePolishChars(String text) {
    return text
        .replaceAll('ą', 'a')
        .replaceAll('ć', 'c')
        .replaceAll('ę', 'e')
        .replaceAll('ł', 'l')
        .replaceAll('ń', 'n')
        .replaceAll('ó', 'o')
        .replaceAll('ś', 's')
        .replaceAll('ź', 'z')
        .replaceAll('ż', 'z')
        .replaceAll('Ą', 'A')
        .replaceAll('Ć', 'C')
        .replaceAll('Ę', 'E')
        .replaceAll('Ł', 'L')
        .replaceAll('Ń', 'N')
        .replaceAll('Ó', 'O')
        .replaceAll('Ś', 'S')
        .replaceAll('Ź', 'Z')
        .replaceAll('Ż', 'Z');
  }

  static Future<Uint8List> captureWidget(GlobalKey key, {double pixelRatio = 3.0}) async {
    try {
      final context = key.currentContext;
      if (context == null) {
        throw Exception('Widget context is null');
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('RenderRepaintBoundary not found');
      }

      await Future.delayed(const Duration(milliseconds: 100));
      
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert image to byte data');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      rethrow;
    }
  }

  static String fileNameForScheduleType(ScheduleType type, {DateTime? visibleDate}) {
    switch (type) {
      case ScheduleType.mainCalendar:
        if (visibleDate != null) {
          final weekNumber = _getWeekNumber(visibleDate);
          final monthName = _getPolishMonthName(visibleDate.month);
          return 'grafik_ogolny_${monthName}_${visibleDate.year}_tydzien_$weekNumber.pdf';
        }
        return 'grafik_ogolny_${DateTime.now().year}.pdf';
      case ScheduleType.individualCalendar:
        if (visibleDate != null) {
          final monthName = _getPolishMonthName(visibleDate.month);
          return 'grafik_indywidualny_${monthName}_${visibleDate.year}.pdf';
        }
        return 'grafik_indywidualny_${DateTime.now().year}.pdf';
    }
  }

  static Future<void> exportToPdf({
    required ScheduleType type,
    required GlobalKey chartKey,
    String? title,
    BuildContext? context,
    DateTime? visibleDate,
  }) async {
    try {
      if (chartKey.currentContext == null) {
        throw Exception('Widget nie jest dostępny');
      }

      final pdf = pw.Document();
      final imageBytes = await captureWidget(chartKey);
      
      if (imageBytes.isEmpty) {
        throw Exception('Nie udało się przechwycić obrazu kalendarza');
      }

      final image = pw.MemoryImage(imageBytes);
      final safeTitle = title != null ? _removePolishChars(title) : 'Grafik - ${_formatDate(visibleDate ?? DateTime.now())}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Container(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    safeTitle,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Data wygenerowania: ${_formatDate(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(
                        image,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                  pw.Text(
                    '© Mrowisko ${DateTime.now().year}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileNameForScheduleType(type, visibleDate: visibleDate), // Użyj nowej funkcji
      );
      
    } catch (e) {
      print('PDF Export Error: $e');
      rethrow;
    }
  }

  static String _getPolishMonthName(int month) {
    switch (month) {
      case 1: return 'styczen';
      case 2: return 'luty';
      case 3: return 'marzec';
      case 4: return 'kwiecien';
      case 5: return 'maj';
      case 6: return 'czerwiec';
      case 7: return 'lipiec';
      case 8: return 'sierpien';
      case 9: return 'wrzesien';
      case 10: return 'pazdziernik';
      case 11: return 'listopad';
      case 12: return 'grudzien';
      default: return '';
    }
  }

  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(firstDayOfYear).inDays;
    return ((daysDifference + firstDayOfYear.weekday) / 7).ceil();
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year}';
  }
}