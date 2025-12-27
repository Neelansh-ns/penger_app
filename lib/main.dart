import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const WireframeApp());

class WireframeApp extends StatelessWidget {
  const WireframeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(child: WireframeWidget()),
      ),
    );
  }
}

class WireframeWidget extends StatefulWidget {
  const WireframeWidget({super.key});

  @override
  State<WireframeWidget> createState() => _WireframeWidgetState();
}

class _WireframeWidgetState extends State<WireframeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double angle = 0;
  final double dz = 1;
  static const int fps = 60;

  // Cube vertices
  final List<Point3D> vs = [
    Point3D(-0.5, -0.5, -0.5),
    Point3D(0.5, -0.5, -0.5),
    Point3D(0.5, 0.5, -0.5),
    Point3D(-0.5, 0.5, -0.5),
    Point3D(-0.5, -0.5, 0.5),
    Point3D(0.5, -0.5, 0.5),
    Point3D(0.5, 0.5, 0.5),
    Point3D(-0.5, 0.5, 0.5),
  ];

  // Cube faces (indices into vertices)
  final List<List<int>> fs = [
    [0, 1, 2, 3], [4, 5, 6, 7], // front, back
    [0, 1, 5, 4], [2, 3, 7, 6], // bottom, top
    [0, 3, 7, 4], [1, 2, 6, 5], // left, right
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(() {
        setState(() {
          angle += pi / fps;
        });
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 800,
      child: CustomPaint(
        painter: WireframePainter(vs: vs, fs: fs, angle: angle, dz: dz),
      ),
    );
  }
}

class Point3D {
  final double x, y, z;
  const Point3D(this.x, this.y, this.z);

  // Rotate around Y-axis (in XZ plane)
  Point3D rotateXZ(double angle) {
    final c = cos(angle);
    final s = sin(angle);
    return Point3D(x * c - z * s, y, x * s + z * c);
  }

  // Translate along Z-axis
  Point3D translateZ(double dz) => Point3D(x, y, z + dz);

  // Perspective projection (3D → 2D)
  Offset project() => Offset(x / z, y / z);
}

class WireframePainter extends CustomPainter {
  final List<Point3D> vs;
  final List<List<int>> fs;
  final double angle;
  final double dz;

  static const foreground = Color(0xFF50FF50);

  WireframePainter({required this.vs, required this.fs, required this.angle, required this.dz});

  // Convert normalized coords (-1..1) to screen coords
  Offset screen(Offset p, Size size) {
    return Offset((p.dx + 1) / 2 * size.width, (1 - (p.dy + 1) / 2) * size.height);
  }

  // Transform a 3D point to screen coordinates
  Offset transform(Point3D v, Size size) {
    return screen(v.rotateXZ(angle).translateZ(dz).project(), size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foreground
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw each face as a series of lines
    for (final face in fs) {
      for (int i = 0; i < face.length; i++) {
        final a = vs[face[i]];
        final b = vs[face[(i + 1) % face.length]];
        canvas.drawLine(transform(a, size), transform(b, size), paint);
      }
    }
  }

  @override
  bool shouldRepaint(WireframePainter old) => old.angle != angle;
}
