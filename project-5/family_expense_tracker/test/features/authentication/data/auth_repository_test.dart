import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';

import 'auth_repository_test.mocks.dart';

// Generate mocks for the classes we need
@GenerateMocks([GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockGoogleSignIn mockGoogleSignIn;

    // Store for mocked secure storage values
    final Map<String, String> _mockSecureStorageData = {};

    // This setup mocks the platform channel for flutter_secure_storage
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              return _mockSecureStorageData[methodCall.arguments['key']];
            case 'write':
              _mockSecureStorageData[methodCall.arguments['key']] =
                  methodCall.arguments['value'];
              return null;
            case 'delete':
              _mockSecureStorageData.remove(methodCall.arguments['key']);
              return null;
            case 'deleteAll':
              _mockSecureStorageData.clear();
              return null;
            default:
              return null;
          }
        },
      );
    });

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      authRepository = AuthRepository(
        googleSignIn: mockGoogleSignIn,
      );
      _mockSecureStorageData.clear(); // Clear mock data for each test
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), null);
    });

    // Helper to mock a successful Google Sign-In flow
    void mockSignInSuccess() {
      final mockAuth = MockGoogleSignInAuthentication();
      when(mockAuth.accessToken).thenReturn('test_access_token');
      when(mockAuth.idToken).thenReturn('test_id_token');

      final mockAccount = MockGoogleSignInAccount();
      // Stub all non-nullable getters with valid values
      when(mockAccount.id).thenReturn('test_id');
      when(mockAccount.email).thenReturn('test@example.com');
      when(mockAccount.displayName).thenReturn('Test User');
      when(mockAccount.photoUrl).thenReturn('http://example.com/photo.jpg');
      when(mockAccount.serverAuthCode).thenReturn('test_server_auth_code');
      when(mockAccount.authentication).thenAnswer((_) async => mockAuth);

      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
      when(mockGoogleSignIn.currentUser).thenReturn(mockAccount);
    }

    group('signInWithGoogle', () {
      test('should store tokens securely on successful sign-in', () async {
        mockSignInSuccess();

        final user = await authRepository.signInWithGoogle();

        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');

        // Verify tokens were written to secure storage
        expect(_mockSecureStorageData['access_token'], 'test_access_token');
        expect(_mockSecureStorageData['id_token'], 'test_id_token');
      });

      test('should return null if sign-in is cancelled', () async {
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);
        final user = await authRepository.signInWithGoogle();
        expect(user, isNull);
      });
    });

    group('getAccessToken', () {
      test('should return stored access token if user is not signed in', () async {
        when(mockGoogleSignIn.currentUser).thenReturn(null);
        _mockSecureStorageData['access_token'] = 'stored_access_token';

        final token = await authRepository.getAccessToken();

        expect(token, 'stored_access_token');
      });

      test('should refresh token if current user exists', () async {
        final mockAuth = MockGoogleSignInAuthentication();
        when(mockAuth.accessToken).thenReturn('new_access_token');
        when(mockAuth.idToken).thenReturn('new_id_token');

        final mockAccount = MockGoogleSignInAccount();
        when(mockAccount.authentication).thenAnswer((_) async => mockAuth);
        when(mockGoogleSignIn.currentUser).thenReturn(mockAccount);

        final token = await authRepository.getAccessToken();

        expect(token, 'new_access_token');
        expect(_mockSecureStorageData['access_token'], 'new_access_token');
      });
    });

    group('signOut', () {
      test('should sign out and clear stored tokens', () async {
        _mockSecureStorageData['access_token'] = 'some_token';
        _mockSecureStorageData['id_token'] = 'some_id_token';

        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authRepository.signOut();

        verify(mockGoogleSignIn.signOut()).called(1);
        expect(_mockSecureStorageData.containsKey('access_token'), isFalse);
        expect(_mockSecureStorageData.containsKey('id_token'), isFalse);
      });
    });

    group('getCurrentUser', () {
      test('should return current user if signed in', () async {
        final mockAccount = MockGoogleSignInAccount();
        when(mockAccount.id).thenReturn('test_id');
        when(mockAccount.email).thenReturn('test@example.com');
        when(mockAccount.displayName).thenReturn('Test User');
        when(mockAccount.photoUrl).thenReturn(null);
        when(mockGoogleSignIn.currentUser).thenReturn(mockAccount);

        final user = await authRepository.getCurrentUser();

        expect(user, isNotNull);
        expect(user!.email, 'test@example.com');
      });

      test('should return null if not signed in and no stored tokens', () async {
        when(mockGoogleSignIn.currentUser).thenReturn(null);
        when(mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);

        final user = await authRepository.getCurrentUser();

        expect(user, isNull);
      });
    });
  });
}
