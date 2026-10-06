import 'dart:math' as math;

// Motor de decisão da cobrinha. Não é um modelo de IA: é busca em grafo
// (BFS + flood fill) que dá uma nota a cada direção e uma camada de
// segurança que só intervém quando a melhor nota levaria a um beco.
//
// A cada passo:
//   1. Planeja a ORDEM de coleta dos pontos (caixeiro-viajante pequeno:
//      força bruta até 7 pontos, heurística acima disso), usando distâncias
//      reais pelo quadro, com o corpo da cobra como obstáculo.
//   2. Avalia as 4 direções: progresso até o próximo ponto do plano, espaço
//      livre depois do movimento e se a cauda continua alcançável.
//   3. Converte as notas em probabilidades (softmax) e executa a melhor —
//      a menos que a segurança vete.

class Cell {
  final int x;
  final int y;

  const Cell(this.x, this.y);

  Cell step(Move m) => Cell(x + m.dx, y + m.dy);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

enum Move {
  up(0, -1),
  down(0, 1),
  left(-1, 0),
  right(1, 0);

  final int dx;
  final int dy;

  const Move(this.dx, this.dy);

  Move get opposite => switch (this) {
        Move.up => Move.down,
        Move.down => Move.up,
        Move.left => Move.right,
        Move.right => Move.left,
      };
}

class MoveLog {
  final int tick;
  final Move move;
  final bool intervened;

  const MoveLog(this.tick, this.move, this.intervened);
}

/// Avaliação de uma direção candidata.
class _Candidate {
  final Move move;
  final List<Cell> nextBody;
  final bool eats;
  final int area;
  final bool tailReachable;
  final double score;

  const _Candidate({
    required this.move,
    required this.nextBody,
    required this.eats,
    required this.area,
    required this.tailReachable,
    required this.score,
  });

  /// Seguro: a cauda continua alcançável ou sobra espaço para o corpo.
  bool get safe => tailReachable || area >= nextBody.length;
}

class SnakeEngine {
  final int cols;
  final int rows;
  final int maxFoods;
  final math.Random _rnd;

  late List<Cell> snake;
  Move dir = Move.left;
  final List<Cell> foods = [];
  int score = 0;
  int tick = 0;
  bool gameOver = false;

  // O que o painel mostra.
  Map<Move, double> probabilities = {for (final m in Move.values) m: 0};
  double deadEndRisk = 0;
  double foodReachable = 1;
  Move? executing;
  bool intervened = false;
  final List<MoveLog> history = [];

  /// Pontos na ordem em que o motor pretende coletá-los.
  List<Cell> plan = const [];

  /// Caminho completo planejado, célula a célula.
  List<Cell> route = const [];

  SnakeEngine({
    this.cols = 18,
    this.rows = 14,
    this.maxFoods = 10,
    math.Random? random,
  }) : _rnd = random ?? math.Random() {
    reset();
  }

  void reset() {
    final cx = cols ~/ 2;
    final cy = rows ~/ 2;
    snake = [for (var i = 0; i < 4; i++) Cell(cx + i, cy)];
    dir = Move.left;
    foods.clear();
    score = 0;
    tick = 0;
    gameOver = false;
    executing = null;
    intervened = false;
    history.clear();
    _spawnFood();
    _replan();
  }

  /// Cobra ocupando mais da metade do quadro: hora de recomeçar a demo.
  bool get crowded => snake.length >= cols * rows * 0.55;

  bool _inside(Cell c) => c.x >= 0 && c.y >= 0 && c.x < cols && c.y < rows;
  int _index(Cell c) => c.y * cols + c.x;

  /// Visitante clicou no quadro: novo ponto, se a célula estiver livre.
  bool addFood(Cell c) {
    if (!_inside(c) || foods.length >= maxFoods) return false;
    if (foods.contains(c) || snake.contains(c)) return false;
    foods.add(c);
    _replan();
    return true;
  }

