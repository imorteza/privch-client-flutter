/*
  Xinlake Liu

  2022-04-22
  - Change to StatelessWidget
 */

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TrafficChart extends StatelessWidget {
  const TrafficChart({
    required this.rxMax,
    required this.txMax,
    required this.rxTrace,
    required this.txTrace,
    required this.rxColors,
    required this.txColors,
    this.rxBarWidth = 1,
    this.txBarWidth = 1,
    Key? key,
  }) : super(key: key);

  final int rxMax;
  final int txMax;

  final List<int> rxTrace;
  final List<int> txTrace;

  final double rxBarWidth;
  final double txBarWidth;
  final List<Color> rxColors;
  final List<Color> txColors;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> rxList = List.generate(rxTrace.length, (index) {
      return FlSpot(index.toDouble(), rxTrace[index].toDouble());
    });
    final List<FlSpot> txList = List.generate(txTrace.length, (index) {
      return FlSpot(index.toDouble(), txTrace[index].toDouble());
    });

    // max y, at least 1k
    final maxY = max(max(rxMax, txMax), 1000);

    return LineChart(
      LineChartData(
        maxY: maxY.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: rxList,
            belowBarData: rxColors.length > 1
                ? BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: rxColors,
                    ),
                  )
                : BarAreaData(
                    show: true,
                    color: rxColors.first.withOpacity(0.3),
                  ),
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            barWidth: rxBarWidth,
            color: rxColors.first, // not have to
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                rxColors.first,
                rxColors.first,
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.05, 0.95, 1.0],
            ),
          ),
          LineChartBarData(
            spots: txList,
            belowBarData: txColors.length > 1
                ? BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: txColors,
                    ),
                  )
                : BarAreaData(
                    show: true,
                    color: rxColors.first.withOpacity(0.6),
                  ),
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            barWidth: txBarWidth,
            color: txColors.first, // not have to
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                txColors.first,
                txColors.first,
                Colors.transparent,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.05, 0.95, 1.0],
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: false,
          drawHorizontalLine: false,
          drawVerticalLine: false,
        ),
      ),
      swapAnimationDuration: Duration.zero,
    );
  }
}
