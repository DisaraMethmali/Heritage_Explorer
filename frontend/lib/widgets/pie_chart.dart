import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, int> data;

  const PieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final sections = data.entries.map((e) {
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.key} (${e.value})',
        color: Colors.primaries[data.keys.toList().indexOf(e.key) %
            Colors.primaries.length],
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      child: PieChart(PieChartData(sections: sections)),
    );
  }
}
