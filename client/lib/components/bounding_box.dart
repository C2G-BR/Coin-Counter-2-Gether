import 'package:flutter/material.dart';

class BoundingBox extends StatelessWidget {
  final BBox box;
  final Size imageSize;

  const BoundingBox({
    required this.box,
    required this.imageSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: box.left * imageSize.width,
      top: box.top * imageSize.height,
      child: Container(
        width: box.width * imageSize.width,
        height: box.height * imageSize.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
            width: 1,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: ColoredBox(
              color: Colors.red,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    box.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BBox {
  final double left;
  final double top;
  final double right;
  final double bottom;
  final String text;

  BBox(this.left, this.top, this.right, this.bottom, this.text);

  double get width {
    return (right - left).abs();
  }

  double get height {
    return (bottom - top).abs();
  }
}
