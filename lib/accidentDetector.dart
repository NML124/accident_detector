import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccidentDetector extends StatefulWidget {
  const AccidentDetector({super.key});
  @override
  State<AccidentDetector> createState() => _AccidentDetectorState();
}

class _AccidentDetectorState extends State<AccidentDetector> {
  List<double>? _userAccelerometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  bool isCrashed(userAccelerometer) {
    return sqrt((userAccelerometer[0] ^
            2 + userAccelerometer[1] ^
            2 + userAccelerometer[2] ^
            2)) >
        300;
  }

  @override
  Widget build(BuildContext context) {
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();
    return Center(
        child: Column(
      children: [
        Text("Your actual accelerometer values: $userAccelerometer"),
      ],
    ));
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
  }
}
