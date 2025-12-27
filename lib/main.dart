import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:penger_app/obj_data.dart';

void main() => runApp(const WireframeApp());

class WireframeApp extends StatelessWidget {
  const WireframeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const WireframeViewer(),
    );
  }
}

class WireframeViewer extends StatefulWidget {
  const WireframeViewer({super.key});

  @override
  State<WireframeViewer> createState() => _WireframeViewerState();
}

class _WireframeViewerState extends State<WireframeViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // View controls
  double angleY = 0; // Rotation around Y axis
  double angleX = 0; // Rotation around X axis (tilt)
  double zoom = 15.0; // Distance from camera
  double speed = 1.0; // Rotation speed multiplier
  bool isPlaying = true; // Auto-rotate toggle
  bool showWireframe = true;

  // Drag tracking
  Offset? _lastPanPosition;

  static const int fps = 60;

  // Penger vertices and faces (indices into vertices)
  final List<Vertex> vs = Obj3D.penger.vertices;
  final List<Face> fs = Obj3D.penger.faces;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            if (isPlaying) {
              setState(() {
                angleY += (pi / fps) * speed;
              });
            }
          });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_lastPanPosition != null) {
      final delta = details.localPosition - _lastPanPosition!;
      setState(() {
        angleY += delta.dx * 0.01;
        angleX += delta.dy * 0.01;
        // Clamp vertical rotation
        angleX = angleX.clamp(-pi / 2, pi / 2);
      });
      _lastPanPosition = details.localPosition;
    }
  }

  void _handleScroll(PointerScrollEvent event) {
    setState(() {
      zoom += event.scrollDelta.dy * 0.05; // Scroll up = zoom in
      zoom = zoom.clamp(1.0, 20.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Column(
        children: [
          // Control panel
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1a1a1a),
            child: Column(
              children: [
                // Title and play controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🐧 PENGER VIEWER',
                      style: TextStyle(
                        color: Color(0xFF50FF50),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Play/Pause button
                    IconButton(
                      onPressed: () => setState(() => isPlaying = !isPlaying),
                      icon: Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: const Color(0xFF50FF50),
                        size: 36,
                      ),
                    ),
                    // Reset button
                    IconButton(
                      onPressed: () => setState(() {
                        angleY = 0;
                        angleX = 0;
                        zoom = 15.0;
                        speed = 1.0;
                      }),
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF50FF50),
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sliders row
                Row(
                  children: [
                    // Zoom slider
                    Expanded(
                      child: _buildSlider(
                        icon: Icons.zoom_in,
                        label: 'Zoom',
                        value: zoom,
                        min: 1.0,
                        max: 20.0,
                        onChanged: (v) => setState(() => zoom = v),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Speed slider
                    Expanded(
                      child: _buildSlider(
                        icon: Icons.speed,
                        label: 'Speed',
                        value: speed,
                        min: 0.0,
                        max: 3.0,
                        onChanged: (v) => setState(() => speed = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3D Viewport
          Expanded(
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  _handleScroll(event);
                }
              },
              child: GestureDetector(
                onPanStart: _handlePanStart,
                onPanUpdate: _handlePanUpdate,
                child: Container(
                  color: const Color(0xFF101010),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(700, 700),
                      painter: WireframePainter(
                        vs: vs,
                        fs: fs,
                        angleY: angleY,
                        angleX: angleX,
                        dz:
                            20.0 /
                            zoom, // Inverse: higher zoom = smaller dz = closer
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF1a1a1a),
            child: const Text(
              '🖱️ Drag to rotate  •  📜 Scroll to zoom  •  ▶️ Play/Pause auto-rotation',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF50FF50), size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: const TextStyle(color: Color(0xFF50FF50), fontSize: 12),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF50FF50),
              inactiveTrackColor: const Color(0xFF333333),
              thumbColor: const Color(0xFF50FF50),
              overlayColor: const Color(0xFF50FF50).withValues(alpha: .2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class WireframePainter extends CustomPainter {
  final List<Vertex> vs;
  final List<Face> fs;
  final double angleY;
  final double angleX;
  final double dz;

  static const foreground = Color(0xFF50FF50);

  WireframePainter({
    required this.vs,
    required this.fs,
    required this.angleY,
    required this.angleX,
    required this.dz,
  });

  // Use (double x, double y) records instead of Offset where possible

  (double, double) screen((double, double) p, Size size) {
    final (dx, dy) = p;
    final x = (dx + 1) / 2 * size.width;
    final y = (1 - (dy + 1) / 2) * size.height;
    return (x, y);
  }

  (double, double) transform(Vertex v, Size size) {
    // Center the model
    final centered = Vertex(v.x, v.y - 0.5, v.z);
    // Apply rotations and projection, then map to screen coordinates
    final (px, py) = centered
        .rotateX(angleX)
        .rotateY(angleY)
        .translateZ(dz)
        .project();
    return screen((px, py), size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = foreground.withValues(alpha: 0.8)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Draw each face
    for (final face in fs) {
      for (int i = 0; i < face.length; i++) {
        final a = vs[face[i]];
        final b = vs[face[(i + 1) % face.length]];
        final (ax, ay) = transform(a, size);
        final (bx, by) = transform(b, size);
        canvas.drawLine(Offset(ax, ay), Offset(bx, by), paint);
      }
    }
  }

  @override
  bool shouldRepaint(WireframePainter old) =>
      old.angleY != angleY || old.angleX != angleX || old.dz != dz;
}
