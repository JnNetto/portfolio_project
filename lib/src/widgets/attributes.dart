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
    _decodeImages();
    _initializeKeys();
  }

  void _initializeKeys() {
    _cardKeys =
        List.generate(widget.data["attributes"].length, (index) => GlobalKey());
  }

  void _decodeImages() {
    _decodedImages = widget.data["attributes"]
        .map<Uint8List>((attribute) => base64Decode(attribute["image"]))
        .toList();
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
    double maxHeightEffect = widget.constraints.maxWidth > 1050 ? 300 : 250;
    double maxSizeCard = widget.constraints.maxWidth > 1050 ? 180 : 100;
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            title(),
            listViewAtributtes(widget.constraints, widget.data, _isExpanded,
                maxHeightEffect, maxSizeCard),
          ],
        ),
      );
    });
  }

  Widget attributesList(BoxConstraints constraints,
      {required Map<String, dynamic> project}) {
    List<Map> habilidades = List<Map>.from(project["attributes"]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: habilidades.asMap().entries.map((entry) {
        int index = entry.key;
        Map habilidade = entry.value;
        return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 1050 ? 200 : 50),
            child: LayoutBuilder(builder: (context, constraints) {
              return Card(
                key: _cardKeys[index],
                elevation: 40,
                color: ColorsApp.background,
                margin: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  children: [
                    image(index, constraints),
                    const SizedBox(width: 10),
                    texts(habilidade, constraints)
                  ],
                ),
              );
            }));
      }).toList(),
    );
  }

  Widget title() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: widget.constraints.maxWidth > 1050 ? 60 : 40),
      child: Text("|| Habilidades ||",
          style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                  fontSize: widget.constraints.maxWidth > 1050 ? 50 : 40,
                  color: ColorsApp.letters))),
    );
  }

  Widget listViewAtributtes(
      BoxConstraints constraints,
      Map<String, dynamic> data,
      bool isExpanded,
      double maxHeightEffect,
      double maxSizeCard) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      constraints: _isExpanded
          ? BoxConstraints(
              maxHeight: widget.constraints.maxWidth > 1050
                  ? (totalHeightCards) +
                      20 +
                      (widget.data["attributes"].length * 10)
                  : (totalHeightCards) +
                      15 +
                      (widget.data["attributes"].length * 10),
            )
          : BoxConstraints(
              maxHeight: maxHeightEffect,
            ),
      child: Stack(
        children: [
          listView(constraints, data),
          gradientEffect(
              constraints, data, isExpanded, maxHeightEffect, maxSizeCard),
          showMoreButton(
              constraints, data, isExpanded, maxHeightEffect, maxSizeCard),
          showLessButton(constraints, isExpanded),
        ],
      ),
    );
  }

  listView(BoxConstraints constraints, Map<String, dynamic> data) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: attributesList(widget.constraints, project: widget.data),
    );
  }

  showLessButton(BoxConstraints constraints, bool isExpanded) {
    return Visibility(
      visible: _isExpanded,
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
                  setState(() {
                    _isExpanded = false;
                  });
                  final context = widget.attributeKey.currentContext!;
                  Scrollable.ensureVisible(context,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut);
                },
                widthMobile: 150,
                widthWeb: 150,
                constraints: constraints)),
      ),
    );
  }

  Widget gradientEffect(BoxConstraints constraints, Map<String, dynamic> data,
      bool isExpanded, double maxHeightEffect, double maxSizeCard) {
    return Visibility(
      visible: !_isExpanded &&
          widget.data["attributes"].length * maxSizeCard > maxHeightEffect,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.constraints.maxWidth > 1050 ? 200 : 50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: widget.constraints.maxWidth > 1050 ? 50 : 200,
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

  Widget showMoreButton(BoxConstraints constraints, Map<String, dynamic> data,
      bool isExpanded, double maxHeightEffect, double maxSizeCard) {
    return Visibility(
      visible: !_isExpanded &&
          widget.data["attributes"].length * maxSizeCard > maxHeightEffect,
      child: Align(
          alignment: Alignment.bottomCenter,
          child: HoverButton(
              text: const Text(
                "Exibir mais",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (totalHeightCards == 0) {
                  _calculateTotalHeight();
                }
                setState(() {
                  _isExpanded = true;
                });
              },
              widthMobile: 130,
              widthWeb: 150,
              constraints: constraints)),
    );
  }

  image(int index, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Image.memory(
        _decodedImages[index],
        width: constraints.maxWidth > 1050 ? 150 : 70,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget texts(Map habilidade, BoxConstraints constraints) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(habilidade['title']!,
                style: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 22 : 20,
                    color: ColorsApp.letters)),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: Text(habilidade['description']!,
                style: TextStyle(
                    fontSize: constraints.maxWidth > 1050 ? 16 : 14,
                    color: ColorsApp.letters)),
          ),
        ],
      ),
    );
  }
}