  void _spawnFood() {
    final free = [
      for (var y = 0; y < rows; y++)
        for (var x = 0; x < cols; x++)
          if (!snake.contains(Cell(x, y)) && !foods.contains(Cell(x, y)))
            Cell(x, y),
    ];
    if (free.isNotEmpty) foods.add(free[_rnd.nextInt(free.length)]);
  }

  /// BFS a partir de [from]; devolve distâncias (-1 = inalcançável) e pais
  /// para reconstruir caminhos.
  ({List<int> dist, List<int> parent}) _bfs(Cell from, Set<int> blocked) {
    final n = cols * rows;
    final dist = List.filled(n, -1);
    final parent = List.filled(n, -1);
    final queue = <Cell>[from];
    dist[_index(from)] = 0;
    for (var head = 0; head < queue.length; head++) {
      final c = queue[head];
      final d = dist[_index(c)];
      for (final m in Move.values) {
        final next = c.step(m);
        if (!_inside(next)) continue;
        final i = _index(next);
        if (dist[i] >= 0 || blocked.contains(i)) continue;
        dist[i] = d + 1;
        parent[i] = _index(c);
        queue.add(next);
      }
    }
    return (dist: dist, parent: parent);
  }

  List<Cell> _path(List<int> parent, Cell to) {
    final path = <Cell>[];
    var i = _index(to);
    while (i >= 0) {
      path.add(Cell(i % cols, i ~/ cols));
      i = parent[i];
    }
    return path.reversed.toList();
  }

  /// Ordem de coleta que minimiza o caminho total.
  void _replan() {
    final head = snake.first;
    // A cauda sai do lugar no próximo passo; não é obstáculo.
    final blocked = {
      for (final c in snake.skip(1).take(snake.length - 2)) _index(c)
    };
    final fromHead = _bfs(head, blocked);
    final reachable = [
      for (final f in foods)
        if (fromHead.dist[_index(f)] >= 0) f,
    ];
    foodReachable = foods.isEmpty ? 1 : reachable.length / foods.length;
    if (reachable.isEmpty) {
      plan = const [];
      route = const [];
      return;
    }

    final fromFood = [for (final f in reachable) _bfs(f, blocked)];
    int d(int a, int b) {
      // a = -1 é a cabeça.
      final dist = a < 0 ? fromHead.dist : fromFood[a].dist;
      final v = dist[_index(reachable[b])];
      return v < 0 ? 1 << 20 : v;
    }

    final order = reachable.length <= 7
        ? _bruteForce(reachable.length, d)
        : _nearestThen2Opt(reachable.length, d);

    plan = [for (final i in order) reachable[i]];
    final path = <Cell>[];
    var parent = fromHead.parent;
    for (var k = 0; k < order.length; k++) {
      final leg = _path(parent, reachable[order[k]]);
      path.addAll(k == 0 ? leg : leg.skip(1));
      parent = fromFood[order[k]].parent;
    }
    route = path;
  }

  List<int> _bruteForce(int n, int Function(int, int) d) {
    var best = <int>[];
    var bestCost = 1 << 30;
    final used = List.filled(n, false);
    final current = <int>[];
    void search(int last, int cost) {
      if (cost >= bestCost) return;
      if (current.length == n) {
        bestCost = cost;
        best = List.of(current);
        return;
      }
      for (var i = 0; i < n; i++) {
        if (used[i]) continue;
        used[i] = true;
        current.add(i);
        search(i, cost + d(last, i));
        current.removeLast();
        used[i] = false;
      }
    }

    search(-1, 0);
    return best;
  }

  List<int> _nearestThen2Opt(int n, int Function(int, int) d) {
    final order = <int>[];
    final left = {for (var i = 0; i < n; i++) i};
    var last = -1;
    while (left.isNotEmpty) {
      final next = left.reduce((a, b) => d(last, a) <= d(last, b) ? a : b);
      order.add(next);
      left.remove(next);
      last = next;
    }
    int cost(List<int> o) {
      var c = 0;
      var prev = -1;
      for (final i in o) {
        c += d(prev, i);
        prev = i;
      }
      return c;
    }

    var improved = true;
    while (improved) {
      improved = false;
      for (var i = 0; i < n - 1; i++) {
        for (var j = i + 1; j < n; j++) {
          final candidate = [
            ...order.sublist(0, i),
            ...order.sublist(i, j + 1).reversed,
            ...order.sublist(j + 1),
          ];
          if (cost(candidate) < cost(order)) {
            order
              ..clear()
              ..addAll(candidate);
            improved = true;
          }
        }
      }
    }
    return order;
  }

