import 'package:flutter/material.dart';

class CustomCarouselSlider extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final bool enlargeCenterPage;
  final bool autoPlay;
  final Duration autoPlayAnimationDuration;
  final Curve autoPlayCurve;
  final double aspectRatio;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final CustomCarouselController controller;

  CustomCarouselSlider({
    super.key,
    required this.items,
    required this.height,
    this.enlargeCenterPage = false,
    this.autoPlay = false,
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.autoPlayCurve = Curves.easeInExpo,
    this.aspectRatio = 16 / 9,
    this.enableInfiniteScroll = true,
    this.viewportFraction = 0.8,
    CustomCarouselController? controller,
  }) : controller = controller ?? CustomCarouselController();

  @override
  // ignore: library_private_types_in_public_api
  _CustomCarouselSliderState createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  late PageController _pageController;
  late List<Widget> _items;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _items = widget.enableInfiniteScroll
        ? [
            widget.items.last,
            ...widget.items,
            widget.items.first,
          ]
        : widget.items;

    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: widget.viewportFraction,
    );
    widget.controller._attach(this);

    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoPlay();
      });
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayAnimationDuration, () {
      if (!mounted) return;
      nextPage();
      if (widget.autoPlay) {
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _items.length,
        onPageChanged: (index) {
          if (widget.enableInfiniteScroll) {
            if (index == 0) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _jumpToPage(_items.length - 2);
              });
            } else if (index == _items.length - 1) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _jumpToPage(1);
              });
            }
          }
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              } else if (index == _currentPage) {
                value = 1.0;
              } else {
                value = 0.7;
              }

              return Center(
                child: SizedBox(
                  height: Curves.easeOut.transform(value) * widget.height,
                  child: child,
                ),
              );
            },
            child: item,
          );
        },
      ),
    );
  }

  void _jumpToPage(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(index);
    });
  }

  void nextPage() {
    _pageController.animateToPage(
      _currentPage + 1,
      duration: widget.autoPlayAnimationDuration,
      curve: widget.autoPlayCurve,
    );
  }

  void previousPage() {
    _pageController.animateToPage(
      _currentPage - 1,
      duration: widget.autoPlayAnimationDuration,
      curve: widget.autoPlayCurve,
    );
  }
}

class CustomCarouselController {
  late _CustomCarouselSliderState _state;

  void _attach(_CustomCarouselSliderState state) {
    _state = state;
  }

  void nextPage() {
    _state.nextPage();
  }

  void previousPage() {
    _state.previousPage();
  }
}
