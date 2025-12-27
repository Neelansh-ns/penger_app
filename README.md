# 🐧 Penger Viewer

A Flutter app that projects 3D vertices onto a 2D coordinate system using perspective projection.

Inspired by [tsoding/formula](https://github.com/tsoding/formula) - "One Formula That Demystifies 3D Graphics"

## Preview

https://github.com/user-attachments/assets/7707003e-e1f8-42cf-b3d4-347756c3bdfe

## What it does

Takes 3D model data (vertices and faces) and renders them as wireframe graphics on screen. The app performs:

- **3D to 2D Projection** - Converts 3D coordinates to 2D screen space using perspective division
- **Rotation Transforms** - Rotates vertices around X and Y axes
- **Real-time Rendering** - Draws wireframe edges using Flutter's CustomPainter

## Interactive Playground

The app includes an interactive viewer where you can:

- Drag to rotate the model
- Scroll to zoom in/out
- Toggle auto-rotation
- Adjust rotation speed

## Model

The model is provided by [https://github.com/Max-Kawula/penger-obj](https://github.com/Max-Kawula/penger-obj)

[![penger-obj](https://raw.githubusercontent.com/Max-Kawula/penger-obj/main/penger/screenshots/penger-obj.png)](https://github.com/Max-Kawula/penger-obj)

## Getting Started

```bash
flutter pub get
flutter run
```

---

Made with Flutter 💜
