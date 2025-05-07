import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time_mobile_app/app/model/connected_user.dart';
import 'package:prayer_time_mobile_app/app/model/prayer_status.dart';
import 'package:prayer_time_mobile_app/app/provider/connection_provider.dart';
import 'package:prayer_time_mobile_app/app/provider/prayer_provider.dart';
import 'package:prayer_time_mobile_app/services/adhan_service.dart';
import 'package:prayer_time_mobile_app/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hijri/hijri_calendar.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime now = DateTime.now().toLocal();
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  CalendarFormat _calendarFormat = CalendarFormat.month;

  var weekdays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  
  var weekmonths = [
    'Dec',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov'
  ];

  final Map<DateTime, List<PrayerStatus>> _events = {};
  List<PrayerStatus> _selectedEvents = [];
  String _nowAdhanName = '';
  ConnectedUser? selectedUser;
  late PrayerProvider _prayerProvider;
  
  // 统计数据
  Map<String, int> _attendanceCounts = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    
    // 延迟加载需要context的操作
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPrayerStatus();
        _loadConnectedUser();
        _calculateCurrentAdhan();
        _prayerProvider = Provider.of<PrayerProvider>(context, listen: false);
        _loadPrayerStatuses(_prayerProvider);
        fetchMonthlyAttendanceData();
      }
    });
  }

  List<PrayerStatus> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Future<void> _calculateCurrentAdhan() async {
    try {
      Position position = await LocationService.getCoordinates();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final currentPrayer = await AdhanService().getCurrentPrayer(coordinates);
      if (mounted) {
        setState(() {
          _nowAdhanName = currentPrayer;
        });
      }
    } catch (e) {
      debugPrint("Error calculating current adhan: $e");
    }
  }

  void _loadPrayerStatus() {
    try {
      Provider.of<PrayerProvider>(context, listen: false).fetchPrayerStatuses();
    } catch (e) {
      debugPrint("Error loading prayer status: $e");
    }
  }

  void _loadConnectedUser() {
    try {
      Provider.of<ConnectionProvider>(context, listen: false).getConnectedUsers();
    } catch (e) {
      debugPrint("Error loading connected users: $e");
    }
  }

  void onRefresh() async {
    _loadPrayerStatus();
    _loadConnectedUser();
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents = _getEventsForDay(_selectedDay!);
    }
  }

  void _loadPrayerStatuses(PrayerProvider provider) {
    try {
      final prayerStatuses = provider.prayerStatuses;
      final creationDate = provider.creationDate;
      _processEvents(prayerStatuses, creationDate);
    } catch (e) {
      debugPrint("Error loading prayer statuses: $e");
    }
  }

  void _processEvents(List<PrayerStatus> prayerStatuses, DateTime creationDate) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    for (DateTime date = creationDate; 
         date.isBefore(now) || isSameDay(date, now); 
         date = date.add(const Duration(days: 1))) {
      
      String formattedDate = dateFormat.format(date);
      DateTime formattedDateTime = DateTime.parse(formattedDate);
      
      PrayerStatus status = _findOrCreateStatus(prayerStatuses, formattedDate);
      
      if (!isSameDay(date, now)) {
        status = _markPendingAsAbsent(status);
      }
      
      if (_events[formattedDateTime] == null) {
        _events[formattedDateTime] = [status];
      } else {
        _events[formattedDateTime]!.add(status);
      }
    }
    
    if (_selectedDay != null && mounted) {
      setState(() {
        _selectedEvents = _getEventsForDay(_selectedDay!);
      });
    }
  }

  PrayerStatus _findOrCreateStatus(List<PrayerStatus> statuses, String date) {
    return statuses.firstWhere(
      (status) => status.date == date,
      orElse: () => PrayerStatus(
        date: date,
        fajr: 'pending',
        dhuhr: 'pending',
        asr: 'pending',
        maghrib: 'pending',
        isha: 'pending',
      ),
    );
  }

  PrayerStatus _markPendingAsAbsent(PrayerStatus status) {
    return PrayerStatus(
      date: status.date,
      fajr: status.fajr == 'pending' ? 'absent' : status.fajr,
      dhuhr: status.dhuhr == 'pending' ? 'absent' : status.dhuhr,
      asr: status.asr == 'pending' ? 'absent' : status.asr,
      maghrib: status.maghrib == 'pending' ? 'absent' : status.maghrib,
      isha: status.isha == 'pending' ? 'absent' : status.isha,
    );
  }

  void _showConnectUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connect to User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter user email',
                ),
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Enter a nickname for this user',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _connectUser(emailController.text, nicknameController.text, context);
              },
              child: const Text('Connect'),
            ),
          ],
        );
      },
    );
  }

  void _connectUser(String email, String nickname, BuildContext context) async {
    try {
      await Provider.of<ConnectionProvider>(context, listen: false).connectToUserByEmail(email, nickname);
      if (mounted) {
        _showSuccessDialog(context, 'User connected successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, 'Failed to connect user: $e');
      }
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchMonthlyAttendanceData() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      final userId = _prayerProvider.userId;
      if (userId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      
      final firstDayStr = firstDayOfMonth.toIso8601String().split('T')[0];
      final lastDayStr = lastDayOfMonth.toIso8601String().split('T')[0];
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('prayers')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: firstDayStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: lastDayStr)
          .get();
      
      Map<String, int> counts = {
        'Fajr': 0, 'Dhuhr': 0, 'Asr': 0, 'Maghrib': 0, 'Isha': 0,
      };
      
      for (var doc in snapshot.docs) {
        if (doc.data()['Fajr'] == 'success') counts['Fajr'] = (counts['Fajr'] ?? 0) + 1;
        if (doc.data()['Dhuhr'] == 'success') counts['Dhuhr'] = (counts['Dhuhr'] ?? 0) + 1;
        if (doc.data()['Asr'] == 'success') counts['Asr'] = (counts['Asr'] ?? 0) + 1;
        if (doc.data()['Maghrib'] == 'success') counts['Maghrib'] = (counts['Maghrib'] ?? 0) + 1;
        if (doc.data()['Isha'] == 'success') counts['Isha'] = (counts['Isha'] ?? 0) + 1;
      }
      
      if (mounted) {
        setState(() {
          _attendanceCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching monthly attendance data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getHijriDate(DateTime date) {
    final hijriDate = HijriCalendar.fromDate(date);
    return '${hijriDate.hDay} ${_getHijriMonthName(hijriDate.hMonth)} ${hijriDate.hYear}';
  }

  String _getHijriMonthName(int month) {
    const hijriMonths = [
      'Muharram',
      'Safar',
      'Rabi\'ul Awwal',
      'Rabi\'ul Thani',
      'Jumada\'ul Awwal',
      'Jumada\'ul Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu\'l-Qa\'dah',
      'Dhu\'l-Hijjah'
    ];
    return hijriMonths[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                rangeSelectionMode: _rangeSelectionMode,
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedEvents.isNotEmpty)
                const Text(
                  'Prayer Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: _attendanceCounts['Fajr']?.toDouble() ?? 0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: _attendanceCounts['Dhuhr']?.toDouble() ?? 0,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: _attendanceCounts['Asr']?.toDouble() ?? 0,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            toY: _attendanceCounts['Maghrib']?.toDouble() ?? 0,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(
                            toY: _attendanceCounts['Isha']?.toDouble() ?? 0,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            String text = '';
                            switch (value.toInt()) {
                              case 0: text = 'Fajr'; break;
                              case 1: text = 'Dhuhr'; break;
                              case 2: text = 'Asr'; break;
                              case 3: text = 'Maghrib'; break;
                              case 4: text = 'Isha'; break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(text),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              ..._selectedEvents.map((event) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1.8,
                      color: Colors.black,
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prayer Attendance : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16)),
                        const SizedBox(height: 10),
                        PrayerListTile(prayerName: 'Fajr', prayerStatus: event.fajr),
                        PrayerListTile(prayerName: 'Dhuhr', prayerStatus: event.dhuhr),
                        PrayerListTile(prayerName: 'Asr', prayerStatus: event.asr),
                        PrayerListTile(prayerName: 'Maghrib', prayerStatus: event.maghrib),
                        PrayerListTile(prayerName: 'Isha', prayerStatus: event.isha),
                      ],
                    ),
                  )
                ),
              )),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      )
    );
  }
}

class PrayerListTile extends StatelessWidget {
  final String prayerName;
  final String prayerStatus;

  const PrayerListTile({
    required this.prayerName,
    required this.prayerStatus,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$prayerName : $prayerStatus',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14),
        ),
        const SizedBox(width: 4),
        if (prayerStatus == 'absent') 
          const Icon(
            Icons.close,
            color: Colors.red,
          ),
        if (prayerStatus == 'success') 
          const Icon(
            Icons.done,
            color: Colors.green,
          ),
      ],
    );
  }
}

class CalendarWorkSelection extends StatelessWidget {
  final String imageAddress;
  final String title;

  const CalendarWorkSelection({
    required this.imageAddress,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Image(image: AssetImage(imageAddress)),
      const SizedBox(height: 5),
      Text(title,
        style: const TextStyle(
          color: Colors.black, 
          fontSize: 12, 
          fontWeight: FontWeight.w400))
    ]);
  }
}

