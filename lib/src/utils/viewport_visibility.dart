import 'package:flutter/widgets.dart';

/// Avisa quando o widget entra ou sai da área visível da rolagem.
///
/// Animações contínuas (tickers, timers) devem pausar fora da tela: um ticker
/// ativo obriga o Flutter a produzir frames sem parar, mesmo sem nada visível
/// mudando.
mixin ViewportVisibility<T extends StatefulWidget> on State<T> {
  ScrollPosition? _position;
  bool _visibleInViewport = true;

  bool get visibleInViewport => _visibleInViewport;

  /// Chamado só quando a visibilidade muda.
  void onViewportVisibilityChanged(bool visible);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final screen = MediaQuery.sizeOf(context).height;
    // Uma folga de 100px evita liga-desliga na borda da tela.
    final visible = top < screen + 100 && top + box.size.height > -100;
    if (visible != _visibleInViewport) {
      _visibleInViewport = visible;
      onViewportVisibilityChanged(visible);
    }
  }
}
