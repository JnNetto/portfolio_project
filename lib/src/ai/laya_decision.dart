/// Laya-style local decision engine.
///
/// `laya_dart` 0.0.4 runs a 1.7 GB ONNX model via FFI. That does not work on
/// Flutter web (this portfolio's target) and would block first paint.
/// This engine keeps Laya's typed-question API so a native ONNX backend can
/// replace [classify] later without changing the command bar UI.
library;

class LayaQuestion {
  final String instructions;
  final Map<String, String> criteria;

  const LayaQuestion.choice({
    required this.instructions,
    required this.criteria,
  });
}

class LayaChoice {
  final String id;
  final String label;
  final double confidence;

  const LayaChoice({
    required this.id,
    required this.label,
    required this.confidence,
  });
}

class PortfolioLaya {
  static const intentQuestion = LayaQuestion.choice(
    instructions: 'Qual ação o visitante quer no portfólio?',
    criteria: {
      'home': 'voltar ao início, hero, hello, começar',
      'about': 'sobre mim, biografia, quem sou, trajetória',
      'projects': 'projetos, trabalhos, cases, portfólio de apps',
      'skills': 'habilidades, stack, tecnologias, competências',
      'contact': 'contato, email, falar, contratar, mensagem',
      'theme': 'tema, dark, light, modo escuro, modo claro',
    },
  );

  LayaChoice classify(String raw) {
    final text = _normalize(raw);
    if (text.isEmpty) {
      return const LayaChoice(id: 'idle', label: 'aguardando', confidence: 0);
    }

    final scores = <String, double>{};
    intentQuestion.criteria.forEach((id, criteria) {
      scores[id] = _score(text, id, criteria);
    });

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = ranked.first;
    final second = ranked.length > 1 ? ranked[1].value : 0.0;
    final lead = (best.value - second).clamp(0.0, 1.0);
    final confidence = (0.35 + best.value * 0.45 + lead * 0.4).clamp(0.0, 0.98);

    if (best.value < 0.18) {
      return LayaChoice(
        id: 'unknown',
        label: 'não identificado',
        confidence: confidence * 0.4,
      );
    }

    return LayaChoice(
      id: best.key,
      label: _labels[best.key] ?? best.key,
      confidence: confidence,
    );
  }

  double _score(String text, String id, String criteria) {
    final tokens = <String>{id, ...criteria.split(RegExp(r'[,\s]+'))}
        .where((token) => token.length > 2)
        .map(_normalize)
        .toSet();

    var hits = 0.0;
    for (final token in tokens) {
      if (token.isEmpty) continue;
      if (text == token) {
        hits += 2.2;
      } else if (text.contains(token)) {
        hits += token.length > 6 ? 1.4 : 1.0;
      }
    }
    return hits;
  }

  String _normalize(String value) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    var output = value.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      output = output.replaceAll(from[i], to[i]);
    }
    return output;
  }

  static const _labels = {
    'home': 'Ir ao início',
    'about': 'Abrir sobre mim',
    'projects': 'Ver projetos',
    'skills': 'Ver habilidades',
    'contact': 'Falar comigo',
    'theme': 'Alternar tema',
    'unknown': 'Não identificado',
    'idle': 'Aguardando',
  };
}
