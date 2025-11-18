import 'dart:async'; // For the async Future in the dummy callback
import 'package:flutter_test/flutter_test.dart'; // For test, setUp, expect
import 'package:fake_async/fake_async.dart'; // For fakeAsync
import 'package:mocktail/mocktail.dart'; // For Mock, when, verify, any
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/services/session_timer.dart';

class MockProgressProvider extends Mock implements ProgressProvider {}

void main() {
  late SessionTimer sessionTimer;
  late MockProgressProvider mockProgressProvider;

  void dummyOnTick() {}
  Future<void> dummyOnSessionEnd(String id) async {}
  void dummyOnBreakEnd() {}

  setUp(() {
    mockProgressProvider = MockProgressProvider();

    when(
      () => mockProgressProvider.endSession(any()),
    ).thenAnswer((_) async => 'session-123');

    sessionTimer = SessionTimer(
      workInterval: 25,
      breakInterval: 5,
      progressProvider: mockProgressProvider,
      onTick: dummyOnTick,
      onSessionEnd: dummyOnSessionEnd,
      onBreakEnd: dummyOnBreakEnd,
    );
  });

  test('Initial state should be idle', () {
    expect(sessionTimer.state, SessionState.idle);
    expect(sessionTimer.isWorkInterval, isTrue);
    expect(sessionTimer.elapsedSeconds, 0);
  });

  test('start() should change state to running and start timer', () {
    fakeAsync((async) {
      sessionTimer.start();
      expect(sessionTimer.state, SessionState.running);

      async.elapse(Duration(seconds: 10));
      expect(sessionTimer.elapsedSeconds, 10);
    });
  });

  test('Work session end should call progressProvider and switch to break', () {
    fakeAsync((async) {
      sessionTimer.start();

      async.elapse(Duration(minutes: 25));

      verify(() => mockProgressProvider.endSession(25 * 60)).called(1);

      expect(sessionTimer.isWorkInterval, isFalse);
      expect(sessionTimer.state, SessionState.running);
      expect(sessionTimer.elapsedSeconds, 0);
    });
  });
}
