import 'package:flutter_riverpod/flutter_riverpod.dart';

class RateLimitState {
  final bool isRateLimited;
  final DateTime? cooldownUntil;
  final String? message;

  RateLimitState({
    this.isRateLimited = false,
    this.cooldownUntil,
    this.message,
  });

  RateLimitState copyWith({
    bool? isRateLimited,
    DateTime? cooldownUntil,
    String? message,
  }) {
    return RateLimitState(
      isRateLimited: isRateLimited ?? this.isRateLimited,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
      message: message ?? this.message,
    );
  }

  Duration? get cooldownRemaining {
    if (cooldownUntil == null) return null;
    final remaining = cooldownUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class RateLimitNotifier extends StateNotifier<RateLimitState> {
  RateLimitNotifier() : super(RateLimitState());

  void setRateLimited(Duration cooldown, String message) {
    state = state.copyWith(
      isRateLimited: true,
      cooldownUntil: DateTime.now().add(cooldown),
      message: message,
    );
    _startCooldownTimer(cooldown);
  }

  void clearRateLimited() {
    state = state.copyWith(
      isRateLimited: false,
      cooldownUntil: null,
      message: null,
    );
  }

  void _startCooldownTimer(Duration cooldown) {
    Future.delayed(cooldown, () {
      if (state.isRateLimited && state.cooldownUntil != null && DateTime.now().isAfter(state.cooldownUntil!)) {
        clearRateLimited();
      }
    });
  }
}

final rateLimitStateProvider = StateNotifierProvider<RateLimitNotifier, RateLimitState>(
  (ref) => RateLimitNotifier(),
);
