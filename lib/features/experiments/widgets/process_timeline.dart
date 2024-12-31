// lib/features/dashboard/widgets/experiment/process_timeline.dart

import 'package:flutter/material.dart';

class ProcessTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hardcoded timeline data for UI demonstration
    final timelineItems = [
      _TimelineItem(
        title: 'Process Started',
        time: '14:30:00',
        description: 'Initial chamber preparation',
        status: TimelineStatus.completed,
        isFirst: true,
      ),
      _TimelineItem(
        title: 'Precursor A Pulse',
        time: '14:30:15',
        description: 'TiCl4 exposure for 2.0s',
        status: TimelineStatus.completed,
      ),
      _TimelineItem(
        title: 'Purge Step',
        time: '14:30:20',
        description: 'N2 purge for 5.0s',
        status: TimelineStatus.completed,
      ),
      _TimelineItem(
        title: 'Precursor B Pulse',
        time: '14:30:25',
        description: 'H2O exposure for 1.5s',
        status: TimelineStatus.inProgress,
      ),
      _TimelineItem(
        title: 'Final Purge',
        time: '14:30:30',
        description: 'Waiting for purge completion',
        status: TimelineStatus.pending,
        isLast: true,
      ),
    ];

    return Column(
      children: timelineItems.map((item) => _buildTimelineItem(item)).toList(),
    );
  }

  Widget _buildTimelineItem(_TimelineItem item) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(item),
          Expanded(child: _buildTimelineContent(item)),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(_TimelineItem item) {
    return SizedBox(
      width: 60,
      child: Column(
        children: [
          _buildIndicatorDot(item.status),
          if (!item.isLast)
            Expanded(
              child: Container(
                width: 2,
                color: _getTimelineColor(
                  item.status == TimelineStatus.completed
                      ? TimelineStatus.completed
                      : TimelineStatus.pending,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(TimelineStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case TimelineStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case TimelineStatus.inProgress:
        icon = Icons.timelapse;
        color = Colors.blue;
        break;
      case TimelineStatus.pending:
        icon = Icons.circle_outlined;
        color = Colors.grey;
        break;
      case TimelineStatus.error:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildTimelineContent(_TimelineItem item) {
    return Card(
      color: Color(0xFF2A2A2A),
      margin: EdgeInsets.only(left: 8, right: 16, bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.time,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimelineColor(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.completed:
        return Colors.green;
      case TimelineStatus.inProgress:
        return Colors.blue;
      case TimelineStatus.pending:
        return Colors.grey;
      case TimelineStatus.error:
        return Colors.red;
    }
  }
}

class _TimelineItem {
  final String title;
  final String time;
  final String description;
  final TimelineStatus status;
  final bool isFirst;
  final bool isLast;

  _TimelineItem({
    required this.title,
    required this.time,
    required this.description,
    required this.status,
    this.isFirst = false,
    this.isLast = false,
  });
}

enum TimelineStatus {
  completed,
  inProgress,
  pending,
  error,
}