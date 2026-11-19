import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/config/app_config.dart';
import '../bloc/agenda_bloc.dart';
import '../l10n/generated/app_localizations.dart';

/// Diálogo modal unificado para registrar o actualizar el nombre del usuario.
class UserNameDialog extends StatefulWidget {
  final String? initialName;

  const UserNameDialog({super.key, this.initialName});

  /// Abre el diálogo y despacha [AgendaUserNameRegistered] al confirmar.
  static Future<void> showAndSubmit(
    BuildContext context, {
    String? initialName,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => UserNameDialog(initialName: initialName),
    );
    if (name != null && context.mounted) {
      context.read<AgendaBloc>().add(AgendaUserNameRegistered(name));
    }
  }

  @override
  State<UserNameDialog> createState() => _UserNameDialogState();
}

class _UserNameDialogState extends State<UserNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.userNameDialogTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameCtrl,
          maxLength: AppConfig.maxUserNameLength,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.userNameLabel),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? l10n.requiredFieldError
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelCta),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_nameCtrl.text.trim());
          },
          child: Text(l10n.saveNameCta),
        ),
      ],
    );
  }
}
