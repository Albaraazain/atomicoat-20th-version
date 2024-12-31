import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/overlays/components_overlay.dart';
import '../widgets/overlays/graph_overlay.dart';
import '../../../features/components/providers/component_provider.dart';

class SystemOverviewScreen extends StatefulWidget {
  @override
  _SystemOverviewScreenState createState() => _SystemOverviewScreenState();
}

class _SystemOverviewScreenState extends State<SystemOverviewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset to default orientation when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF2A2A2A),
        title: Text('System Overview'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _buildOverlayIndicator(),
        ],
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ComponentProvider()),
        ],
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            ComponentsOverlay(),
            GraphOverlay(overlayId: 'system_overview'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentPage == 0 ? 'Components' : 'Graphs',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}