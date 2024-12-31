import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/navigation_service.dart';
import 'theme_config.dart';
import 'route_config.dart';
import 'provider_config.dart';

class AppConfig {
  final ThemeConfig themeConfig;
  final RouteConfig routeConfig;
  final ProviderConfig providerConfig;
  final NavigationService navigationService;

  AppConfig({
    required this.themeConfig,
    required this.routeConfig,
    required this.providerConfig,
    required this.navigationService,
  });

  static AppConfig of(BuildContext context) {
    return Provider.of<AppConfig>(context, listen: false);
  }
}
