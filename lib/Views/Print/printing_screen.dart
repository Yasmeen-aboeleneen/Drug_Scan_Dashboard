// ignore_for_file: use_build_context_synchronously

import 'package:dashboard_drug_scan/Core/colors.dart';
import 'package:dashboard_drug_scan/Views/Widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PrintingScreen extends StatefulWidget {
  const PrintingScreen({super.key});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen> {
  bool _isGenerating = false;

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    final querySnapshot =
        await FirebaseFirestore.instance.collection('analysis_results').get();

    final data = querySnapshot.docs.map((doc) {
      // ignore: unnecessary_cast
      final data = doc.data() as Map<String, dynamic>;
      return [
        data['userName'] ?? 'Unknown User',
        data['userEmail'] ?? 'No Email',
        data['result'] ?? 'No Result',
        data['detectedDrug'] ?? 'No Drug Detected',
        (data['timestamp'] as Timestamp).toDate().toString(),
      ];
    }).toList();

    data.insert(0, ['Name', 'Email', 'Result', 'Detected Drug', 'Timestamp']);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Analysis Results Report')),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                context: context,
                data: data,
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final pdf = await _generatePdf();

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/analysis_results.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (await file.exists()) {
      } else {
        throw Exception('File does not exist');
      }

      await Share.shareXFiles([XFile(filePath)], text: 'Check out this PDF!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share PDF: $e'),
        ),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: kveryWhite,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: kveryWhite),
        backgroundColor: kPrimary,
        title: Text(
          'Print Data As PDF',
          style: GoogleFonts.cairo(
              color: kveryWhite,
              fontSize: w * .06,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: _isGenerating
            ? CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                      onTap: () async {
                        final pdf = await _generatePdf();

                        await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdf.save(),
                        );
                      },
                      child: CustomButton(text: "Print PDF")),
                  SizedBox(height: 20),
                  GestureDetector(
                      onTap: _sharePdf, child: CustomButton(text: "Share PDF"))
                ],
              ),
      ),
    );
  }
}
