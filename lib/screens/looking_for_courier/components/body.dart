import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

class ShowCase extends StatelessWidget {
  const ShowCase({Key? key}) : super(key: key);

  static const kits = <Widget>[
    SpinKitRotatingCircle(color: Colors.white),
    SpinKitRotatingPlain(color: Colors.white),
    SpinKitChasingDots(color: Colors.white),
    SpinKitPumpingHeart(color: Colors.white),
    SpinKitPulse(color: Colors.white),
    SpinKitDoubleBounce(color: Colors.white),
    SpinKitWave(color: Colors.white, type: SpinKitWaveType.start),
    SpinKitWave(color: Colors.white, type: SpinKitWaveType.center),
    SpinKitWave(color: Colors.white, type: SpinKitWaveType.end),
    SpinKitPianoWave(color: Colors.white, type: SpinKitPianoWaveType.start),
    SpinKitPianoWave(color: Colors.white, type: SpinKitPianoWaveType.center),
    SpinKitPianoWave(color: Colors.white, type: SpinKitPianoWaveType.end),
    SpinKitThreeBounce(color: Colors.white),
    SpinKitThreeInOut(color: Colors.white),
    SpinKitWanderingCubes(color: Colors.white),
    SpinKitWanderingCubes(color: Colors.white, shape: BoxShape.circle),
    SpinKitCircle(color: Colors.white),
    SpinKitFadingFour(color: Colors.white),
    SpinKitFadingFour(color: Colors.white, shape: BoxShape.rectangle),
    SpinKitFadingCube(color: Colors.white),
    SpinKitCubeGrid(size: 51.0, color: Colors.white),
    SpinKitFoldingCube(color: Colors.white),
    SpinKitRing(color: Colors.white),
    SpinKitDualRing(color: Colors.white),
    SpinKitSpinningLines(color: Colors.white),
    SpinKitFadingGrid(color: Colors.white),
    SpinKitFadingGrid(color: Colors.white, shape: BoxShape.rectangle),
    SpinKitSquareCircle(color: Colors.white),
    SpinKitSpinningCircle(color: Colors.white),
    SpinKitSpinningCircle(color: Colors.white, shape: BoxShape.rectangle),
    SpinKitFadingCircle(color: Colors.white),
    SpinKitPulsingGrid(color: Colors.white),
    SpinKitPulsingGrid(color: Colors.white, boxShape: BoxShape.rectangle),
    SpinKitHourGlass(color: Colors.white),
    SpinKitPouringHourGlass(color: Colors.white),
    SpinKitPouringHourGlassRefined(color: Colors.white),
    SpinKitRipple(color: Colors.white),
    SpinKitDancingSquare(color: Colors.white),
    SpinKitWaveSpinner(color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text('SpinKit', style: TextStyle(fontSize: 24.0)),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.adaptiveCrossAxisCount,
          mainAxisSpacing: 46,
          childAspectRatio: 2,
        ),
        padding: const EdgeInsets.only(top: 32, bottom: 64),
        itemCount: kits.length,
        itemBuilder: (context, index) => kits[index],
      ),
    );
  }
}

extension on BuildContext {
  int get adaptiveCrossAxisCount {
    final width = MediaQuery.of(this).size.width;
    if (width > 1024) {
      return 8;
    } else if (width > 720 && width < 1024) {
      return 6;
    } else if (width > 480) {
      return 4;
    } else if (width > 320) {
      return 3;
    }
    return 1;
  }
}

class WorkSpace extends StatelessWidget {
  const WorkSpace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 300.0,
      height: 300.0,
      child: SpinKitFadingCircle(
        itemBuilder: (_, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
        size: 120.0,
      ),
    );
  }
}

class FetchingCourierText extends StatefulWidget {
  @override
  _FetchingCourierTextState createState() => _FetchingCourierTextState();
}

class _FetchingCourierTextState extends State<FetchingCourierText> {
  late StreamController<String> _streamController;
  late Stream<String> _stream;
  int _dotsCount = 0;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {});

    super.initState();
    _streamController = StreamController<String>();
    _stream = _streamController.stream;

    Timer.periodic(Duration(milliseconds: 500), (timer) {
      _streamController
          .add('Fetching you nearest courier' + '.' * (_dotsCount % 4));
      setState(() {
        _dotsCount++;
      });
    });
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: _stream,
      builder: (context, snapshot) {
        return Text(
          snapshot.data ?? '',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        );
      },
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _courierFound = false;
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _courierFound = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Align(
            child: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _courierFound
                    ? Text(
                        'Found!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      )
                    : FetchingCourierText(),
              ),
            ),
            alignment: Alignment.bottomCenter,
          ),
          _courierFound
              ? Center(
                  child: Icon(
                    Icons.check_circle_outlined,
                    size: 100, // Adjust the size as needed
                    color: Colors.green, // Adjust the color as needed
                  ),
                )
              : Positioned.fill(child: Center(child: WorkSpace())),
        ],
      ),
    );
  }
}
