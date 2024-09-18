import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';

class Contact extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const Contact({
    super.key,
    required this.constraints,
    required this.data,
    required BuildContext context,
  });

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = constraints.maxWidth > 480;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 200 : 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "|| Contato ||",
            style: GoogleFonts.aBeeZee(
              textStyle: TextStyle(
                fontSize: isLargeScreen ? 50 : constraints.maxWidth * .09,
                color: ColorsApp.letters(context),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (isLargeScreen)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: EmailForm(constraints: constraints, data: data),
                ),
                const SizedBox(width: 30),
                Expanded(
                    child: EmailInfo(constraints: constraints, data: data)),
              ],
            )
          else ...[
            EmailForm(constraints: constraints, data: data),
            const SizedBox(height: 35),
            EmailInfo(constraints: constraints, data: data),
          ],
        ],
      ),
    );
  }
}

class EmailInfo extends StatelessWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const EmailInfo({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Email para contato:",
          style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
              fontSize: constraints.maxWidth > 480 ? 30 : 20,
              color: ColorsApp.letters(context),
            ),
          ),
        ),
        Text(
          data["contact"] ?? "No contact info",
          style: GoogleFonts.aBeeZee(
            textStyle: TextStyle(
              fontSize: constraints.maxWidth > 480 ? 18 : 14,
              color: ColorsApp.letters(context),
            ),
          ),
        ),
      ],
    );
  }
}

class EmailForm extends StatefulWidget {
  final BoxConstraints constraints;
  final Map<String, dynamic> data;

  const EmailForm({
    super.key,
    required this.constraints,
    required this.data,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _senderEmailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _senderEmailHasError = false;
  bool _subjectHasError = false;
  bool _emailTextHasError = false;
  bool _nameHasError = false;

  InputDecoration _inputDecoration(String label, bool hasError) {
    return InputDecoration(
      hintStyle: TextStyle(color: ColorsApp.letters(context)),
      labelText: hasError ? null : label,
      labelStyle: TextStyle(
        color: ColorsApp.letters(context),
        fontSize: widget.constraints.maxWidth > 480 ? 16 : 11,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorsApp.border(context), width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorsApp.border(context), width: 2.0),
      ),
      errorStyle: TextStyle(
        fontSize: widget.constraints.maxWidth > 480 ? 12 : 10,
        color: Colors.red,
      ),
      hintMaxLines: 1,
      alignLabelWithHint: true,
    );
  }

  void _validateForm() {
    final formState = _formKey.currentState;
    if (formState != null) {
      setState(() {
        _senderEmailHasError = !_validateEmail(_senderEmailController.text);
        _subjectHasError = _subjectController.text.isEmpty;
        _emailTextHasError = _emailTextController.text.isEmpty;
        _nameHasError = _nameController.text.isEmpty;
      });

      if (formState.validate()) {
        _sendMessage();
      }
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> _sendMessage() async {
    final String emailContact = widget.data["contact"] ?? "";

    final String subject = _subjectController.text;
    final String emailText = _emailTextController.text;
    final String name = _nameController.text;

    final String mailtoUrl =
        'mailto:$emailContact?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent('$emailText\n\nFrom: $name')}';

    // ignore: deprecated_member_use
    if (await canLaunch(mailtoUrl)) {
      await launchUrl(Uri.parse(mailtoUrl));
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro ao enviar email"),
          content: const Text("Não foi possível abrir o cliente de email."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextFormField(
            "Nome",
            _nameController,
            _nameHasError,
            (value) => value == null || value.isEmpty
                ? 'Por favor, insira o seu nome'
                : null,
          ),
          const SizedBox(height: 10),
          _buildTextFormField(
            "Email do remetente",
            _senderEmailController,
            _senderEmailHasError,
            (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o email do remetente';
              }
              if (!_validateEmail(value)) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          _buildTextFormField(
            "Assunto",
            _subjectController,
            _subjectHasError,
            (value) => value == null || value.isEmpty
                ? 'Por favor, insira o assunto'
                : null,
          ),
          const SizedBox(height: 10),
          _buildTextFormField(
            "Texto do email",
            _emailTextController,
            _emailTextHasError,
            (value) => value == null || value.isEmpty
                ? 'Por favor, insira o texto do email'
                : null,
            maxLines: 6,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ButtonStyle(
              fixedSize: WidgetStateProperty.all<Size>(
                Size(
                  widget.constraints.maxWidth > 480 ? 600 : 300,
                  widget.constraints.maxWidth > 480 ? 35 : 18,
                ),
              ),
              backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.transparent),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side:
                      BorderSide(color: ColorsApp.border(context), width: 2.0),
                ),
              ),
              elevation: WidgetStateProperty.all<double>(0),
            ),
            onPressed: _validateForm,
            child: Text(
              'Enviar mensagem',
              style: TextStyle(color: ColorsApp.letters(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
    String label,
    TextEditingController controller,
    bool hasError,
    String? Function(String?)? validator, {
    int maxLines = 1,
  }) {
    return SizedBox(
      height: maxLines == 1
          ? widget.constraints.maxWidth > 480
              ? 70
              : 55
          : null,
      width: widget.constraints.maxWidth > 480 ? 600 : 300,
      child: TextFormField(
        style: TextStyle(
          color: ColorsApp.letters(context),
          fontSize: widget.constraints.maxWidth > 480 ? 13 : 11,
        ),
        controller: controller,
        decoration: _inputDecoration(label, hasError),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
