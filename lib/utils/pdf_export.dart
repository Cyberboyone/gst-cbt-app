import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

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

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final minutes = (timeSpentSeconds / 60).floor();
    final seconds = timeSpentSeconds % 60;
    final timeStr = '${minutes}m ${seconds}s';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Logo / Branding
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GST CBT PREP REPORT',
                          style: pw.TextStyle(
                            fontSize: 24.0,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                          ),
                        ),
                        pw.SizedBox(height: 4.0),
                        pw.Text(
                          'Powered by Siyayya.com',
                          style: pw.TextStyle(
                            fontSize: 10.0,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        fontSize: 12.0,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                
                pw.Divider(thickness: 2.0, color: PdfColors.indigo900),
                pw.SizedBox(height: 24.0),

                // Report Summary Card
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12.0)),
                  ),
                  padding: const pw.EdgeInsets.all(20.0),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Student Profile',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12.0,
                              color: PdfColors.indigo700,
                            ),
                          ),
                          pw.SizedBox(height: 6.0),
                          pw.Text(
                            'Nickname: $studentName',
                            style: const pw.TextStyle(fontSize: 14.0),
                          ),
                          pw.SizedBox(height: 4.0),
                          pw.Text(
                            'Course Code: $courseCode',
                            style: const pw.TextStyle(fontSize: 14.0),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Exam Score',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12.0,
                              color: PdfColors.indigo700,
                            ),
                          ),
                          pw.SizedBox(height: 6.0),
                          pw.Text(
                            '$scorePercentage%',
                            style: pw.TextStyle(
                              fontSize: 32.0,
                              fontWeight: pw.FontWeight.bold,
                              color: scorePercentage >= 45 ? PdfColors.green700 : PdfColors.red700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32.0),

                // Details Table
                pw.Text(
                  'Attempt Details',
                  style: pw.TextStyle(
                    fontSize: 16.0,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo900,
                  ),
                ),
                pw.SizedBox(height: 12.0),

                pw.TableHelper.fromTextArray(
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                  headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                  cellHeight: 30.0,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                  },
                  headers: ['Metric', 'Performance Summary'],
                  data: [
                    ['Course Subject', courseCode],
                    ['Total Exam Questions', '$totalQuestions'],
                    ['Correctly Answered', '$correctAnswers'],
                    ['Incorrectly Answered', '${totalQuestions - correctAnswers}'],
                    ['Time Spent', timeStr],
                    ['Status', scorePercentage >= 45 ? 'PASSED (Credit)' : 'FAILED (Re-take Required)'],
                  ],
                ),

                pw.Spacer(),

                // Footer Note
                pw.Divider(thickness: 1.0, color: PdfColors.grey300),
                pw.SizedBox(height: 8.0),
                pw.Center(
                  child: pw.Text(
                    'This is an automated CBT preparation transcript from the GST Prep Application. Keep studying to succeed!',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 9.0,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Prompt user to print or save PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'GST_CBT_Result_$courseCode.pdf',
    );
  }
}
