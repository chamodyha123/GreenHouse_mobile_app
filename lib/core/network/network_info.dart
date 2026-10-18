import '../services/connectivity_service.dart';
import '../services/connectivity_stub.dart'
    if (dart.library.io) '../services/connectivity_io.dart'
    if (dart.library.html) '../services/connectivity_web.dart' as platform;

/// Abstract class for network information
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

/// Implementation using ConnectivityService
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required ConnectivityService connectivityService})
      : _connectivityService = connectivityService;
  final ConnectivityService _connectivityService;

  @override
  Future<bool> get isConnected async => _connectivityService.isOnline;

  @override
  Stream<bool> get onConnectivityChanged => platform.onConnectivityChanged();
}
