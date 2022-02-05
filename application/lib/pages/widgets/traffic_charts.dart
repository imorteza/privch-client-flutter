import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrafficChart extends StatefulWidget {
  const TrafficChart(
    this.rxTrace,
    this.rxMax,
    this.txTrace,
    this.txMax, {
    Key? key,
  }) : super(key: key);

  final List<int> rxTrace;
  final List<int> txTrace;

  final int rxMax;
  final int txMax;

  @override
  _TrafficState createState() => _TrafficState();
}

class _TrafficState extends State<TrafficChart> {
  @override
  Widget build(BuildContext context) {
    final List<FlSpot> rxList = List.generate(widget.rxTrace.length, (index) {
      return FlSpot(index.toDouble(), widget.rxTrace[index].toDouble());
    });
    final List<FlSpot> txList = List.generate(widget.txTrace.length, (index) {
      return FlSpot(index.toDouble(), widget.txTrace[index].toDouble());
    });

    final maxY = max(max(widget.rxMax, widget.txMax), 10000);
    final _colorRx = <Color>[Theme.of(context).colorScheme.secondary];
    final _colorTx = <Color>[Colors.grey];

    return LineChart(
      LineChartData(
        maxY: maxY.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: rxList,
            belowBarData: BarAreaData(
              show: true,
              colors: _colorRx.map((color) => color.withOpacity(0.2)).toList(),
            ),
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            colors: _colorRx,
            barWidth: 1,
          ),
          LineChartBarData(
            spots: txList,
            belowBarData: BarAreaData(
              show: true,
              colors: _colorTx.map((color) => color.withOpacity(0.2)).toList(),
            ),
            isCurved: true,
            preventCurveOverShooting: true,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            colors: _colorTx,
            barWidth: 1,
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
