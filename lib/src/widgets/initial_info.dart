import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/src/utils/app_fonts.dart';
import 'package:portfolio/src/utils/colors.dart';
import 'package:portfolio/src/widgets/about_me.dart';
import 'package:portfolio/src/widgets/phone_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Logos já decodificados, para não refazer o base64 a cada build.
final _badgeCache = <String, TechBadge>{};

/// As tecnologias principais viram selos ao redor do celular, usando os
/// logos que já estão nas habilidades do banco.
List<TechBadge> _techBadges(Map<String, dynamic> data) {
  const preferred = ['Flutter', 'Firebase', 'Supabase', 'Kotlin'];
  final attributes = (data['attributes'] as List?) ?? const [];
  final badges = <TechBadge>[];
  for (final name in preferred) {
    for (final a in attributes) {
      if (a is! Map) continue;
      final title = '${a['title'] ?? ''}';
      final image = a['image'];
      if (!title.startsWith(name) || image is! String || image.isEmpty) {
        continue;
      }
      try {
        badges.add(
            _badgeCache[title] ??= (title: title, image: base64Decode(image)));
      } catch (_) {
        // Imagem inválida: o selo dessa tecnologia só não aparece.
      }
      break;
    }
  }
  return badges;
}

class InitialInfo extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final VoidCallback onViewProjects;
  final VoidCallback onContact;
  final Key? aboutKey;

  const InitialInfo({
    super.key,
    required this.constraints,
    required this.data,
    required this.onViewProjects,
    required this.onContact,
    this.aboutKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = constraints.maxWidth > 980;
    final horizontal = constraints.maxWidth > 1050
        ? 88.0
        : constraints.maxWidth > 480
            ? 40.0
            : 20.0;

    final info = HeroCopy(
      constraints: constraints,
      data: data,
      onViewProjects: onViewProjects,
      onContact: onContact,
      aboutKey: aboutKey,
    );
    final phone = PhoneViewer(
      constraints: constraints,
      badges: _techBadges(data),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        constraints.maxWidth > 480 ? 48 : 24,
        horizontal,
        24,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: info),
                const SizedBox(width: 16),
                phone,
              ],
            )
          : Column(
              children: [
                info,
                const SizedBox(height: 36),
                phone,
              ],
            ),
    );
  }
}

class HeroCopy extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;
  final VoidCallback onViewProjects;
  final VoidCallback onContact;
  final Key? aboutKey;

  const HeroCopy({
    super.key,
    required this.constraints,
    required this.data,
    required this.onViewProjects,
    required this.onContact,
    this.aboutKey,
  });

  @override
  Widget build(BuildContext context) {
    final wide = constraints.maxWidth > 480;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PORTFOLIO / MOBILE + WEB',
          style: TextStyle(
            color: ColorsApp.accent(context),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 18),
        _HeroName(name: data['name'] ?? 'João Neto', wide: wide),
        const SizedBox(height: 18),
        Occupation(constraints: constraints, data: data),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: onViewProjects,
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                backgroundColor: ColorsApp.accent(context),
                foregroundColor: ColorsApp.onAccent(context),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ver projetos'),
            ),
            OutlinedButton(
              onPressed: onContact,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: ColorsApp.letters(context),
                side: BorderSide(color: ColorsApp.border(context), width: 1.4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Falar comigo'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SocialNetwork(data: data),
        const SizedBox(height: 28),
        KeyedSubtree(
          key: aboutKey,
          child: _HeroAbout(constraints: constraints, data: data),
        ),
      ],
    );
  }
}

class _HeroName extends StatelessWidget {
  final String name;
  final bool wide;

  const _HeroName({required this.name, required this.wide});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : name;
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final size = wide ? 64.0 : 40.0;

    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: first,
              style: AppFonts.aBeeZee(
                textStyle: TextStyle(
                  fontSize: size,
                  height: 0.95,
                  fontWeight: FontWeight.w300,
                  color: ColorsApp.letters(context),
                  letterSpacing: -1.2,
                ),
              ),
            ),
            if (rest.isNotEmpty)
              TextSpan(
                text: '\n$rest',
                style: AppFonts.aBeeZee(
                  textStyle: TextStyle(
                    fontSize: size,
                    height: 0.95,
                    fontWeight: FontWeight.w700,
                    color: ColorsApp.letters(context),
                    letterSpacing: -1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SocialNetwork extends StatelessWidget {
  final Map<String, dynamic> data;

  const SocialNetwork({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final links = data['socialNetwork'] as List? ?? [];
    const icons = [EvaIcons.linkedinOutline, EvaIcons.githubOutline];
    const labels = ['LinkedIn', 'GitHub'];

    return Row(
      children: [
        for (var i = 0; i < links.length && i < icons.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.outlined(
              tooltip: labels[i],
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              style: IconButton.styleFrom(
                side: BorderSide(color: ColorsApp.border(context)),
                foregroundColor: ColorsApp.letters(context),
              ),
              icon: Icon(icons[i]),
              onPressed: () => launchUrl(Uri.parse('${links[i]}')),
            ),
          ),
      ],
    );
  }
}

class Occupation extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Occupation({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final text = data['occupation'] ?? 'Flutter developer';
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: ColorsApp.accent(context), width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: RepaintBoundary(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                textStyle: TextStyle(
                  fontFamily: 'ABeeZee',
                  fontSize: constraints.maxWidth > 480 ? 22 : 18,
                  height: 1.45,
                  color: ColorsApp.muted(context),
                ),
                speed: const Duration(milliseconds: 42),
              ),
            ],
            totalRepeatCount: 2,
            pause: const Duration(milliseconds: 2400),
          ),
        ),
      ),
    );
  }
}

class _HeroAbout extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const _HeroAbout({
    required this.constraints,
    required this.data,
  });

  // Atalhos visuais: quem lê pouco entende de cara com o que eu trabalho.
  static const _highlights = [
    (Icons.devices_rounded, 'Mobile e Web', 'Android, iOS, web e desktop'),
    (Icons.bolt_rounded, '~2 anos', 'em produção com Flutter e Firebase'),
    (Icons.sensors_rounded, 'Hardware', 'RFID, balanças, serial e BLE'),
    (Icons.school_rounded, 'Eng. de Software', 'iCEV · conclusão em 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre mim',
            style: AppFonts.aBeeZee(
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: ColorsApp.accent(context),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextAboutMe(constraints: constraints, data: data),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 10.0;
              // Duas colunas sempre que couber; uma só em telas muito estreitas.
              final columns = box.maxWidth >= 340 ? 2 : 1;
              final width = (box.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final (icon, title, subtitle) in _highlights)
                    SizedBox(
                      width: width,
                      child: _Highlight(
                        icon: icon,
                        title: title,
                        subtitle: subtitle,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Highlight({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorsApp.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsApp.border(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorsApp.accent(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: ColorsApp.accent(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: ColorsApp.letters(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: ColorsApp.muted(context),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
