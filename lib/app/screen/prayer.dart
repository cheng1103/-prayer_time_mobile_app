import 'dart:async';
import 'dart:ui';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/prayer_recitations.dart';
import 'package:prayer_time_mobile_app/app/model/prayer_status.dart';
import 'package:prayer_time_mobile_app/app/provider/prayer_provider.dart';
import 'package:provider/provider.dart';

class PrayerScreen extends StatefulWidget {
  final String currentPrayer;

  const PrayerScreen({
    super.key,
    required this.currentPrayer,
  });

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with WidgetsBindingObserver {
  bool prayerStarted = false;
  bool prayerCompleted = false;
  bool prayerDisqualified = false;
  int exitCount = 0;
  Timer? prayerTimer;
  Timer? countdownTimer;
  int remainingSeconds = 300;
  final Duration requiredPrayerTime = const Duration(minutes: 5);
  Coordinates? coordinates;

  // List of valid prayer names
  final List<String> validPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPrayerStatus();
  }

  void _loadPrayerStatus() {
    Provider.of<PrayerProvider>(context, listen: false).fetchPrayerStatuses();
  }

  void startPrayerSession() {
    setState(() {
      prayerStarted = true;
      exitCount = 0;
      remainingSeconds = 300;
    });

    _restartPrayerTimer();
  }

  void _restartPrayerTimer() {
    if (prayerTimer != null && prayerTimer!.isActive) {
      prayerTimer?.cancel();
    }

    prayerTimer = Timer(requiredPrayerTime, () {
      if (mounted) {
        setState(() {
          prayerCompleted = true;
          prayerStarted = false;
        });
        Provider.of<PrayerProvider>(context, listen: false).savePrayerStatus(
          prayerName: widget.currentPrayer,
          status: 'success',
        );
        _showStatusDialog("✅ Prayer Completed");
      }
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        timer.cancel();
      } else if (mounted) {
        setState(() {
          remainingSeconds -= 1;
        });
      }
    });
  }

  void _showStatusDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Prayer Status"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Warning"),
        content: Text(
            "You’ve left the screen $exitCount times.\nLeave 3 times = absent."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _restartPrayerTimer();
            },
            child: const Text("Continue Prayer"),
          ),
        ],
      ),
    );
  }

  void _markAsAbsent(String reason, String status) {
    prayerTimer?.cancel();
    if (mounted) {
      setState(() {
        prayerStarted = false;
        prayerCompleted = false;
        prayerDisqualified = true;
      });
      Provider.of<PrayerProvider>(context, listen: false).savePrayerStatus(
        prayerName: widget.currentPrayer,
        status: status,
      );
      _showStatusDialog("❌ Absent: $reason");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!prayerStarted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      exitCount += 1;
      if (exitCount >= 3) {
        _markAsAbsent("You left the screen too many times.", 'absent');
      } else {
        _showExitWarningDialog();
      }
    }

    if (state == AppLifecycleState.detached) {
      _markAsAbsent("App was closed during prayer.", 'absent');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    prayerTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, provider, child) {
        String currentDate = DateTime.now().toIso8601String().split('T').first;
        PrayerStatus? prayerStatus = provider.prayerStatuses.firstWhere(
          (status) => status.date == currentDate,
          orElse: () => PrayerStatus(
            date: currentDate,
            fajr: 'pending',
            dhuhr: 'pending',
            asr: 'pending',
            maghrib: 'pending',
            isha: 'pending',
          ),
        );

        Map<String, String> prayerMap = {
          'Fajr': prayerStatus.fajr,
          'Dhuhr': prayerStatus.dhuhr,
          'Asr': prayerStatus.asr,
          'Maghrib': prayerStatus.maghrib,
          'Isha': prayerStatus.isha,
        };

        // Check if currentPrayer is valid
        bool isValidPrayer = validPrayers.contains(widget.currentPrayer);
        prayerDisqualified =
            isValidPrayer ? prayerMap[widget.currentPrayer] == 'absent' : false;
        prayerCompleted = isValidPrayer
            ? prayerMap[widget.currentPrayer] == 'success'
            : false;

        return WillPopScope(
          onWillPop: () async {
            if (prayerStarted) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Leave Prayer?"),
                  content:
                      const Text("You'll be marked absent if you stop now."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Leave"),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                _markAsAbsent("You left during prayer.", 'absent');
              }
              return confirm ?? false;
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(title: const Text("Prayer Tracker")),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/mosque.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: prayerStarted
                        ? SizedBox(
                            width: 400,
                            height: 380,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.self_improvement,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Prayer in progress...",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.alarm,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          formatTime(remainingSeconds),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                PrayerRecitations(
                                    currentPrayer: widget.currentPrayer),
                                const SizedBox(height: 10),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Current Prayer: ${widget.currentPrayer.isNotEmpty ? widget.currentPrayer : "None"}",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isValidPrayer
                                    ? !prayerDisqualified
                                        ? prayerCompleted
                                            ? "🟢 You had done prayer"
                                            : "🟢 You can pray now"
                                        : "🔴 You had skip the prayer session"
                                    : "🔴 No prayer session available",
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              if (isValidPrayer &&
                                  !prayerDisqualified &&
                                  !prayerCompleted)
                                ElevatedButton(
                                  onPressed: startPrayerSession,
                                  child: const Text("Start Prayer"),
                                ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
