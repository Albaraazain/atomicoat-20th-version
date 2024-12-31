// lib/features/dashboard/widgets/tabs/process_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/process_provider.dart';
import '../../providers/recipe_provider.dart';
import '../process/parameter_trend_chart.dart';
import '../process/recipe_progress_panel.dart';
import '../process/process_control_panel.dart';

class ProcessTab extends StatefulWidget {
  @override
  _ProcessTabState createState() => _ProcessTabState();
}

class _ProcessTabState extends State<ProcessTab> {
  // We'll track which parameters the operator wants to monitor closely
  final Set<String> _selectedParameters = {};

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProcessProvider, RecipeProvider>(
      builder: (context, processProvider, recipeProvider, _) {
        // The layout adapts based on whether a process is running
        return Column(
          children: [
            _buildProcessHeader(processProvider),
            Expanded(
              child: _buildProcessContent(
                processProvider,
                recipeProvider,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProcessHeader(ProcessProvider processProvider) {
    // The header shows the current process status and basic information
    return Container(
      padding: EdgeInsets.all(16),
      color: Color(0xFF2A2A2A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusIndicator(processProvider.processStatus),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      processProvider.currentRecipe?.name ?? 'No Recipe Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (processProvider.isProcessing) ...[
                      SizedBox(height: 4),
                      Text(
                        'Started: ${_formatDateTime(processProvider.processStartTime!)}',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (processProvider.isProcessing)
            _buildProgressIndicator(processProvider),
        ],
      ),
    );
  }

  Widget _buildProcessContent(
    ProcessProvider processProvider,
    RecipeProvider recipeProvider,
  ) {
    // The content area changes based on the process state
    if (!processProvider.isProcessing) {
      return _buildRecipeSelection(recipeProvider);
    }

    return Row(
      children: [
        // Left side: Recipe progress and controls
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Expanded(
                child: RecipeProgressPanel(
                  recipe: processProvider.currentRecipe!,
                  currentStep: processProvider.currentStep,
                  completedSteps: processProvider.completedSteps,
                ),
              ),
              ProcessControlPanel(
                onPause: processProvider.pauseProcess,
                onResume: processProvider.resumeProcess,
                onAbort: () => _showAbortConfirmation(context),
              ),
            ],
          ),
        ),
        // Right side: Parameter monitoring
        Expanded(
          flex: 4,
          child: _buildParameterMonitoring(processProvider),
        ),
      ],
    );
  }

  Widget _buildParameterMonitoring(ProcessProvider processProvider) {
    // This section shows real-time parameter trends
    return Column(
      children: [
        _buildParameterSelector(processProvider),
        Expanded(
          child: _selectedParameters.isEmpty
              ? _buildParameterSelectionPrompt()
              : _buildParameterCharts(processProvider),
        ),
      ],
    );
  }

  Widget _buildParameterCharts(ProcessProvider processProvider) {
    // Create a scrollable list of parameter trend charts
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _selectedParameters.length,
      itemBuilder: (context, index) {
        final parameter = _selectedParameters.elementAt(index);
        return Card(
          color: Color(0xFF2A2A2A),
          margin: EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      parameter,
                      style: TextStyle(color: Colors.white),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          _selectedParameters.remove(parameter);
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ParameterTrendChart(
                  parameter: parameter,
                  data: processProvider.getParameterHistory(parameter),
                  setPoint: processProvider.getParameterSetPoint(parameter),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeSelection(RecipeProvider recipeProvider) {
    // The recipe selection interface when no process is running
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select a Recipe to Begin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          Container(
            width: 300,
            child: DropdownButtonFormField<String>(
              value: recipeProvider.selectedRecipe?.id,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: recipeProvider.availableRecipes
                  .map((recipe) => DropdownMenuItem(
                        value: recipe.id,
                        child: Text(recipe.name),
                      ))
                  .toList(),
              onChanged: (recipeId) {
                if (recipeId != null) {
                  recipeProvider.selectRecipe(recipeId);
                }
              },
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('Start Process'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            onPressed: recipeProvider.selectedRecipe != null
                ? () => _startProcess(context)
                : null,
          ),
        ],
      ),
    );
  }
}



/*
This Process Tab implementation offers several important features:

Process Status and Control

Clear indication of current process status
Real-time progress tracking
Easy access to process controls (pause, resume, abort)


Recipe Execution

Step-by-step visualization of recipe progress
Clear indication of completed and current steps
Estimated time remaining


Parameter Monitoring

Customizable parameter selection
Real-time trend charts
Set point visualization
Historical data view
The Process Tab is a key component of the machine dashboard, providing operators with the information and controls they need to manage ongoing processes effectively.
*/