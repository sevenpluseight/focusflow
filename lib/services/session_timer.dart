import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:focusflow/providers/progress_provider.dart';

enum SessionState { idle, running, paused }

class SessionTimer {
  final int workInterval; // in minutes
  final int breakInterval; // in minutes
  final ProgressProvider progressProvider;

  final VoidCallback onTick;
  final VoidCallback onSessionEnd;
  final VoidCallback onBreakEnd;

  Timer? _timer;
  int elapsedSeconds = 0;
  bool isWorkInterval = true;
  SessionState state = SessionState.idle;

  SessionTimer({
    required this.workInterval,
    required this.breakInterval,
    required this.progressProvider,
    required this.onTick,
    required this.onSessionEnd,
    required this.onBreakEnd,
  });

  int get currentIntervalSeconds =>
      (isWorkInterval ? workInterval : breakInterval) * 60;

  bool get isRunning => state == SessionState.running;

  void start() {
    if (state == SessionState.running) return;

    state = SessionState.running;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (state != SessionState.running) return;

    state = SessionState.paused;
    _timer?.cancel();
  }

  void resume() {
    if (state != SessionState.paused) return;

    start();
  }

  void cancel() {
    state = SessionState.idle;
    _timer?.cancel();
    elapsedSeconds = 0;
    isWorkInterval = true;
  }

  void skipBreak() {
    if (!isWorkInterval) {
      _endBreak();
    }
  }

  void _tick() {
    if (state != SessionState.running) {
      return;
    }
    elapsedSeconds += 1;
    onTick();

    if (elapsedSeconds >= currentIntervalSeconds) {
      if (isWorkInterval) {
        _endWork();
      } else {
        _endBreak();
      }
    }
  }

  void _endWork() async {
    state = SessionState.idle;
    isWorkInterval = false;
    elapsedSeconds = 0;

    // Update ProgressProvider
    await progressProvider.endSession(workInterval * 60);

    onSessionEnd();
    start();
  }

  void _endBreak() {
    state = SessionState.idle;
    isWorkInterval = true;
    elapsedSeconds = 0;

    onBreakEnd();
    start();
  }

  void dispose() {
    _timer?.cancel();
  }
}
