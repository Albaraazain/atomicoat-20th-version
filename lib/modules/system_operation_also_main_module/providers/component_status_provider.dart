import 'base_component_provider.dart';
import '../models/system_component.dart';

class ComponentStatusProvider extends BaseComponentProvider {
  Future<void> updateComponentStatus(String componentId, ComponentStatus newStatus, {String? userId}) async {
    if (!validateComponentOperation(componentId, 'update status')) {
      return;
    }

    final component = componentsMap[componentId];
    if (component != null && component.status != newStatus) {
      component.status = newStatus;
      await repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> activateComponent(String componentId, {String? userId}) async {
    final component = componentsMap[componentId];
    if (component != null && !component.isActivated) {
      component.isActivated = true;
      await repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> deactivateComponent(String componentId, {String? userId}) async {
    final component = componentsMap[componentId];
    if (component != null && component.isActivated) {
      component.isActivated = false;
      await repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  bool checkSystemReadiness() {
    return componentsMap.values.every((component) => component.status == ComponentStatus.ok);
  }
}
