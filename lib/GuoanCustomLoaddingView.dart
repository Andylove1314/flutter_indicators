import 'package:flutter/material.dart';
import 'dart:math' as math;

/**
 * 自定义loading view
 */
class GuoanCustomLoaddingView extends StatefulWidget {
//指示器线条颜色
  final Color color;
  //指示器尺寸
  final double size;
  //动画时长
  final int duration;

  const GuoanCustomLoaddingView({
    Key key,
    this.color = const Color(0xfffe564c),
    this.size = 25.0,
    this.duration = 1000,
  }) : super(key: key);

  @override
  GuoanCustomLoaddingViewState createState() =>
      new GuoanCustomLoaddingViewState(duration);
}

class GuoanCustomLoaddingViewState extends State<GuoanCustomLoaddingView>
    with TickerProviderStateMixin {
  AnimationController _scaleCtrl, _rotateCtrl;
  Animation<double> _scale, _rotate;
  Duration dura;

  GuoanCustomLoaddingViewState(int duration) {
    dura = Duration(milliseconds: duration);
  }

  @override
  void initState() {
    super.initState();
    _scaleCtrl = new AnimationController(vsync: this, duration: dura);
    _rotateCtrl = new AnimationController(vsync: this, duration: dura);

    _scale = Tween(begin: 0.0, end: 1.0).animate(
      new CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    )
      ..addListener(() => setState(() => <String, void>{}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleCtrl.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _scaleCtrl.forward();
        }
      });

    _rotate = Tween(begin: 0.0, end: 360.0).animate(
      new CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear),
    )..addListener(() => setState(() => <String, void>{}));

    _rotateCtrl.repeat();
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = new Matrix4.identity()
      ..rotateZ((_rotate.value) * math.pi * 2);
    return new Transform.scale(
      scale: (1.0 - _scale.value.abs() * 0.4),
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Transform.rotate(
            angle: _rotate.value * 0.0174533,
            child: new Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: CustomPaint(
                child: new Container(
                  height: widget.size,
                  width: widget.size,
                ),
                painter: _DualRingPainter(color: widget.color),
              ),
            ),
          ),
          new Transform.rotate(
            angle: 1 - _rotate.value * 0.0174533,
            child: new Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: CustomPaint(
                child: new Container(
                  height: widget.size * 0.4,
                  width: widget.size * 0.4,
                ),
                painter: _DualRingPainter(color: widget.color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  Paint p = Paint();
  final double weight;

  _DualRingPainter({this.weight = 90.0, Color color}) {
    p.color = color;
    p.strokeWidth = 1.0;
    p.style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      0.0,
      getRadian(weight),
      false,
      p,
    );
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      getRadian(180.0),
      getRadian(weight),
      false,
      p,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) {
    return math.pi / 180 * angle;
  }
}
