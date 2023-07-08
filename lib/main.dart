import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accident Detector',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(159, 19, 175, 22),
      ),
      home: const MyHomePage(title: 'Accident Detector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<double>? _accelerometerValues = [0, 0, 0];
  double dangerousValueAccelerometer = 300;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  bool crash = false;
  bool answered = false;
  bool safe = false;

  late FlutterTts flutterTts;
  final String _messageAlerte1 = "Are you okay ? If you are not, click \"no\".";
  final String _messageAlerte2 = "I'm calling ambulance.";

  bool isCrashed(userAccelerometer) {
    return userAccelerometer != null
        ? sqrt((pow(userAccelerometer[0], 2) +
                pow(userAccelerometer[1], 2) +
                pow(userAccelerometer[2], 2))) >=
            dangerousValueAccelerometer
        : false;
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer = _accelerometerValues;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accident Detector'),
        elevation: 4,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                crash
                    ? Text("There is a crash $safe")
                    : Text("Everything is okay. Magnetometer : $accelerometer"),
                OutlinedButton(onPressed: isSafe, child: Text("Is Okay ?")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    flutterTts.stop();
  }

  void isSafe() {
    if (answered) {
      _speak();
      answered = false;
    }

    showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Accident Detect"),
            content: Text("Are you okay ?"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
            ],
          );
        }).then((value) {
      answered = true;
      safe = value!;
    });
  }

  @override
  void initState() {
    super.initState();
    initTextToSpeech();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
            crash = isCrashed([dangerousValueAccelerometer, 0, 0]);
          });
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Gyroscope Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
  }

  void initTextToSpeech() {
    flutterTts = FlutterTts();
  }

  Future _speak() async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.4);
    await flutterTts.setPitch(0.2);

    await flutterTts.speak(_messageAlerte1);

    Future.delayed(const Duration(seconds: 10), () {
      if (!safe) {
        flutterTts.speak(_messageAlerte1);
      }
    }).then((_) => Future.delayed(const Duration(seconds: 5), () {
          if (!safe) {
            flutterTts.speak(_messageAlerte2);
          }
        }));
  }

  Future _stop() async {
    var result = await flutterTts.stop();
  }
}
