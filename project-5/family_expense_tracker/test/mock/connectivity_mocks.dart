import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockConnectivityPlatform extends Mock implements ConnectivityPlatform {
  // Mock the method channel to prevent MissingPluginException
  static void setMockConnectivityPlatform() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity_status');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'listen') {
        return null; // Or return a stream of ConnectivityResult if needed for specific test cases
      }
      return null;
    });
  }
}