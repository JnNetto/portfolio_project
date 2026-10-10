import 'dart:ui';

export 'orbit_reader_stub.dart'
    if (dart.library.js_interop) 'orbit_reader_web.dart';

/// Estado da câmera do model-viewer, em radianos.
/// [theta] já desconta a rotação automática (turntable) do modelo.
class OrbitReading {
  final double theta;
  final double phi;
  final double radius;
  final Offset? pointer;

  /// Ângulo da câmera sem descontar o auto-rotate: só muda quando o
  /// visitante gira o modelo.
  final double cameraTheta;

  const OrbitReading({
    required this.cameraTheta,
    required this.theta,
    required this.phi,
    required this.radius,
    this.pointer,
  });
}
