import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/metrics.dart';

class MetricsPdfService {
  /// -------- EXPORT PDF --------
  static Future<File> generatePdf(Metrics metrics) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Chatbot Performance Metrics',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 16),

          _section('Intent Distribution', metrics.intentDistribution),
          _section('Topic Distribution', metrics.topicDistribution),

          pw.SizedBox(height: 12),
          pw.Text(
            'Training Loss',
            style: pw.TextStyle(fontSize: 16),
          ),
          pw.Table.fromTextArray(
            headers: ['Step', 'Loss'],
            data: metrics.trainingMetrics
                .map((e) => [e.step.toString(), e.loss.toStringAsFixed(4)])
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chatbot_metrics.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _section(String title, Map<String, int> data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Table.fromTextArray(
          headers: ['Category', 'Count'],
          data: data.entries.map((e) => [e.key, e.value.toString()]).toList(),
        ),
        pw.SizedBox(height: 16),
      ],
    );
  }
}
