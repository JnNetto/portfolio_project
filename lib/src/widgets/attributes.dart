import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/src/utils/hover_button.dart';
import '../utils/colors.dart';

class Attributes extends StatefulWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final GlobalKey attributeKey;

  const Attributes({
    super.key,
    required this.constraints,
    required this.data,
    required this.attributeKey,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AttributesState createState() => _AttributesState();
}

class _AttributesState extends State<Attributes> {
  bool _isExpanded = false;
  double totalHeightCards = 0;
  List<Uint8List> _decodedImages = [];
  List<GlobalKey> _cardKeys = [];

  @override
  void initState() {
    super.initState();
    _decodedImages = widget.data["attributes"]
        .map<Uint8List>((attribute) => base64Decode(attribute["image"]))
        .toList();
    _cardKeys =
        List.generate(widget.data["attributes"].length, (index) => GlobalKey());
  }

  void _calculateTotalHeight() {
    double height = 0;
    for (var key in _cardKeys) {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        height += renderBox.size.height;
      }
    }
    setState(() {
      totalHeightCards = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxHeightEffect = widget.constraints.maxWidth > 480 ? 300 : 250;
    double maxSizeCard = widget.constraints.maxWidth > 480 ? 180 : 100;
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            TitleAtributtes(constraints: widget.constraints),
            _AttributesList(
              constraints: widget.constraints,
              data: widget.data,
              isExpanded: _isExpanded,
              maxHeightEffect: maxHeightEffect,
              maxSizeCard: maxSizeCard,
              cardKeys: _cardKeys,
              decodedImages: _decodedImages,
              calculateTotalHeight: _calculateTotalHeight,
              toggleExpansion: _toggleExpansion,
              totalHeightCards: totalHeightCards,
              attributeKey: widget.attributeKey,
            ),
          ],
        ),
      );
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded && totalHeightCards == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTotalHeight();
      });
    }
  }
}

class _AttributesList extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final bool isExpanded;
  final double maxHeightEffect;
  final double maxSizeCard;
  final List<GlobalKey> cardKeys;
  final List<Uint8List> decodedImages;
  final Function calculateTotalHeight;
  final Function toggleExpansion;
  final double totalHeightCards;
  final GlobalKey attributeKey;

  const _AttributesList({
    required this.constraints,
    required this.data,
    required this.isExpanded,
    required this.maxHeightEffect,
    required this.maxSizeCard,
    required this.cardKeys,
    required this.decodedImages,
    required this.calculateTotalHeight,
    required this.toggleExpansion,
    required this.totalHeightCards,
    required this.attributeKey,
  });

  @override
  Widget build(BuildContext context) {
    List<Map> habilidades = List<Map>.from(data["attributes"]);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      constraints: isExpanded
          ? BoxConstraints(
              maxHeight: constraints.maxWidth > 480
                  ? totalHeightCards + 20 + (habilidades.length * 10)
                  : totalHeightCards + 15 + (habilidades.length * 10),
            )
          : BoxConstraints(
              maxHeight: maxHeightEffect,
            ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: habilidades.asMap().entries.map<Widget>((entry) {
                int index = entry.key;
                Map habilidade = entry.value;
                return _AttributeCard(
                  index: index,
                  attribute: habilidade,
                  constraints: constraints,
                  cardKey: cardKeys[index],
                  image: decodedImages[index],
                );
              }).toList(),
            ),
          ),
          _GradientEffect(
            constraints: constraints,
            isExpanded: isExpanded,
            maxHeightEffect: maxHeightEffect,
            maxSizeCard: maxSizeCard,
            dataLength: habilidades.length,
          ),
          _ShowMoreButton(
            isExpanded: isExpanded,
            toggleExpansion: toggleExpansion,
            constraints: constraints,
            totalHeightCards: totalHeightCards,
            attributeKey: attributeKey,
          ),
          _ShowLessButton(
            isExpanded: isExpanded,
            toggleExpansion: toggleExpansion,
            constraints: constraints,
            attributeKey: attributeKey,
          ),
        ],
      ),
    );
  }
}

