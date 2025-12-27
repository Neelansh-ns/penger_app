import 'dart:math';

import 'objects/penger_obj.dart';
import 'objects/cube_obj.dart';

/// A 3D point/vertex
class Vertex {
  final double x, y, z;
  const Vertex(this.x, this.y, this.z);

  /// Rotate around Y-axis (in XZ plane)
  Vertex rotateY(double angle) {
    final c = cos(angle);
    final s = sin(angle);
    return Vertex(x * c - z * s, y, x * s + z * c);
  }

  // Rotate around X-axis
  Vertex rotateX(double angle) {
    final c = cos(angle);
    final s = sin(angle);
    return Vertex(x, y * c - z * s, y * s + z * c);
  }

  /// Translate along Z-axis
  Vertex translateZ(double dz) => Vertex(x, y, z + dz);

  // Perspective projection
  (double, double) project() => (x / z, y / z);
}

/// A face is a list of vertex indices (typically 3 for triangles)
typedef Face = List<int>;

/// Base class for all 3D objects
abstract class Obj3D {
  String get name;
  List<Vertex> get vertices;
  List<Face> get faces;

  // Static accessors for all available objects
  static final Obj3D penger = Penger();
  static final Obj3D cube = Cube();
  // Add more here: static final Obj3D penguin = Penguin();
}
