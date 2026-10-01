import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/colors.dart';

class HoverButton extends StatefulWidget {
  final Widget text;
  final VoidCallback onPressed;
  final double widthMobile;
  final double widthWeb;
  final BoxConstraints constraints;

  const HoverButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.widthMobile,
    required this.widthWeb,
    required this.constraints,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isWide = widget.constraints.maxWidth > 480;
    final width = isWide ? widget.widthWeb : widget.widthMobile;
    final height = isWide ? 35.0 : 30.0;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? ColorsApp.border(context).withValues(alpha: 0.2)
                  : Colors.transparent,
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        width: _isHovered ? width + 6 : width,
        height: _isHovered ? height + 5 : height,
        alignment: Alignment.center,
        child: ElevatedButton(
          style: ButtonStyle(
            fixedSize: WidgetStateProperty.all<Size>(Size(width, height)),
            backgroundColor:
                WidgetStateProperty.all<Color>(Colors.transparent),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
                side: BorderSide(color: ColorsApp.border(context), width: 2.0),
              ),
            ),
            elevation: WidgetStateProperty.all<double>(0),
          ),
          onPressed: widget.onPressed,
          child: widget.text,
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
