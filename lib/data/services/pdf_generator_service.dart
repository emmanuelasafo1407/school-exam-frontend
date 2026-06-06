import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' show debugPrint;

class PdfGeneratorService {
  static Future<void> generateAndPrintLedger({
    required String courseCode,
    required String courseName,
    required String hall,
    required String dateGenerated,
    required String invigilatorName,
    required String? signaturePicture,
    required List<dynamic> records,
  }) async {
    final pdf = pw.Document();

    pw.ImageProvider? signatureImageWidget;

    if (signaturePicture != null) {
      try {
        final cleanUrl = signaturePicture.replaceAll(
          "localhost",
          "172.20.10.3",
        );
        signatureImageWidget = await networkImage(cleanUrl);
      } catch (e) {
        debugPrint("Signature failed to load: $e");
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "GHANA COMMUNICATION TECHNOLOGY UNIVERSITY",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Center(
            child: pw.Text(
              "FACULTY OF ENGINEERING",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Center(
            child: pw.Text(
              "Official Examination Attendance Ledger",
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 16),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "COURSE: $courseCode - ${courseName.toUpperCase()}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    "EXAMINATION HALL: ${hall.toUpperCase()}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "DATE GENERATED: $dateGenerated",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    "TOTAL RECORDS: ${records.length} Students",
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // 👈 FIXED ARRAY MATRIX: Houses both explicit tracking time markers
          pw.TableHelper.fromTextArray(
            headers: [
              "#",
              "STUDENT ID",
              "STUDENT NAME",
              "SESSION",
              "PAPER CODE",
              "TIME LOGGED", // 👈 Restored
              "SUBMITTED",
              "TIME SUBMITTED", // 👈 Kept
            ],
            data: List<List<String>>.generate(records.length, (index) {
              final item = records[index];
              final bool isTurnedIn =
                  item["paper_submitted"] == true ||
                  item["paper_submitted"] == 1;
              return [
                (index + 1).toString(),
                item["index_number"].toString(),
                item["student_name"].toString(),
                item["session"].toString().toUpperCase(),
                item["paper_code"]?.toString() ?? "N/A",
                item["time_logged"]?.toString() ??
                    "N/A", // 👈 Renders attendance timestamp
                isTurnedIn ? "YES" : "NO",
                item["time_submitted"]?.toString() ??
                    "PENDING", // 👈 Renders script submission timestamp
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
            },
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (signatureImageWidget != null)
                    pw.Container(
                      width: 100,
                      height: 40,
                      margin: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Image(
                        signatureImageWidget,
                        fit: pw.BoxFit.contain,
                      ),
                    )
                  else
                    pw.SizedBox(height: 44),
                  pw.Container(
                    width: 160,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.75,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "INVIGILATOR: $invigilatorName",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 44),
                  pw.Container(
                    width: 160,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: 0.75,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "CO-INVIGILATOR SIGNATURE",
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            "Page ${context.pageNumber} of ${context.pagesCount} | Generated by Silent Presence Secure System",
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
