import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/services/services.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/routes/app_routes.dart';

class UserTimerScreen extends StatefulWidget {
  const UserTimerScreen({super.key});

  @override
  State<UserTimerScreen> createState() => _UserTimerWidgetState();
}

class _UserTimerWidgetState extends State<UserTimerScreen> {
  SessionTimer? _sessionTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final userProvider = context.read<UserProvider>();
      final progressProvider = context.read<ProgressProvider>();
      final user = userProvider.user;

      if (user != null) {
        setState(() {
          _sessionTimer = SessionTimer(
            workInterval: user.workInterval ?? 25,
            breakInterval: user.breakInterval ?? 5,
            progressProvider: progressProvider,
            onTick: () {
              if (mounted) setState(() {});
            },
            onSessionEnd: (sessionId) async {
              if (!mounted) return;
              setState(() {}); 
              await Navigator.of(context).pushNamed(
                AppRoutes.moodTracker,
                arguments: sessionId,
              );
            },
            onBreakEnd: () {
              if (mounted) setState(() {});
            },
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = _sessionTimer;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    final totalSeconds = session.currentIntervalSeconds;
    final remainingSeconds = totalSeconds - session.elapsedSeconds;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final formattedTime =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Focus Timer", style: theme.appBarTheme.titleTextStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.appBarTheme.iconTheme,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Log Distraction',
            icon: Icon(
              Pixel.edit,
              color: theme.appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.distractionLog);
            },
          ),
          InfoIcon(
            icon: Pixel.infobox,
            dialogTitle: "Focus Session Controls",
            dialogContentText:
                "Skip Break: Skips current break\n\nPause/Resume: Pause or resume timer\n\nCancel: Cancel current session",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              session.isWorkInterval ? 'Work Session' : 'Break',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: session.elapsedSeconds / session.currentIntervalSeconds,
                    strokeWidth: 18,
                    backgroundColor: theme.brightness == Brightness.light
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(session.isWorkInterval
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  formattedTime,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Pixel.forward,
                              color: session.isWorkInterval
                                  ? Colors.grey
                                  : theme.colorScheme.primary,
                            ),
                            tooltip: 'Skip Break',
                            iconSize: 28,
                            onPressed: session.isWorkInterval
                                ? null
                                : () {
                                    session.skipBreak();
                                  },
                          ),
                          Text(
                            'Skip',
                            style: TextStyle(
                              fontSize: 12,
                              color: session.isWorkInterval
                                  ? Colors.grey
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Pixel.close, color: theme.colorScheme.error),
                            tooltip: 'Cancel Session',
                            iconSize: 28,
                            onPressed: () {
                              setState(() {
                                session.cancel();
                              });
                              CustomSnackBar.show(
                                context,
                                message: "Session cancelled.",
                                type: SnackBarType.info,
                                position: SnackBarPosition.top,
                              );
                            },
                          ),
                          Text('Cancel',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        session.isRunning ? Pixel.pause : Pixel.play,
                      ),
                      label: Text(
                        session.isRunning
                            ? "Pause"
                            : (session.elapsedSeconds == 0 ? "Start" : "Resume"),
                      ),
                      onPressed: () {
                        setState(() {
                          if (session.isRunning) {
                            session.pause();
                          } else {
                            session.start();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
