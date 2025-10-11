import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:family_expense_tracker/main.dart';
import 'package:family_expense_tracker/presentation/pages/authentication_page.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';

import 'widget_test.mocks.dart';

// Generate a mock for the AuthRepository
@GenerateMocks([AuthRepository])
void main() {
  // Use the generated mock class
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
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

  testWidgets('Shows Welcome message and Sign Out button when user is logged in', (WidgetTester tester) async {
    // ARRANGE
    final mockUser = User(id: '123', email: 'test@test.com', displayName: 'Test User');
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => mockUser);

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
    expect(find.byKey(const Key('welcome_message')), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });
}
