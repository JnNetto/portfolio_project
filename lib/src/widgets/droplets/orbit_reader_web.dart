import 'dart:js_interop';
import 'dart:ui';

import 'package:portfolio/src/widgets/droplets/orbit_reader.dart';
import 'package:web/web.dart' as web;

extension type _ModelViewerElement._(JSObject _) implements JSObject {
  external _SphericalPosition getCameraOrbit();
  external double? get turntableRotation;
}

extension type _SphericalPosition._(JSObject _) implements JSObject {
  external double get theta;
  external double get phi;
  external double get radius;
}

/// Lê a órbita da câmera direto do <model-viewer> no DOM, já que os eventos
/// de ponteiro sobre a platform view não chegam ao Flutter.
class OrbitReader {
  web.HTMLElement? _element;
  int _framesUntilLookup = 0;
  Offset? _pointer;

  late final JSFunction _onMove = ((web.PointerEvent e) {
    final el = _element;
    if (el == null) return;
    final rect = el.getBoundingClientRect();
    _pointer = Offset(e.clientX - rect.left, e.clientY - rect.top);
  }).toJS;

  late final JSFunction _onLeave = ((web.PointerEvent _) {
    _pointer = null;
  }).toJS;

  OrbitReading? read() {
    final el = _element ?? _lookup();
    if (el == null) return null;
    if (!el.isConnected) {
      _detach();
      return null;
    }
    try {
      final viewer = el as _ModelViewerElement;
      final orbit = viewer.getCameraOrbit();
      return OrbitReading(
        theta: orbit.theta - (viewer.turntableRotation ?? 0),
        phi: orbit.phi,
        radius: orbit.radius,
        pointer: _pointer,
      );
    } catch (_) {
      // Elemento ainda não foi atualizado pelo script do model-viewer.
      return null;
    }
  }

  web.HTMLElement? _lookup() {
    if (_framesUntilLookup-- > 0) return null;
    _framesUntilLookup = 30;
    final el = web.document.querySelector('model-viewer') as web.HTMLElement?;
    if (el == null) return null;
    _element = el
      ..addEventListener('pointermove', _onMove)
      ..addEventListener('pointerdown', _onMove)
      ..addEventListener('pointerleave', _onLeave);
    return el;
  }

  void _detach() {
    _element
      ?..removeEventListener('pointermove', _onMove)
      ..removeEventListener('pointerdown', _onMove)
      ..removeEventListener('pointerleave', _onLeave);
    _element = null;
    _pointer = null;
  }

  void dispose() => _detach();
}
