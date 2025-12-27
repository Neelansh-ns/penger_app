import '../obj_data.dart';

class Cube extends Obj3D {
  @override
  String get name => 'Cube';

  @override
  List<Vertex> get vertices => [
    Vertex(-0.5, -0.5, -0.5),
    Vertex(0.5, -0.5, -0.5),
    Vertex(0.5, 0.5, -0.5),
    Vertex(-0.5, 0.5, -0.5),
    Vertex(-0.5, -0.5, 0.5),
    Vertex(0.5, -0.5, 0.5),
    Vertex(0.5, 0.5, 0.5),
    Vertex(-0.5, 0.5, 0.5),
  ];

  @override
  List<Face> get faces => [
    [0, 1, 2, 3], [4, 5, 6, 7], // front, back
    [0, 1, 5, 4], [2, 3, 7, 6], // bottom, top
    [0, 3, 7, 4], [1, 2, 6, 5], // left, right
  ];
}
