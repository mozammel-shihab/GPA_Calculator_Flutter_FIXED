import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../services/app_store.dart';

class Reports extends StatelessWidget {
  const Reports({super.key, required this.store});

  final AppStore store;

  Future<void> _generatePdf() async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('GPA Calculator Pro - Academic Report'),
          ),
          pw.Text('Student: ${store.studentName}'),
          pw.Text('Student ID: ${store.studentId.isEmpty ? 'N/A' : store.studentId}'),
          pw.Text('University: ${store.university.isEmpty ? 'N/A' : store.university}'),
          pw.SizedBox(height: 18),
          ...store.history.map(
            (record) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${record.semester} — GPA ${record.gpa.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Credits: ${record.totalCredits.toStringAsFixed(2)} | Grade Points: ${record.totalGradePoints.toStringAsFixed(2)}',
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: const ['Course', 'Code', 'Credit', 'Grade', 'Point'],
                  data: record.courses
                      .map(
                        (course) => [
                          course.name,
                          course.code,
                          course.credit.toStringAsFixed(1),
                          course.grade,
                          (record.scale[course.grade] ?? 0).toStringAsFixed(2),
                        ],
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => document.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, size: 54),
                  const SizedBox(height: 12),
                  Text(
                    'Academic Report',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate a printable PDF containing student information, saved semesters, courses, credits, grade points and GPA.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: store.history.isEmpty ? null : _generatePdf,
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Generate / Print PDF'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...store.history.map(
            (record) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(record.semester),
                subtitle: Text(
                  '${record.courses.length} courses • ${record.totalCredits.toStringAsFixed(1)} credits',
                ),
                trailing: Text(
                  record.gpa.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
