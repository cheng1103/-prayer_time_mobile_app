import 'dart:async';

class CountdownService {
  Timer? _timer;

  // Start the countdown for the next prayer
  void startCountdown(DateTime prayerTime, Function(String, bool) onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = prayerTime.difference(now);

      if (difference.isNegative) {
        onTick('Prayer time has passed', false);
        _timer?.cancel();
        return;
      }

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      // Change color if less than 30 minutes remaining
      final isUrgent = difference.inMinutes <= 30;
      final countdown = 'Upcoming Prayer in: ${hours}h ${minutes}m ${seconds}s';
      onTick(countdown, isUrgent);
    });
  }

  // Stop the countdown
  void stopCountdown() {
    _timer?.cancel();
  }
}
