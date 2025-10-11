import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';

// Import the generated mocks from widget_test.dart
import '../widget_test.mocks.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('Google OAuth Integration Tests', () {
    testWidgets('User can sign in and sign out', (WidgetTester tester) async {
      // ARRANGE: Initial state (not signed in)
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      // ACT: Build the app with the mocked repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // ASSERT: Verify sign-in button is shown
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign Out'), findsNothing);

      // ARRANGE: Mock successful sign-in
      final mockUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');
      when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => mockUser);
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);

      // ACT: Tap the sign-in button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      // ASSERT: Verify signed-in UI is shown
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byKey(const Key('welcome_message')), findsOneWidget);
      verify(mockAuthRepository.signInWithGoogle()).called(1);

      // ARRANGE: Mock sign-out
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

      // ACT: Tap the sign-out button
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // ASSERT: Verify UI returns to sign-in state
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign Out'), findsNothing);
      verify(mockAuthRepository.signOut()).called(1);
    });
  });
}