  _Candidate? _evaluate(Move m, Cell? target, int d0) {
    if (snake.length > 1 && m == dir.opposite) return null;
    final head = snake.first.step(m);
    if (!_inside(head)) return null;
    final eats = foods.contains(head);
    final nextBody = [
      head,
      ...snake.take(eats ? snake.length : snake.length - 1),
    ];
    if (nextBody.skip(1).contains(head)) return null;

    final tail = nextBody.last;
    final blocked = {
      for (final c in nextBody.skip(1).take(nextBody.length - 2)) _index(c),
    };
    final bfs = _bfs(head, blocked);
    final area = bfs.dist.where((v) => v >= 0).length;
    final tailReachable = nextBody.length < 3 || bfs.dist[_index(tail)] >= 0;

    var progress = 0.0;
    if (target != null) {
      final dt = bfs.dist[_index(target)];
      progress = dt < 0 ? -1.5 : (d0 - dt).clamp(-1, 1).toDouble();
    }
    if (eats) progress += 1;
    final space = math.min(1.0, area / (nextBody.length * 1.2));

    return _Candidate(
      move: m,
      nextBody: nextBody,
      eats: eats,
      area: area,
      tailReachable: tailReachable,
      score: 2.6 * progress +
          2.2 * space +
          (tailReachable ? 0.9 : -1.2) +
          (m == dir ? 0.12 : 0), // leve preferência por seguir reto
    );
  }

  /// Um passo de jogo: planeja, avalia, decide e move.
  void step() {
    if (gameOver) return;
    tick++;
    _replan();

    final target = plan.isEmpty ? null : plan.first;
    final head = snake.first;
    var d0 = 0;
    if (target != null) {
      final blocked = {
        for (final c in snake.skip(1).take(snake.length - 2)) _index(c),
      };
      d0 = _bfs(head, blocked).dist[_index(target)];
    }

    final candidates = [
      for (final m in Move.values) _evaluate(m, target, d0),
    ].whereType<_Candidate>().toList();
    if (candidates.isEmpty) {
      gameOver = true;
      executing = null;
      return;
    }

    // Softmax com temperatura: notas próximas viram probabilidades próximas.
    const temperature = 0.55;
    final maxScore = candidates.map((c) => c.score).reduce(math.max);
    final weights = {
      for (final c in candidates)
        c.move: math.exp((c.score - maxScore) / temperature),
    };
    final total = weights.values.fold(0.0, (a, b) => a + b);
    probabilities = {
      for (final m in Move.values) m: (weights[m] ?? 0) / total,
    };

    final top = candidates.reduce((a, b) => a.score >= b.score ? a : b);
    var chosen = top;
    intervened = false;
    if (!top.safe) {
      // Segurança: prefere manter a cauda alcançável, depois mais espaço.
      final safest = candidates.reduce((a, b) {
        if (a.tailReachable != b.tailReachable) return a.tailReachable ? a : b;
        return a.area >= b.area ? a : b;
      });
      if (safest.move != top.move) {
        chosen = safest;
        intervened = true;
      }
    }

    final r = (1 - top.area / (top.nextBody.length * 2)).clamp(0.0, 1.0);
    deadEndRisk = top.tailReachable ? r * 0.6 : math.max(r, 0.7);

    snake = chosen.nextBody;
    dir = chosen.move;
    executing = chosen.move;
    if (chosen.eats) {
      foods.remove(snake.first);
      score++;
      if (foods.isEmpty) _spawnFood();
    }
    history.insert(0, MoveLog(tick, chosen.move, intervened));
    if (history.length > 6) history.removeLast();
    _replan();
  }
}
