import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';

import '../../mock/auth_mocks.mocks.dart';
void main() {
  group('AuthenticationPage', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createAuthenticationPage() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          home: AuthenticationPage(),
        ),
      );
    }

    testWidgets('should display generic error message for other exceptions during sign-in', (tester) async {
      // Arrange
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
      when(mockAuthRepository.signInWithGoogle()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createAuthenticationPage());
      await tester.pumpAndSettle(); // Wait for all animations and rebuilds

      // Act: Tap sign-in button
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle(); // Wait for all animations and rebuilds

      // Assert: Verify snackbar message
      expect(find.textContaining('Sign-in failed: Exception: Network error'), findsOneWidget);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull); // Should not be disabled for generic errors
    });
  });
}