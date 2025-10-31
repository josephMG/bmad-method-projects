import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
}

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  return Connectivity().onConnectivityChanged.map((connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      return ConnectivityStatus.disconnected;
    } else {
      return ConnectivityStatus.connected;
    }
  });
});