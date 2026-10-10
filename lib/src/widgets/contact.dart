import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:portfolio/src/widgets/section_heading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

// Contato no formato "book a demo": à esquerda, o que posso fazer e o e-mail
// direto; à direita, o formulário. No desktop as duas metades ficam numa
// moldura com bordas laterais e uma divisória entre elas.

/// O que o visitante pode esperar. Edite à vontade.
const _offers = [
  ('Apps mobile e web com Flutter, ', 'do protótipo à publicação'),
  ('Interfaces ', 'responsivas e acessíveis'),
  ('Integração com ', 'APIs, Firebase e serviços'),
  ('Melhorias de performance e manutenção de ', 'apps existentes'),
];

class Contact extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Contact({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final width = constraints.maxWidth;
    final split = width > 900;
    final horizontal = width > 1050
        ? 88.0
        : width > 480
            ? 40.0
            : 20.0;
    final border = BorderSide(color: ColorsApp.border(context));

    final info = Padding(
      padding: EdgeInsets.all(split ? 48 : 0),
      child: _ContactInfo(data: data),
    );
    final form = Padding(
      padding: EdgeInsets.all(split ? 48 : 0),
      child: _ContactForm(email: '${data["contact"] ?? ''}'),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        children: [
          const SectionHeading(
            index: '03',
            eyebrow: 'Contato',
            title: 'Vamos conversar',
            subtitle:
                'Tem um projeto, uma vaga ou uma ideia? Me conte um pouco '
                'e eu respondo assim que puder.',
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: split ? 1180 : 560),
            child: split
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(left: border, right: border),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: info),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: ColorsApp.border(context),
                          ),
                          Expanded(child: form),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      info,
                      const SizedBox(height: 32),
                      Divider(height: 1, color: ColorsApp.border(context)),
                      const SizedBox(height: 32),
                      form,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ContactInfo({required this.data});

  @override
  Widget build(BuildContext context) {
    final email = '${data["contact"] ?? ''}';
    final links = data['socialNetwork'] as List? ?? const [];
    // Opcional: só aparece se houver um campo "whatsapp" no banco (só dígitos,
    // com DDI, ex.: 5586999999999).
    final whatsapp =
        '${data['whatsapp'] ?? ''}'.replaceAll(RegExp(r'[^0-9]'), '');
    final text = TextStyle(
      color: ColorsApp.letters(context),
      fontSize: 15,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posso ajudar com:',
          style: text.copyWith(color: ColorsApp.muted(context)),
        ),
        const SizedBox(height: 20),
        for (final (lead, bold) in _offers)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: ColorsApp.accent(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: lead,
                      children: [
                        TextSpan(
                          text: bold,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    style: text,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 28),
        Text(
          'Prefere escrever direto?',
          style: TextStyle(
            color: ColorsApp.letters(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        if (email.isNotEmpty) _EmailCard(email: email),
        const SizedBox(height: 14),
        // Atalhos para quem prefere não preencher o formulário.
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            if (email.isNotEmpty)
              _QuickAction(
                icon: Icons.mail_outline_rounded,
                label: 'Escrever pelo Gmail',
                url: _gmailCompose(email),
              ),
            if (whatsapp.isNotEmpty)
              _QuickAction(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                url: Uri.https('wa.me', '/$whatsapp'),
              ),
            for (var i = 0; i < links.length && i < 2; i++)
              _QuickAction(
                icon:
                    i == 0 ? EvaIcons.linkedinOutline : EvaIcons.githubOutline,
                label: i == 0 ? 'LinkedIn' : 'GitHub',
                url: Uri.parse('${links[i]}'),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Uri url;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        foregroundColor: ColorsApp.letters(context),
        side: BorderSide(color: ColorsApp.border(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// O e-mail em destaque, com atalho para copiar.
class _EmailCard extends StatefulWidget {
  final String email;

  const _EmailCard({required this.email});

  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.email));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: ColorsApp.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsApp.border(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.mail_outline_rounded,
              size: 20, color: ColorsApp.accent(context)),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              widget.email,
              maxLines: 1,
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _copy,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
              foregroundColor: _copied
                  ? ColorsApp.accent(context)
                  : ColorsApp.muted(context),
            ),
            icon: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 16,
            ),
            label: Text(_copied ? 'Copiado' : 'Copiar'),
          ),
        ],
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  final String email;

  const _ContactForm({required this.email});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

enum _SendState { idle, sending, sent, failed }

/// Links prontos para escrever por fora do formulário.
Uri _gmailCompose(String to, {String subject = '', String body = ''}) =>
    Uri.https('mail.google.com', '/mail/', {
      'view': 'cm',
      'fs': '1',
      'to': to,
      if (subject.isNotEmpty) 'su': subject,
      if (body.isNotEmpty) 'body': body,
    });

Uri _mailto(String to, {String subject = '', String body = ''}) => Uri(
      scheme: 'mailto',
      path: to,
      query: [
        if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
        if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
      ].join('&'),
    );

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sender = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  _SendState _state = _SendState.idle;

  @override
  void dispose() {
    _name.dispose();
    _sender.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String get _body =>
      '${_message.text.trim()}\n\n— ${_name.text.trim()} (${_sender.text.trim()})';

  /// Envia direto para o meu e-mail pelo FormSubmit (sem backend e sem
  /// depender de um app de e-mail configurado). Antes, o "mailto" no
  /// navegador não fazia nada para quem não tinha um cliente de e-mail, e
  /// a pessoa ficava sem saber se a mensagem tinha ido.
  Future<void> _submit() async {
    if (_state == _SendState.sending) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _state = _SendState.sending);

    try {
      final response = await http
          .post(
            Uri.https('formsubmit.co', '/ajax/${widget.email}'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': _name.text.trim(),
              'email': _sender.text.trim(),
              'message': _message.text.trim(),
              '_subject': 'Portfólio: ${_subject.text.trim()}',
              '_replyto': _sender.text.trim(),
              '_template': 'table',
              '_captcha': 'false',
            }),
          )
          .timeout(const Duration(seconds: 15));
      final ok = response.statusCode == 200 &&
          '${(jsonDecode(response.body) as Map)['success']}' == 'true';
      if (!mounted) return;
      setState(() => _state = ok ? _SendState.sent : _SendState.failed);
    } catch (_) {
      if (mounted) setState(() => _state = _SendState.failed);
    }
  }

  void _reset() {
    for (final c in [_name, _sender, _subject, _message]) {
      c.clear();
    }
    setState(() => _state = _SendState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _state == _SendState.sent
          ? _SentPanel(
              key: const ValueKey('sent'),
              name: _name.text.trim(),
              replyTo: _sender.text.trim(),
              onAnother: _reset,
            )
          : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    final sending = _state == _SendState.sending;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Field(
            label: 'Nome',
            hint: 'Como posso te chamar?',
            controller: _name,
            autofill: AutofillHints.name,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Informe o seu nome' : null,
          ),
          _Field(
            label: 'E-mail',
            hint: 'voce@exemplo.com',
            controller: _sender,
            keyboard: TextInputType.emailAddress,
            autofill: AutofillHints.email,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Informe o seu e-mail';
              if (!_emailPattern.hasMatch(value)) {
                return 'Esse e-mail não parece válido';
              }
              return null;
            },
          ),
          _Field(
            label: 'Assunto',
            hint: 'Projeto, vaga, parceria…',
            controller: _subject,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Informe o assunto' : null,
          ),
          _Field(
            label: 'Mensagem',
            hint: 'Conte um pouco sobre o que você precisa',
            controller: _message,
            maxLines: 6,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Escreva a sua mensagem' : null,
          ),
          if (_state == _SendState.failed)
            _FailedBanner(
              gmail: _gmailCompose(
                widget.email,
                subject: _subject.text.trim(),
                body: _body,
              ),
              mailto: _mailto(
                widget.email,
                subject: _subject.text.trim(),
                body: _body,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'A mensagem chega direto no meu e-mail e eu respondo no endereço '
            'que você informar.',
            style: TextStyle(
              color: ColorsApp.muted(context),
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: sending ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: ColorsApp.accent(context),
              foregroundColor: ColorsApp.onAccent(context),
              disabledBackgroundColor:
                  ColorsApp.accent(context).withValues(alpha: 0.6),
              disabledForegroundColor: ColorsApp.onAccent(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (sending) ...[
                  SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: ColorsApp.onAccent(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(sending ? 'Enviando…' : 'Enviar mensagem'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Confirmação de envio: a pessoa precisa saber que a mensagem chegou.
class _SentPanel extends StatelessWidget {
  final String name;
  final String replyTo;
  final VoidCallback onAnother;

  const _SentPanel({
    super.key,
    required this.name,
    required this.replyTo,
    required this.onAnother,
  });

  @override
  Widget build(BuildContext context) {
    final first = name.split(' ').first;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: ColorsApp.surface(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ColorsApp.accent(context).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ColorsApp.accent(context).withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 30,
                color: ColorsApp.accent(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mensagem enviada!',
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Obrigado${first.isEmpty ? '' : ', $first'}. Recebi sua mensagem '
              'e vou responder em $replyTo assim que puder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorsApp.muted(context),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onAnother,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: ColorsApp.letters(context),
                side: BorderSide(color: ColorsApp.border(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Enviar outra mensagem'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Se o envio falhar, a mensagem não se perde: dá para mandar pelo Gmail ou
/// pelo app de e-mail com tudo já preenchido.
class _FailedBanner extends StatelessWidget {
  final Uri gmail;
  final Uri mailto;

  const _FailedBanner({required this.gmail, required this.mailto});

  @override
  Widget build(BuildContext context) {
    const error = Color(0xFFDC2626);
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: error.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Não consegui enviar agora. Sua mensagem continua aqui; '
              'você pode mandar por um destes:',
              style: TextStyle(
                color: ColorsApp.letters(context),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      launchUrl(gmail, mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Abrir no Gmail'),
                ),
                OutlinedButton.icon(
                  onPressed: () => launchUrl(mailto),
                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                  label: const Text('App de e-mail'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Rótulo acima do campo, como nos formulários do shadcn.
class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final int maxLines;
  final TextInputType? keyboard;
  final String? autofill;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.maxLines = 1,
    this.keyboard,
    this.autofill,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder outline(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );
    const error = Color(0xFFDC2626);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ColorsApp.letters(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            keyboardType: maxLines > 1 ? TextInputType.multiline : keyboard,
            autofillHints: autofill == null ? null : [autofill!],
            cursorColor: ColorsApp.accent(context),
            style: TextStyle(color: ColorsApp.letters(context), fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: ColorsApp.muted(context)),
              filled: true,
              fillColor: ColorsApp.background(context),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: outline(ColorsApp.border(context)),
              enabledBorder: outline(ColorsApp.border(context)),
              focusedBorder: outline(ColorsApp.accent(context), 1.6),
              errorBorder: outline(error),
              focusedErrorBorder: outline(error, 1.6),
              errorStyle: const TextStyle(color: error, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
