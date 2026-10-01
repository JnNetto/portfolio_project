import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';

class HoverText extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color lettersColor;
  final double? fontSize;

  const HoverText({
    super.key,
    required this.text,
    required this.onPressed,
    required this.lettersColor,
    required this.fontSize,
  });

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: TextButton(
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: AppFonts.aBeeZee(
            textStyle: TextStyle(
              color: widget.lettersColor,
              fontSize: widget.fontSize,
              decoration: _isHovered
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: ColorsApp.hoverButton(context),
              decorationThickness: 2,
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    if (_isHovered == isHovered) return;
    setState(() {
      _isHovered = isHovered;
    });
  }
}
