import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart' show AuthRepository, authRepositoryProvider, User;
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart' show AuthenticationPage, userProvider;
import 'package:google_sign_in/google_sign_in.dart';

// Import the generated mocks from widget_test.mocks.dart
import '../mock/auth_mocks.mocks.dart';
import '../mock/connectivity_mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;
  late MockGoogleSignIn mockGoogleSignIn;
  User? _currentUser; // To simulate the current user state

  setUp(() {
    MockConnectivityPlatform.setMockConnectivityPlatform();
    mockAuthRepository = MockAuthRepository();
    mockGoogleSignIn = MockGoogleSignIn();
    _currentUser = null; // Reset current user for each test

    when(mockAuthRepository.getGoogleSignInInstance()).thenAnswer((_) => mockGoogleSignIn);
    when(mockGoogleSignIn.onCurrentUserChanged).thenAnswer((_) => Stream.value(null));
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

    // Mock getCurrentUser to return the current user state
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => _currentUser);
  });

  group('Google OAuth Integration Tests', () {
    testWidgets('User can sign in and sign out', (WidgetTester tester) async {
      // ARRANGE: Initial state (not signed in)
      _currentUser = null; // Ensure initial state is null

      // ACT: Build the app with the mocked repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MyApp(),
        )
      );
      await tester.pumpAndSettle(); // Initial pump

      // ASSERT: Verify sign-in button is shown and ExpenseListPage is not
      expect(find.byKey(const Key('signInButton')), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsNothing);

      // ARRANGE: Mock successful sign-in
      final mockUser = User(
          id: '123', email: 'test@test.com', displayName: 'Test User');
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async {
        _currentUser = mockUser; // Update current user state
        return mockUser;
      });

      // ACT: Tap the sign-in button
      await tester.tap(find.byKey(const Key('signInButton')));
      await tester
          .pumpAndSettle(); // Wait for sign-in action and provider invalidation
      await tester.pumpAndSettle(); // Wait for navigation to ExpenseListPage

      // ASSERT: Verify navigation to ExpenseListPage
      expect(find.byType(ExpenseListPage),
          findsOneWidget); // Explicitly check for ExpenseListPage
      expect(find.text('Monthly Expenses'), findsOneWidget);
      expect(find.byKey(const Key('signInButton')), findsNothing);

      // ARRANGE: Mock sign-out
      when(mockAuthRepository.signOut()).thenAnswer((_) async {
        _currentUser = null; // Update current user state
      });

      // ACT: Tap the sign-out button on ExpenseListPage
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester
          .pumpAndSettle(); // Wait for logout action and provider invalidation
      await tester
          .pumpAndSettle(); // Wait for navigation back to AuthenticationPage

      // ASSERT: Verify UI returns to sign-in state on AuthenticationPage
      expect(find.byType(AuthenticationPage),
          findsOneWidget); // Explicitly check for AuthenticationPage
      expect(find.byKey(const Key('signInButton')), findsOneWidget);
      expect(find.text('Monthly Expenses'), findsNothing);
      verify(mockAuthRepository.signOut()).called(1);
    });
  });
}
