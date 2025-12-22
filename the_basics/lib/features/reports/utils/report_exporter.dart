import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'report_tab_type.dart';

class ReportExporter {
  ReportExporter._();

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

  static Future<Uint8List> captureWidget(GlobalKey key) async {
    final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  static String fileNameForTab(ReportTabType type) {
    final year = DateTime.now().year;

    switch (type) {
      case ReportTabType.yearlyLeaves:
        return 'raport_urlopy_roczne_$year.pdf';
      case ReportTabType.monthlyLeaves:
        return 'raport_urlopy_miesieczne_$year.pdf';
      case ReportTabType.workingSundays:
        return 'raport_niedziele_handlowe_$year.pdf';
    }
  }

  static Future<void> exportToPdf({
    required ReportTabType type,
    required GlobalKey chartKey,
    String? title,
  }) async {
    final pdf = pw.Document();
    final imageBytes = await captureWidget(chartKey);
    
    final year = DateTime.now().year;
    final image = pw.MemoryImage(imageBytes);
  
    final safeTitle = title != null ? _removePolishChars(title) : 'Raport - $year';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              safeTitle,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Data wygenerowania: ${_formatDate(DateTime.now())}',
              style: pw.TextStyle(
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Image(image, fit: pw.BoxFit.contain),
            pw.SizedBox(height: 20),
            pw.Text(
              '© Mrowisko ${DateTime.now().year}',
              style: pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileNameForTab(type),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year}';
  }
}