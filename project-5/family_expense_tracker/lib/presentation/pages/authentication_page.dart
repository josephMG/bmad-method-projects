import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

// Provider for the current user
final userProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return Stream.fromFuture(authRepository.getCurrentUser());
});

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userAsyncValue = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Expense Tracker'),
      ),
      body: Center(
        child: userAsyncValue.when(
          data: (user) {
            debugPrint('AuthenticationPage: userAsyncValue.when - data: user = $user');
            if (user == null) {
              debugPrint('AuthenticationPage: User is null, showing Sign in button.');
              return ElevatedButton(
                onPressed: () async {
                  await authRepository.signInWithGoogle();
                  ref.invalidate(userProvider); // Refresh user state
                },
                child: const Text('Sign in with Google'),
              );
            } else {
              debugPrint('AuthenticationPage: User is not null, showing Sign Out button. User email: ${user.email}');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    radius: 40,
                  ),
                  const SizedBox(height: 16),
                  Text('Welcome, ${user.displayName ?? user.email}!', key: const Key('welcome_message')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await authRepository.signOut();
                      ref.invalidate(userProvider); // Refresh user state
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            }
          },
          loading: () {
            debugPrint('AuthenticationPage: userAsyncValue.when - loading');
            return const CircularProgressIndicator();
          },
          error: (error, stack) {
            debugPrint('AuthenticationPage: userAsyncValue.when - error: $error');
            return Text('Error: $error');
          },
        ),
      ),
    );
  }
}
