import 'dart:math';
import 'package:flutter/material.dart';
import 'obj_data.dart';

void main() => runApp(const WireframeApp());

class WireframeApp extends StatelessWidget {
  const WireframeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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

  // Penger vertices and faces (indices into vertices)
  final List<Vertex> vs = Obj3D.penger.vertices;
  final List<Face> fs = Obj3D.penger.faces;

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

class WireframePainter extends CustomPainter {
  final List<Vertex> vs;
  final List<Face> fs;
  final double angle;
  final double dz;

  static const foreground = Color(0xFF50FF50);

  WireframePainter({required this.vs, required this.fs, required this.angle, required this.dz});

  // Convert normalized coords (-1..1) to screen coords
  Offset screen(Offset p, Size size) {
    return Offset((p.dx + 1) / 2 * size.width, (1 - (p.dy + 1) / 2) * size.height);
  }

  // Perspective projection (3D → 2D)
  Offset project(Vertex v) => Offset(v.x / v.z, v.y / v.z);

  // Transform a 3D vertex to screen coordinates
  Offset transform(Vertex v, Size size) {
    final centered = Vertex(v.x, v.y - 0.5, v.z);
    return screen(project(centered.rotateY(angle).translateZ(dz)), size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foreground
      ..strokeWidth =
          1.0 // Thinner lines for detailed model
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
