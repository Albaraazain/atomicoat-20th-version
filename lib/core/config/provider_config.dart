import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/services/auth_service.dart';
import '../../features/components/providers/component_provider.dart';

class ProviderConfig {
  static final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
    ChangeNotifierProvider(create: (_) => ComponentProvider()),
  ];
}
