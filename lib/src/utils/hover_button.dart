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
  // ignore: library_private_types_in_public_api
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? ColorsApp.color4.withOpacity(0.2)
                          : Colors.transparent,
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: _isHovered
                    ? (constraints.maxWidth > 1050
                        ? widget.widthWeb + 6
                        : widget.widthMobile + 6)
                    : (constraints.maxWidth > 1050
                        ? widget.widthWeb
                        : widget.widthMobile),
                height: _isHovered
                    ? (constraints.maxWidth > 1050 ? 40 : 23)
                    : (constraints.maxWidth > 1050 ? 35 : 30),
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: WidgetStateProperty.all<Size>(Size(
                      constraints.maxWidth > 1050
                          ? widget.widthWeb
                          : widget.widthMobile,
                      constraints.maxWidth > 1050 ? 35 : 30,
                    )),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Colors.transparent),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: ColorsApp.color4, width: 2.0),
                      ),
                    ),
                    elevation: WidgetStateProperty.all<double>(0),
                  ),
                  onPressed: widget.onPressed,
                  child: widget.text,
                ),
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
