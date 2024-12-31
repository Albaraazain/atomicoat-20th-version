import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/components/providers/component_provider.dart';
import '../../../../features/components/models/component.dart';
import '../../../../features/components/models/component_parameter.dart';

class GraphOverlay extends StatefulWidget {
  final String overlayId;

  GraphOverlay({required this.overlayId});

  @override
  _GraphOverlayState createState() => _GraphOverlayState();
}

class _GraphOverlayState extends State<GraphOverlay> {
  Map<String, Offset> _componentPositions = {};
  Size _diagramSize = Size.zero;
  bool _isEditMode = false;

  final Map<String, Color> componentColors = {
    'Nitrogen Generator': Colors.blueAccent,
    'MFC': Colors.green,
    'Backline Heater': Colors.orange,
    'Frontline Heater': Colors.purple,
    'Precursor Heater 1': Colors.teal,
    'Precursor Heater 2': Colors.indigo,
    'Reaction Chamber': Colors.redAccent,
    'Pressure Control System': Colors.cyan,
    'Vacuum Pump': Colors.amber,
    'Valve 1': Colors.brown,
    'Valve 2': Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    _loadComponentPositions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDiagramSize();
    });
  }

  void _updateDiagramSize() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _diagramSize = renderBox.size;
      });
      if (_componentPositions.isEmpty) {
        _initializeDefaultPositions();
      }
    }
  }

  Future<void> _resetComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('component_positions_graph_overlay_${widget.overlayId}');
    _initializeDefaultPositions();
    setState(() {});
  }

  void _initializeDefaultPositions() {
    if (_diagramSize == Size.zero) return;

    setState(() {
      _componentPositions = {
        'Nitrogen Generator': Offset(_diagramSize.width * 0.05, _diagramSize.height * 0.80),
        'MFC': Offset(_diagramSize.width * 0.20, _diagramSize.height * 0.70),
        'Backline Heater': Offset(_diagramSize.width * 0.35, _diagramSize.height * 0.60),
        'Frontline Heater': Offset(_diagramSize.width * 0.50, _diagramSize.height * 0.50),
        'Precursor Heater 1': Offset(_diagramSize.width * 0.65, _diagramSize.height * 0.40),
        'Precursor Heater 2': Offset(_diagramSize.width * 0.80, _diagramSize.height * 0.30),
        'Reaction Chamber': Offset(_diagramSize.width * 0.50, _diagramSize.height * 0.20),
        'Pressure Control System': Offset(_diagramSize.width * 0.75, _diagramSize.height * 0.75),
        'Vacuum Pump': Offset(_diagramSize.width * 0.85, _diagramSize.height * 0.85),
        'Valve 1': Offset(_diagramSize.width * 0.60, _diagramSize.height * 0.60),
        'Valve 2': Offset(_diagramSize.width * 0.60, _diagramSize.height * 0.40),
      };
    });
    _saveComponentPositions();
  }

  Future<void> _loadComponentPositions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionsJson = prefs.getString('component_positions_graph_overlay_${widget.overlayId}');

      if (positionsJson != null) {
        final positionsMap = jsonDecode(positionsJson) as Map<String, dynamic>;
        setState(() {
          _componentPositions = positionsMap.map((key, value) {
            final offsetList = (value as List<dynamic>).cast<double>();
            return MapEntry(key, Offset(offsetList[0], offsetList[1]));
          });
        });
      } else {
        _initializeDefaultPositions();
      }
    } catch (e) {
      print("Error loading component positions: $e");
      _initializeDefaultPositions();
    }
  }

  Future<void> _saveComponentPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positionsMap = _componentPositions.map((key, value) {
      return MapEntry(key, [value.dx, value.dy]);
    });
    await prefs.setString('component_positions_graph_overlay_${widget.overlayId}', jsonEncode(positionsMap));
  }

  @override
  Widget build(BuildContext context) {
    double graphWidth;
    double graphHeight;
    double fontSize;

    if (widget.overlayId == 'main_dashboard') {
      graphWidth = 60;
      graphHeight = 50;
      fontSize = 7;
    } else {
      graphWidth = 120;
      graphHeight = 100;
      fontSize = 9;
    }

    double horizontalOffset = graphWidth / 2;
    double verticalOffset = graphHeight / 2;

    return Stack(
      children: [
        Consumer<ComponentProvider>(
          builder: (context, componentProvider, child) {
            if (!componentProvider.isMonitoring) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                componentProvider.initializeMonitoring();
              });
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background ALD system diagram
                    Positioned.fill(
                      child: Image.asset(
                        'assets/ald_system_diagram.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Component graphs
                    ...(_componentPositions.entries.map((entry) {
                      final componentName = entry.key;
                      final componentPosition = entry.value;

                      final component = componentProvider.getComponentByName(componentName);
                      if (component == null) {
                        return const SizedBox.shrink();
                      }

                      final parameter = component.primaryParameter;
                      if (parameter == null) {
                        return const SizedBox.shrink();
                      }

                      final left = componentPosition.dx - horizontalOffset;
                      final top = componentPosition.dy - verticalOffset;

                      return Positioned(
                        left: left,
                        top: top,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: _isEditMode
                              ? (details) {
                                  setState(() {
                                    _componentPositions[componentName] = Offset(
                                      _componentPositions[componentName]!.dx + details.delta.dx,
                                      _componentPositions[componentName]!.dy + details.delta.dy,
                                    );
                                  });
                                }
                              : null,
                          onPanEnd: _isEditMode
                              ? (_) {
                                  _saveComponentPositions();
                                }
                              : null,
                          child: Container(
                            width: graphWidth,
                            height: graphHeight,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: componentColors[component.name] ?? Colors.white, width: 1),
                            ),
                            padding: EdgeInsets.all(4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$componentName\n(${parameter.name})',
                                  style: TextStyle(color: Colors.white, fontSize: fontSize),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Expanded(
                                  child: _buildMinimalGraph(component, parameter),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                    // Reset button
                    Positioned(
                      top: 40,
                      right: widget.overlayId == 'main_dashboard' ? 8 : null,
                      left: widget.overlayId != 'main_dashboard' ? 8 : null,
                      child: GestureDetector(
                        onTap: _resetComponentPositions,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.restore,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Positioned(
          top: 8,
          right: widget.overlayId == 'main_dashboard' ? 8 : null,
          left: widget.overlayId != 'main_dashboard' ? 8 : null,
          child: _buildEditModeToggle(),
        ),
      ],
    );
  }

  Widget _buildEditModeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditMode = !_isEditMode;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isEditMode ? Colors.blueAccent : Colors.grey,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8),
        child: Icon(
          _isEditMode ? Icons.lock_open : Icons.lock,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildMinimalGraph(Component component, ComponentParameter parameter) {
    if (parameter.history.isEmpty) {
      return Container(
        color: Colors.black26,
        child: Center(
          child: Text(
            component.isActivated ? 'Waiting...' : 'Inactive',
            style: TextStyle(color: Colors.white, fontSize: 8),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final firstTimestamp = parameter.history.first.timestamp.millisecondsSinceEpoch.toDouble();
    List<FlSpot> spots = parameter.history.map((dp) {
      double x = (dp.timestamp.millisecondsSinceEpoch.toDouble() - firstTimestamp) / 1000;
      double y = dp.value;
      return FlSpot(x, y);
    }).toList();

    double yRange = _calculateYRange(parameter);
    double minY = parameter.setValue != null ? parameter.setValue! - yRange : parameter.minValue;
    double maxY = parameter.setValue != null ? parameter.setValue! + yRange : parameter.maxValue;

    if (maxY - minY < 1) {
      minY = minY - 1;
      maxY = maxY + 1;
    }

    double maxX = spots.isNotEmpty ? spots.last.x : 60;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: componentColors[component.name] ?? Colors.white,
            barWidth: 2,
            dotData: FlDotData(show: false),
          ),
          if (parameter.setValue != null)
            LineChartBarData(
              spots: [
                FlSpot(0, parameter.setValue!),
                FlSpot(maxX, parameter.setValue!),
              ],
              isCurved: false,
              color: Colors.grey,
              barWidth: 1,
              dotData: FlDotData(show: false),
              dashArray: [5, 5],
            ),
        ],
        titlesData: FlTitlesData(
          show: false,
        ),
        gridData: FlGridData(
          show: false,
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineTouchData: LineTouchData(
          enabled: false,
        ),
      ),
    );
  }

  double _calculateYRange(ComponentParameter parameter) {
    if (parameter.history.isEmpty) {
      return 1.0;
    }

    double maxY = parameter.history.map((dp) => dp.value).reduce(max);
    double minY = parameter.history.map((dp) => dp.value).reduce(min);

    if (parameter.setValue != null) {
      maxY = max(maxY, parameter.setValue! + 1);
      minY = min(minY, parameter.setValue! - 1);
    }

    if (maxY - minY < 2.0) {
      maxY += 1.0;
      minY -= 1.0;
    }

    return (maxY - minY) / 2;
  }
}