import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/src/ai/laya_decision.dart';
import 'package:portfolio/src/utils/colors.dart';

class PortfolioActions {
  final VoidCallback goHome;
  final VoidCallback goAbout;
  final VoidCallback goProjects;
  final VoidCallback goSkills;
  final VoidCallback goContact;
  final VoidCallback toggleTheme;

  const PortfolioActions({
    required this.goHome,
    required this.goAbout,
    required this.goProjects,
    required this.goSkills,
    required this.goContact,
    required this.toggleTheme,
  });
}

class LayaCommandBar extends StatefulWidget {
  final PortfolioActions actions;
  final FocusNode focusNode;

  const LayaCommandBar({
    super.key,
    required this.actions,
    required this.focusNode,
  });

  @override
  State<LayaCommandBar> createState() => _LayaCommandBarState();
}

class _LayaCommandBarState extends State<LayaCommandBar> {
  final _controller = TextEditingController();
  final _engine = PortfolioLaya();
  LayaChoice _choice = const LayaChoice(
    id: 'idle',
    label: 'aguardando',
    confidence: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {
      _choice = _engine.classify(_controller.text);
    });
  }

  void _run() {
    switch (_choice.id) {
      case 'home':
        widget.actions.goHome();
      case 'about':
        widget.actions.goAbout();
      case 'projects':
        widget.actions.goProjects();
      case 'skills':
        widget.actions.goSkills();
      case 'contact':
        widget.actions.goContact();
      case 'theme':
        widget.actions.toggleTheme();
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _choice.confidence >= 0.45 &&
        _choice.id != 'unknown' &&
        _choice.id != 'idle';
    final width = (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 560.0);

    return SizedBox(
      width: width,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          label: 'Comando do portfólio. Ctrl K para focar.',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: widget.focusNode,
                controller: _controller,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) {
                  if (ready) _run();
                },
                style: TextStyle(
                  color: ColorsApp.letters(context),
                  fontSize: 16,
                ),
                cursorColor: ColorsApp.accent(context),
                decoration: InputDecoration(
                  hintText: 'Laya: ver projetos, falar comigo, tema escuro',
                  hintStyle: TextStyle(color: ColorsApp.muted(context)),
                  filled: true,
                  fillColor: ColorsApp.surface(context),
                  prefixIcon: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: ColorsApp.accent(context),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      'Ctrl + K',
                      style: TextStyle(
                        color: ColorsApp.muted(context),
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: ColorsApp.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: ColorsApp.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: ColorsApp.accent(context),
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              if (ready)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      _IntentChip(choice: _choice),
                      const Spacer(),
                      FilledButton(
                        onPressed: _run,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          backgroundColor: ColorsApp.accent(context),
                          foregroundColor: ColorsApp.onAccent(context),
                        ),
                        child: Text(_choice.label),
                      ),
                    ],
                  ),
                )
              else if (_controller.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsApp.surface(context),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ColorsApp.border(context)),
                      ),
                      child: Text(
                        'Tente: projetos, sobre, habilidades, contato, tema',
                        style: TextStyle(
                          color: ColorsApp.muted(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentChip extends StatelessWidget {
  final LayaChoice choice;

  const _IntentChip({required this.choice});

  @override
  Widget build(BuildContext context) {
    final percent = (choice.confidence * 100).round();
    return Semantics(
      label: 'Intenção ${choice.label}, confiança $percent por cento',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ColorsApp.accent(context).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: ColorsApp.accent(context).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          '${choice.label}  $percent%',
          style: TextStyle(
            color: ColorsApp.accent(context),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class OpenCommandBarIntent extends Intent {
  const OpenCommandBarIntent();
}

Map<ShortcutActivator, Intent> commandBarShortcuts() {
  return const {
    SingleActivator(LogicalKeyboardKey.keyK, control: true):
        OpenCommandBarIntent(),
    SingleActivator(LogicalKeyboardKey.keyK, meta: true):
        OpenCommandBarIntent(),
  };
}
