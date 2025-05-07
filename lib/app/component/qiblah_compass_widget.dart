import 'dart:math' ;
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time_mobile_app/app/component/compass_custom_painter.dart';
import 'package:prayer_time_mobile_app/services/location_service.dart';

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget> {
  Future<Position>? getPosition;
  double? _direction;

  @override
  void initState() {
    super.initState();
    getPosition = LocationService.getCoordinates();
    _initCompass();
  }

  void _initCompass() {
    magnetometerEvents.listen((MagnetometerEvent event) {
      final double x = event.x;
      final double y = event.y;
      final double z = event.z;
      
      // 计算方向角度
      double direction = atan2(y, x) * (180 / pi);
      if (direction < 0) {
        direction += 360;
      }
      
      setState(() {
        _direction = direction;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return FutureBuilder<Position>(
      future: getPosition,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Position positionResult = snapshot.data!;
          Coordinates coordinates = Coordinates(
            positionResult.latitude,
            positionResult.longitude,
          );
          double qiblaDirection = Qibla(
            coordinates,
          ).direction;
          
          if (_direction == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: size,
                      painter: CompassCustomPainter(
                        angle: _direction!,
                      ),
                    ),
                    Transform.rotate(
                      angle: -2 * pi * (_direction! / 360),
                      child: Transform(
                        alignment: FractionalOffset.center,
                        transform: Matrix4.rotationZ(qiblaDirection * pi / 180),
                        origin: Offset.zero,
                        child: Image.asset(
                          'assets/images/qiblah.png',
                          width: 112,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      radius: 140,
                      child: Transform.rotate(
                        angle: -2 * pi * (_direction! / 360),
                        child: Transform(
                          alignment: FractionalOffset.center,
                          transform: Matrix4.rotationZ(qiblaDirection * pi / 180),
                          origin: Offset.zero,
                          child: const Align(
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.expand_less_outlined,
                              color: Colors.black,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.45),
                      child: Text(
                        showHeading(normalizeAngle(_direction!), qiblaDirection),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      },
    );
  }

  double normalizeAngle(double angle) {
    return (angle >= 0) ? angle : (360 + angle);
  }

  String showHeading(double direction, double qiblaDirection) {
    return qiblaDirection.toInt() != direction.toInt()
        ? '${direction.toStringAsFixed(0)}°'
        : "You're facing Makkah!";
  }
}
