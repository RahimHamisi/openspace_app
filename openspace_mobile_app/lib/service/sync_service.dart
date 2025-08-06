// lib/services/sync_service.dart
import 'package:workmanager/workmanager.dart';


class SyncService {
  final NetworkService networkService = NetworkService();

  void initialize() {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }

  void scheduleSync() {
    Workmanager().registerOneOffTask('syncTask', 'syncData', constraints: WorkmanagerConstraint(networkType: NetworkType.connected));
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final networkService = NetworkService();
    await networkService.syncActions();
    await networkService.fetchOpenSpaces();
    await networkService.fetchReports();
    await networkService.fetchBookings();
    return Future.value(true);
  });
}