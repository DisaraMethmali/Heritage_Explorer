import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/metrics.dart';
import 'package:csv/csv.dart';

class MetricsExportService {
  static Future<File?> generateCsv(Metrics metrics) async {
    try {
      List<List<dynamic>> rows = [];

      // Training metrics
      rows.add(['Step', 'Loss']);
      for (var metric in metrics.trainingMetrics) {
        rows.add([metric.step, metric.loss]);
      }

      // Query times
      rows.add([]);
      rows.add(['Query', 'Time']);
      for (var query in metrics.queryTimes) {
        rows.add([query.query, query.time]);
      }

      // RL rewards
      rows.add([]);
      rows.add(['Reward Name', 'Value']);
      for (var reward in metrics.rlRewards) {
        rows.add([reward.name, reward.value]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/metrics.csv';
      final file = File(path);
      await file.writeAsString(csvData);
      return file;
    } catch (e) {
      print('CSV export error: $e');
      return null;
    }
  }
}
