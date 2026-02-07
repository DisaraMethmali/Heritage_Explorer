import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget<T> extends StatelessWidget {
  final List<T> points;
  final double Function(T) xValue;
  final double Function(T) yValue;
  final String Function(T)? xLabel;

  const LineChartWidget({
    super.key,
    required this.points,
    required this.xValue,
    required this.yValue,
    this.xLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: points.map((e) => FlSpot(xValue(e), yValue(e))).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
