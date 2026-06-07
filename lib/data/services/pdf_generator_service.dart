import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart' show debugPrint;

class PdfGeneratorService {
  // 1. NEW: Method for Student QR Passes
  static Future<void> generateStudentPass({
    required String studentName,
    required String studentId,
    required String qrPayload,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  "OFFICIAL HALL ADMISSION TOKEN",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qrPayload,
                  width: 250,
                  height: 250,
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  "STUDENT: ${studentName.toUpperCase()}",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "ID NUMBER: $studentId",
                  style: const pw.TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // 2. EXISTING: Method for Invigilator Ledgers
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
    if (signaturePicture != null && signaturePicture.isNotEmpty) {
      try {
        final cleanUrl = signaturePicture.replaceAll(
          "localhost",
          "172.20.10.3",
        );
        signatureImageWidget = await networkImage(cleanUrl);
      } catch (e) {
        debugPrint("Signature image failed to load: $e");
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) => pw.Column(
          children: [
            pw.Center(
              child: pw.Text(
                "GHANA COMMUNICATION TECHNOLOGY UNIVERSITY",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                "FACULTY OF ENGINEERING",
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Center(
              child: pw.Text(
                "Official Examination Attendance Ledger",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
          ],
        ),
        build: (pw.Context context) => [
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
          pw.TableHelper.fromTextArray(
            headers: [
              "#",
              "STUDENT ID",
              "STUDENT NAME",
              "SESSION",
              "PAPER CODE",
              "TIME LOGGED",
              "SUBMITTED",
              "TIME SUBMITTED",
            ],
            data: List<List<String>>.generate(records.length, (index) {
              final item = records[index];
              final bool isTurnedIn =
                  item["paper_submitted"] == true ||
                  item["paper_submitted"] == 1 ||
                  item["paper_submitted"] == "1";
              return [
                (index + 1).toString(),
                item["index_number"].toString(),
                item["student_name"].toString(),
                item["session"].toString().toUpperCase(),
                item["paper_code"]?.toString() ?? "N/A",
                item["time_logged"]?.toString() ?? "N/A",
                isTurnedIn ? "YES" : "NO",
                item["time_submitted"]?.toString() ?? "PENDING",
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
            },
          ),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _buildSignatureBlock(
                invigilatorName,
                signatureImageWidget,
                "INVIGILATOR",
              ),
              _buildSignatureBlock("CO-INVIGILATOR", null, "SIGNATURE"),
            ],
          ),
        ],
        footer: (pw.Context context) => pw.Container(
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

  static pw.Widget _buildSignatureBlock(
    String label,
    pw.ImageProvider? image,
    String role,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (image != null)
          pw.Container(
            width: 80,
            height: 30,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          )
        else
          pw.SizedBox(height: 30),
        pw.Container(
          width: 140,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "$role: $label",
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
