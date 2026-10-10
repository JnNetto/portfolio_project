import 'package:web/web.dart' as web;

/// Liga ou desliga o arraste do <model-viewer> direto no elemento, sem
/// recriá-lo (recriar recarregaria o modelo 3D inteiro).
///
/// [resetOrbit] devolve a câmera ao ângulo inicial; o model-viewer anima a
/// volta sozinho.
bool setModelViewerInteractive(bool interactive, {String? resetOrbit}) {
  final el = web.document.querySelector('model-viewer');
  if (el == null) return false;
  if (interactive) {
    el.setAttribute('camera-controls', '');
  } else {
    el.removeAttribute('camera-controls');
  }
  if (resetOrbit != null) el.setAttribute('camera-orbit', resetOrbit);
  return true;
}
