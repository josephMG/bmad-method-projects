import 'dart:collection';

import 'package:mockito/mockito.dart';

extension When<T> on PostExpectation<T> {
  void thenAnswerInOrder(List<Answering<T>> answers) {
    if (answers.isEmpty) {
      throw ArgumentError('thenAnswerInOrder answers should not be empty');
    }

    final queue = Queue.of(answers);
    thenAnswer((invocation) {
      if (queue.isEmpty) {
        throw StateError('thenAnswerInOrder does not have enough answers');
      }

      final answering = queue.removeFirst();
      return answering(invocation);
    });
  }
}