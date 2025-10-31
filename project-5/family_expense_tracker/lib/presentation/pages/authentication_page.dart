import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family_expense_tracker/features/authentication/data/auth_repository.dart';
import 'package:family_expense_tracker/core/providers/rate_limit_provider.dart';
import 'package:family_expense_tracker/core/widgets/custom_snackbar.dart';
import 'package:family_expense_tracker/core/errors/app_exceptions.dart';
import 'package:family_expense_tracker/presentation/pages/expense_list_page.dart';

// Provider for the current user
final userProvider = StreamProvider<User?>((ref) async* {
  final authRepository = ref.watch(authRepositoryProvider);
  final rateLimitNotifier = ref.read(rateLimitStateProvider.notifier);

  try {
    yield await authRepository.getCurrentUser();
  } on RateLimitException catch (e) {
    rateLimitNotifier.setRateLimited(const Duration(seconds: 60), e.message);
    yield null; // Or yield the last known user state
  } catch (e) {
    // Handle other exceptions if necessary
    yield null;
  }
});

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    final userAsyncValue = ref.watch(userProvider);
    final rateLimitState = ref.watch(rateLimitStateProvider);

    // Show snackbar if rate limited
    if (rateLimitState.isRateLimited && rateLimitState.message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final remainingTime = rateLimitState.cooldownUntil != null
            ? ' (retry after ${rateLimitState.cooldownUntil!.toLocal().hour}:${rateLimitState.cooldownUntil!.toLocal().minute}:${rateLimitState.cooldownUntil!.toLocal().second})'
            : '';
        CustomSnackBar.instance.show(context, '${rateLimitState.message!}$remainingTime');
      });
    }

    final bool isAuthActionDisabled = rateLimitState.isRateLimited;

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
                key: const Key('signInButton'),
                onPressed: isAuthActionDisabled ? null : () async {
                  try {
                    await authRepository.signInWithGoogle();
                    if (!context.mounted) return; // Check if the widget is still mounted
                    ref.invalidate(userProvider); // Refresh user state
                    debugPrint('AuthenticationPage: userProvider invalidated after sign-in.');
                  } on RateLimitException catch (e) {
                    ref.read(rateLimitStateProvider.notifier).setRateLimited(const Duration(seconds: 60), e.message);
                  } catch (e) {
                    if (!context.mounted) return; // Check if the widget is still mounted
                    CustomSnackBar.instance.show(context, 'Sign-in failed: ${e.toString()}');
                  }
                },
                child: const Text('Sign in with Google'),
              );
            } else {
              debugPrint('AuthenticationPage: User is not null, navigating to ExpenseListPage.');
              // Navigate to ExpenseListPage after successful sign-in
              debugPrint('AuthenticationPage: Navigating to ExpenseListPage.');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ExpenseListPage()));
              });
              return const SizedBox.shrink(); // Return an empty widget while navigating
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
