// lib/features/dashboard/widgets/process/recipe_progress_panel.dart

import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';

class RecipeProgressPanel extends StatelessWidget {
  final Recipe recipe;
  final RecipeStep currentStep;
  final List<RecipeStep> completedSteps;

  // Constructor requires the essential information for tracking progress
  const RecipeProgressPanel({
    Key? key,
    required this.recipe,
    required this.currentStep,
    required this.completedSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate overall progress for the progress indicator
    final progress = completedSteps.length / recipe.steps.length;

    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(progress),
          SizedBox(height: 16),
          Expanded(
            child: _buildStepsList(),
          ),
          _buildTimeRemaining(),
        ],
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipe Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        // Show a linear progress indicator for overall completion
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% Complete',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return ListView.builder(
      itemCount: recipe.steps.length,
      itemBuilder: (context, index) {
        final step = recipe.steps[index];
        final isCompleted = completedSteps.contains(step);
        final isCurrent = currentStep == step;

        return _buildStepTile(
          step: step,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          showConnector: index < recipe.steps.length - 1,
        );
      },
    );
  }

  Widget _buildStepTile({
    required RecipeStep step,
    required bool isCompleted,
    required bool isCurrent,
    required bool showConnector,
  }) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: _getStepBackgroundColor(isCompleted, isCurrent),
            borderRadius: BorderRadius.circular(8),
            border: isCurrent
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: ExpansionTile(
            // The title shows the step name and status
            title: Row(
              children: [
                _buildStepStatusIcon(isCompleted, isCurrent),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        _getStepDescription(step),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  _buildStepProgress(step),
              ],
            ),
            // The expanded content shows step details
            children: [
              _buildStepDetails(step),
            ],
          ),
        ),
        // Visual connector between steps
        if (showConnector)
          Container(
            height: 16,
            width: 2,
            color: isCompleted ? Colors.blue : Colors.white24,
            margin: EdgeInsets.symmetric(vertical: 2),
          ),
      ],
    );
  }

  Widget _buildStepStatusIcon(bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return Icon(Icons.check_circle, color: Colors.green);
    }
    if (isCurrent) {
      return Icon(Icons.play_circle_filled, color: Colors.blue);
    }
    return Icon(Icons.circle_outlined, color: Colors.white54);
  }

  Widget _buildStepProgress(RecipeStep step) {
    // Calculate the progress for the current step
    final stepProgress = _calculateStepProgress(step);

    return Container(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        value: stepProgress,
        backgroundColor: Colors.white10,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        strokeWidth: 4,
      ),
    );
  }

  Widget _buildStepDetails(RecipeStep step) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the step parameters
          ...step.parameters.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _formatParameterValue(entry.value),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }),
          // Show step duration if applicable
          if (step.duration != null) ...[
            Divider(color: Colors.white24),
            Text(
              'Duration: ${_formatDuration(step.duration!)}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRemaining() {
    final remainingTime = _calculateRemainingTime();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white24),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.white70),
          SizedBox(width: 8),
          Text(
            'Estimated Time Remaining:',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(width: 8),
          Text(
            _formatDuration(remainingTime),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations and formatting
  double _calculateStepProgress(RecipeStep step) {
    // Implementation depends on step type and tracking mechanism
    // This is a simplified version
    if (step.duration == null) return 0.0;
    final elapsed = DateTime.now().difference(step.startTime!);
    return (elapsed.inMilliseconds / step.duration!.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Duration _calculateRemainingTime() {
    // Sum up the remaining time for current and future steps
    final remainingSteps = recipe.steps
        .skipWhile((step) => completedSteps.contains(step))
        .toList();

    return remainingSteps.fold(
      Duration.zero,
      (total, step) => total + (step.duration ?? Duration.zero),
    );
  }
}


// This RecipeProgressPanel provides several important features for operators:

// Visual Progress Tracking

// Overall recipe progress indication
// Step-by-step visualization
// Clear status indicators for completed, current, and pending steps
// Visual connectors showing the flow between steps


// Detailed Step Information

// Expandable step details
// Parameter values and setpoints
// Step duration and progress
// Clear indication of the current step


// Time Management

// Estimated time remaining
// Individual step progress tracking
// Clear duration display for each step