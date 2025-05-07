import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:prayer_time_mobile_app/app/component/custom_drawer.dart';
import 'package:prayer_time_mobile_app/app/component/footer_navigation.dart';
import 'package:prayer_time_mobile_app/app/screen/calendar.dart';
import 'package:prayer_time_mobile_app/app/screen/notification_schedule.dart';
import 'package:prayer_time_mobile_app/app/screen/prayer.dart';
import 'package:prayer_time_mobile_app/app/screen/tasbih_counter.dart';
import 'package:prayer_time_mobile_app/services/location_service.dart';
import 'package:prayer_time_mobile_app/services/adhan_service.dart';
import 'package:prayer_time_mobile_app/services/countdown_service.dart';
import 'package:prayer_time_mobile_app/services/hijri_date_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationName = 'Loading...';
  String _nowAdhanName = '';
  String _nextAdhanName = '';
  String _nextAdhanTime = '';
  String _countdown = '';
  Color _countdownColor = Colors.white;
  bool _isLoading = true; // Track initial loading state
  bool _isPrayerTimesLoading = false; // Track prayer times loading
  final LocationService _locationService =
      LocationService(googleApiKey: 'AIzaSyDCnPROW7npzMSQQSmGoQz82dKmnh7b6_g');
  final AdhanService _adhanService = AdhanService();
  final CountdownService _countdownService = CountdownService();
  final HijriDateService _hijriDateService = HijriDateService();

  String _gregorianDate = '';
  String _hijriDate = '';
  DateTime _currentDate = DateTime.now();

  Map<String, String> _prayerTimes = {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final locationName = await _locationService.getCurrentLocationName();
      final position = await LocationService.getCoordinates();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final currentPrayer = await _adhanService.getCurrentPrayer(coordinates);
      final adhanData = await _adhanService.calculateNextAdhan(coordinates);
      final prayerTimes =
          await _adhanService.getPrayerTimes(coordinates, _currentDate);
      final dateInfo = _hijriDateService.getCurrentDate();

      if (mounted) {
        setState(() {
          _locationName = locationName;
          _nowAdhanName = currentPrayer.isNotEmpty ? currentPrayer : 'None';
          _nextAdhanName = adhanData['nextAdhanName'];
          _nextAdhanTime = adhanData['nextAdhanTime'];
          _prayerTimes = prayerTimes;
          _gregorianDate = dateInfo['gregorian']!;
          _hijriDate = dateInfo['hijri']!;
          _isLoading = false;
        });

        final nextPrayerTime = adhanData['nextPrayerTime'];
        if (nextPrayerTime != null) {
          _countdownService.startCountdown(
              nextPrayerTime, _updateCountdownDisplay);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationName = 'Error loading location';
          _nowAdhanName = 'None';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openNearbyMosques() async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/mosque+near+me/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      setState(() {
        _isPrayerTimesLoading = true;
      });

      final position = await LocationService.getCoordinates();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final prayerTimes =
          await _adhanService.getPrayerTimes(coordinates, _currentDate);
      final currentPrayer = await _adhanService
          .getCurrentPrayer(coordinates); // Update current prayer
      final adhanData = await _adhanService
          .calculateNextAdhan(coordinates); // Update next prayer

      if (mounted) {
        setState(() {
          _prayerTimes = prayerTimes;
          _nowAdhanName = currentPrayer.isNotEmpty ? currentPrayer : 'None';
          _nextAdhanName = adhanData['nextAdhanName'];
          _nextAdhanTime = adhanData['nextAdhanTime'];
          _isPrayerTimesLoading = false;

          // Restart countdown with new next prayer time
          _countdownService.stopCountdown();
          final nextPrayerTime = adhanData['nextPrayerTime'];
          if (nextPrayerTime != null) {
            _countdownService.startCountdown(
                nextPrayerTime, _updateCountdownDisplay);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prayerTimes = {
            'Fajr': 'Error',
            'Dhuhr': 'Error',
            'Asr': 'Error',
            'Maghrib': 'Error',
            'Isha': 'Error',
          };
          _nowAdhanName = 'None';
          _isPrayerTimesLoading = false;
        });
      }
    }
  }

  void _updateCountdownDisplay(String countdown, bool isUrgent) {
    if (mounted) {
      setState(() {
        _countdown = countdown;
        _countdownColor =
            isUrgent ? const Color.fromARGB(255, 251, 92, 92) : Colors.white;
      });
    }
  }

  void _showPreviousDate() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      _updateDateDisplay();
    });
    _fetchPrayerTimes();
  }

  void _showNextDate() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
      _updateDateDisplay();
    });
    _fetchPrayerTimes();
  }

  void _updateDateDisplay() {
    final dateInfo = _hijriDateService.getFormattedDate(_currentDate);
    if (mounted) {
      setState(() {
        _gregorianDate = dateInfo['gregorian']!;
        _hijriDate = dateInfo['hijri']!;
      });
    }
  }

  @override
  void dispose() {
    _countdownService.stopCountdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/mosque.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _locationName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        Text(
                          _nextAdhanName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 0.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.lightBlue,
                              size: 20.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              _nextAdhanTime,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _countdown,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _countdownColor,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0, bottom: 15.0),
                                  child: _buildIconButton(
                                    Icons.location_searching,
                                    'Nearby\nMosque',
                                    () => _openNearbyMosques(),
                                  ),
                                ),
                                _buildIconButton(Icons.book, 'Azkar', () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PrayerScreen(
                                              currentPrayer: _nowAdhanName)));
                                }),
                                _buildIconButton(Icons.timer, 'Tasbih', () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TasbihCounter()));
                                }),
                                _buildIconButton(
                                    Icons.calendar_today, 'Calendar', () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CalendarScreen()));
                                }),
                                _buildIconButton(
                                    Icons.notification_add, 'Notification', () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationScheduleScreen()));
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: _showPreviousDate,
                            ),
                            Column(
                              children: [
                                Text(
                                  _gregorianDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 0.0),
                                Text(
                                  _hijriDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: _showNextDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _isPrayerTimesLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _prayerTimes.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          entry.value,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FooterNavigation(),
          ),
        ],
      ),
      endDrawer: CustomDrawer(
        onLogout: () {},
        onSettings: () {
          Navigator.pushNamed(context, '/settings');
        },
        onFeedback: () {
          Navigator.pushNamed(context, '/feedback');
        },
        onNotifications: () {
          Navigator.pushNamed(context, '/notifications');
        },
      ),
      drawerEnableOpenDragGesture: false,
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
