import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../mock/auth_mocks.mocks.dart';

// Generate mocks for the classes we need
@GenerateMocks([
  AuthRepository,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthRepository', () {
    late AuthRepository authRepository;
    late MockGoogleSignIn mockGoogleSignIn;

    // Store for mocked secure storage values
    final Map<String, String> mockSecureStorageData = {};

    // This setup mocks the platform channel for flutter_secure_storage
    setUpAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'read':
              return mockSecureStorageData[methodCall.arguments['key']];
            case 'write':
              mockSecureStorageData[methodCall.arguments['key']] =
                  methodCall.arguments['value'];
              return null;
            case 'delete':
              mockSecureStorageData.remove(methodCall.arguments['key']);
              return null;
            case 'deleteAll':
              mockSecureStorageData.clear();
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
      mockSecureStorageData.clear(); // Clear mock data for each test
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
        expect(mockSecureStorageData['access_token'], 'test_access_token');
        expect(mockSecureStorageData['id_token'], 'test_id_token');
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
        mockSecureStorageData['access_token'] = 'stored_access_token';

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
        expect(mockSecureStorageData['access_token'], 'new_access_token');
      });
    });

    group('signOut', () {
      test('should sign out and clear stored tokens', () async {
        mockSecureStorageData['access_token'] = 'some_token';
        mockSecureStorageData['id_token'] = 'some_id_token';

        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authRepository.signOut();

        verify(mockGoogleSignIn.signOut()).called(1);
        expect(mockSecureStorageData.containsKey('access_token'), isFalse);
        expect(mockSecureStorageData.containsKey('id_token'), isFalse);
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

  group('AuthenticationPage Widget Tests', () {
    // Use the generated mock class
    late MockAuthRepository mockAuthRepository;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockGoogleSignIn = MockGoogleSignIn();
      when(mockAuthRepository.getGoogleSignInInstance()).thenAnswer((_) => mockGoogleSignIn);
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) => Stream.value(null));
    });

    testWidgets('Shows Sign In button when user is null', (WidgetTester tester) async {
      // ARRANGE
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      // ACT
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // ASSERT
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign Out'), findsNothing);
    });

    testWidgets('Navigates to ExpenseListPage after sign-in and allows sign-out', (WidgetTester tester) async {
      final mockUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');
      // ARRANGE: Initially, no user is signed in
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async {
        // Simulate successful sign-in by changing the current user
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);
        return mockUser;
      });

      // ACT: Pump the widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // ASSERT: AuthenticationPage should be shown with Sign In button
      expect(find.byType(AuthenticationPage), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byType(ExpenseListPage), findsNothing);

      // ACT: Tap Sign In button
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester.pumpAndSettle(); // Wait for sign-in and navigation

      // ASSERT: Should navigate to ExpenseListPage
      expect(find.byType(ExpenseListPage), findsOneWidget);
      expect(find.byType(AuthenticationPage), findsNothing);

      // ARRANGE: Mock sign-out
      when(mockAuthRepository.signOut()).thenAnswer((_) async => Future.value(null));
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null); // After sign-out, user is null

      // ACT: Tap Sign Out button on ExpenseListPage
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle(); // Wait for logout action and navigation back to AuthenticationPage

      // ASSERT: Should navigate back to AuthenticationPage and show Sign In button
      expect(find.byType(AuthenticationPage), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byType(ExpenseListPage), findsNothing);
    });
  });
}
