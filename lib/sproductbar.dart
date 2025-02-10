import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProductSalesChart extends StatelessWidget {
  final List<int> productData;  // Total quantity per product
  final List<String> labels;    // Product names

  const ProductSalesChart({required this.productData, required this.labels, Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: List.generate(productData.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: productData[index].toDouble(),
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 30, // Increased bar width for a bolder look
                    borderRadius: BorderRadius.circular(8), // Rounded corners for bars
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: productData.reduce((max, e) => e > max ? e : max).toDouble(),
                      color: Colors.grey[200],
                    ),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Text(
                        labels[value.toInt()],
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d), width: 1),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey[300],
                  strokeWidth: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}