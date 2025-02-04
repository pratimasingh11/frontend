import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> salesData;

  SalesBarChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: salesData.map((data) {
          final category = data['category_name'];
          final sales = double.parse(data['total_sales']);
          final index = salesData.indexOf(data);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: sales, color: Colors.blue, width: 16),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double index) => salesData[index.toInt()]['category_name'],
          ),
        ),
      ),
    );
  }
}

class SalesBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> salesData;

  SalesBarChart({required this.salesData});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: salesData.map((data) {
          final category = data['category_name'];
          final sales = double.parse(data['total_sales']);
          final index = salesData.indexOf(data);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: sales, color: Colors.blue, width: 16),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(showTitles: true),
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double index) => salesData[index.toInt()]['category_name'],
          ),
        ),
      ),
    );
  }
}
