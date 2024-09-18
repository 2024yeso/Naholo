import 'dart:math';
import 'package:flutter/material.dart';

class SwippingcardWidget extends StatefulWidget {
  const SwippingcardWidget({super.key});

  @override
  State<SwippingcardWidget> createState() => _SwippingcardWidgetState();
}

class _SwippingcardWidgetState extends State<SwippingcardWidget>
    with SingleTickerProviderStateMixin {
  late final Tween<double> _rotation = Tween(begin: -15, end: 15);
  late final Tween<double> _scale = Tween(begin: 0.8, end: 1);
  late final Size size;
  late final AnimationController _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    _position = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: size.width + 100,
      lowerBound: size.width * (-1) - 100,
      value: 0,
    );
  }

  void _onHorizontalDragUpdate(DragUpdateDetails detail) {
    _position.value += detail.delta.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails detail) {
    final bound = size.width - 200;
    final dropzone = size.width + 100;
    if (_position.value.abs() >= bound) {
      if (_position.value.isNegative) {
        _position.animateTo(dropzone * -1);
      } else {
        _position.animateTo((dropzone));
      }
    } else {
      _position.animateTo(0, curve: Curves.bounceOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _position,
      builder: (context, child) {
        final angle = _rotation
            .transform((_position.value + size.width / 2) / size.width);
        final scale = _scale.transform(_position.value.abs() / size.width);
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 100,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 10,
                  color: Colors.blue.shade100,
                  child: SizedBox(
                    height: size.height * 0.5,
                    width: size.width * 0.8,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Transform.translate(
                  offset: Offset(_position.value, 0),
                  child: Transform.rotate(
                    angle: angle * pi / 360,
                    child: Material(
                      elevation: 10,
                      color: Colors.red.shade100,
                      child: SizedBox(
                        height: size.height * 0.5,
                        width: size.width * 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }
}
