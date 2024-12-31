// lib/features/dashboard/widgets/process/parameter_trend_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/parameter_data_point.dart';

class ParameterTrendChart extends StatefulWidget {
  final String parameter;
  final List<ParameterDataPoint> data;
  final double? setPoint;
  final Duration timeWindow;

  const ParameterTrendChart({
    required this.parameter,
    required this.data,
    this.setPoint,
    // By default, show the last 5 minutes of data
    this.timeWindow = const Duration(minutes: 5),
  });

  @override
  _ParameterTrendChartState createState() => _ParameterTrendChartState();
}

class _ParameterTrendChartState extends State<ParameterTrendChart> {
  // Track the visible data range
  double? _minY;
  double? _maxY;

  // Store the parameter unit for display
  late final String _unit;

  @override
  void initState() {
    super.initState();
    _unit = _getParameterUnit(widget.parameter);
    _updateDataRange();
  }

  // Update the visible range whenever the data changes
  @override
  void didUpdateWidget(ParameterTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _updateDataRange();
    }
  }

  void _updateDataRange() {
    if (widget.data.isEmpty) {
      _minY = 0;
      _maxY = 100;
      return;
    }

    // Calculate the range from the data
    _minY = widget.data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    _maxY = widget.data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Include the setpoint in the range if it exists
    if (widget.setPoint != null) {
      _minY = _minY!.min(widget.setPoint!);
      _maxY = _maxY!.max(widget.setPoint!);
    }

    // Add some padding to the range
    final range = _maxY! - _minY!;
    _minY = _minY! - range * 0.1;
    _maxY = _maxY! + range * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartHeader(),
          Expanded(
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    // The header shows current value and setpoint information
    final currentValue = widget.data.isNotEmpty
        ? widget.data.last.value
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentValue != null)
          Text(
            'Current: ${currentValue.toStringAsFixed(2)} $_unit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (widget.setPoint != null)
          Text(
            'Setpoint: ${widget.setPoint!.toStringAsFixed(2)} $_unit',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildChart() {
    // Convert our data points to chart format
    final spots = widget.data.map((point) {
      return FlSpot(
        point.timestamp.millisecondsSinceEpoch.toDouble(),
        point.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        gridData: _buildGridData(),
        titlesData: _buildTitlesData(),
        borderData: _buildBorderData(),
        lineBarsData: [
          // Parameter value line
          _buildParameterLine(spots),
          // Setpoint reference line
          if (widget.setPoint != null)
            _buildSetPointLine(widget.setPoint!),
        ],
        lineTouchData: _buildTouchData(),
        minX: _getMinX(),
        maxX: DateTime.now().millisecondsSinceEpoch.toDouble(),
        minY: _minY,
        maxY: _maxY,
      ),
    );
  }

  LineChartBarData _buildParameterLine(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blue,
      barWidth: 2,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.1),
      ),
    );
  }

  LineChartBarData _buildSetPointLine(double setPoint) {
    return LineChartBarData(
      spots: [
        FlSpot(_getMinX(), setPoint),
        FlSpot(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          setPoint,
        ),
      ],
      color: Colors.white30,
      barWidth: 1,
      dotData: FlDotData(show: false),
      dashArray: [5, 5], // Create a dashed line
    );
  }

  double _getMinX() {
    return (DateTime.now()
            .subtract(widget.timeWindow)
            .millisecondsSinceEpoch)
        .toDouble();
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: (_maxY! - _minY!) / 5,
      verticalInterval: widget.timeWindow.inMilliseconds / 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.white10,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.white10,
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final time = DateTime.fromMillisecondsSinceEpoch(value.toInt());
            return Text(
              '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            );
          },
          interval: widget.timeWindow.inMilliseconds / 5,
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: TextStyle(color: Colors.white54, fontSize: 12),
            );
          },
          interval: (_maxY! - _minY!) / 5,
        ),
      ),
      rightTitles: AxisTitles(showTitles: false),
      topTitles: AxisTitles(showTitles: false),
    );
  }
}


// This ParameterTrendChart component provides several important features:

// Real-time Visualization

// Continuously updates as new data arrives
// Smooth line representation of parameter values
// Clear indication of current value and setpoint


// Adaptive Scaling

// Automatically adjusts Y-axis range based on data
// Maintains readability by adding padding to the range
// Includes setpoint in range calculations


// Time Window Management

// Shows a configurable time window of data
// Scrolling time axis with readable timestamps
// Grid lines for easy time reference


// Interactive Features

// Hover to see exact values
// Clear indication of current value
// Visual comparison with setpoint