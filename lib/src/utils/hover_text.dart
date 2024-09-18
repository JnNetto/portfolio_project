import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // ignore: library_private_types_in_public_api
  _HoverTextState createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _isHovered = false;
  double _width = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          setState(() {
            _width = renderBox.size.width;
          });
        });

        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: widget.onPressed,
                child: Text(widget.text,
                    style: GoogleFonts.aBeeZee(
                        textStyle: TextStyle(
                            color: widget.lettersColor,
                            fontSize: widget.fontSize))),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                width: _isHovered ? _width : 0,
                color: ColorsApp.hoverButton(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
