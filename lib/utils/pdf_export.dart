import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../config/constants.dart';

class PdfExportHelper {
  static Future<void> exportResultPdf({
    required String courseCode,
    required int scorePercentage,
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpentSeconds,
    required String studentName,
  }) async {
    final pdf = pw.Document();

    final minutes = (timeSpentSeconds / 60).floor();
    final seconds = timeSpentSeconds % 60;
    final timeStr = '${minutes}m ${seconds}s';
    final passed = scorePercentage >= AppConstants.passingScorePercentage;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'GST CBT Prep App',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Exam Result Certificate',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Divider(thickness: 2, color: PdfColors.blueGrey300),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Student info
              pw.Text(
                'Student Name: $studentName',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Course: $courseCode',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${DateTime.now().toLocal().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 24),

              // Score Box
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blueGrey400, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Center(
                      child: pw.Text(
                        '$scorePercentage%',
                        style: pw.TextStyle(
                          fontSize: 48,
                          fontWeight: pw.FontWeight.bold,
                          color: passed ? PdfColors.green700 : PdfColors.red700,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Center(
                      child: pw.Text(
                        passed ? 'PASSED' : 'FAILED',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: passed ? PdfColors.green700 : PdfColors.red700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Details Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildTableRow('Correct Answers', '$correctAnswers / $totalQuestions'),
                  _buildTableRow('Score Percentage', '$scorePercentage%'),
                  _buildTableRow('Time Spent', timeStr),
                  _buildTableRow('Result', passed ? 'Pass' : 'Fail'),
                ],
              ),
              pw.SizedBox(height: 40),

              // Footer
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Powered by Siyayya.com',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