class _AttributeCard extends StatelessWidget {
  final int index;
  final Map attribute;
  final BoxConstraints constraints;
  final GlobalKey cardKey;
  final Uint8List image;

  const _AttributeCard({
    required this.index,
    required this.attribute,
    required this.constraints,
    required this.cardKey,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 480
              ? constraints.maxWidth > 1050
                  ? 200
                  : 100
              : 50),
      child: LayoutBuilder(builder: (context, constraints) {
        return Card(
          key: cardKey,
          elevation: 40,
          color: ColorsApp.background,
          margin: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.memory(
                  image,
                  width: constraints.maxWidth > 480 ? 150 : 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(attribute['title']!,
                          style: TextStyle(
                              fontSize: constraints.maxWidth > 480 ? 22 : 20,
                              color: ColorsApp.letters)),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, right: 10),
                      child: Text(attribute['description']!,
                          style: TextStyle(
                              fontSize: constraints.maxWidth > 480 ? 16 : 14,
                              color: ColorsApp.letters)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  final bool isExpanded;
  final Function toggleExpansion;
  final BoxConstraints constraints;
  final double totalHeightCards;
  final GlobalKey attributeKey;

  const _ShowMoreButton({
    required this.isExpanded,
    required this.toggleExpansion,
    required this.constraints,
    required this.totalHeightCards,
    required this.attributeKey,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Visibility(
        visible: !isExpanded,
        child: HoverButton(
          text: const Text(
            "Exibir mais",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            toggleExpansion();
            if (totalHeightCards == 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 475), () {
                  if (attributeKey.currentContext != null) {
                    Scrollable.ensureVisible(attributeKey.currentContext!,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut);
                  }
                });
              });
            }
          },
          widthMobile: 130,
          widthWeb: 150,
          constraints: constraints,
        ),
      ),
    );
  }
}

class _ShowLessButton extends StatelessWidget {
  final bool isExpanded;
  final Function toggleExpansion;
  final BoxConstraints constraints;
  final GlobalKey attributeKey;

  const _ShowLessButton({
    required this.isExpanded,
    required this.toggleExpansion,
    required this.constraints,
    required this.attributeKey,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isExpanded,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: HoverButton(
            text: const Text(
              "Exibir menos",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              toggleExpansion();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 475), () {
                  if (attributeKey.currentContext != null) {
                    Scrollable.ensureVisible(attributeKey.currentContext!,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut);
                  }
                });
              });
            },
            widthMobile: 150,
            widthWeb: 150,
            constraints: constraints,
          ),
        ),
      ),
    );
  }
}

class TitleAtributtes extends StatelessWidget {
  final BoxConstraints constraints;

  const TitleAtributtes({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: constraints.maxWidth > 480 ? 60 : 40),
      child: Text("|| Habilidades ||",
          style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                  fontSize: constraints.maxWidth > 480
                      ? 50
                      : constraints.maxWidth * .09,
                  color: ColorsApp.letters))),
    );
  }
}

class _GradientEffect extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isExpanded;
  final double maxHeightEffect;
  final double maxSizeCard;
  final int dataLength;

  const _GradientEffect({
    required this.constraints,
    required this.isExpanded,
    required this.maxHeightEffect,
    required this.maxSizeCard,
    required this.dataLength,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isExpanded && dataLength * maxSizeCard > maxHeightEffect,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 480
                ? constraints.maxWidth > 1050
                    ? 200
                    : 100
                : 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: constraints.maxWidth > 480 ? 50 : 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  ColorsApp.background.withOpacity(0.09),
                  ColorsApp.background.withOpacity(0.19),
                  ColorsApp.background.withOpacity(0.29),
                  ColorsApp.background.withOpacity(0.39),
                  ColorsApp.background.withOpacity(0.49),
                  ColorsApp.background.withOpacity(0.59),
                  ColorsApp.background.withOpacity(0.69),
                  ColorsApp.background.withOpacity(0.79),
                  ColorsApp.background.withOpacity(0.89),
                  ColorsApp.background.withOpacity(0.99),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
