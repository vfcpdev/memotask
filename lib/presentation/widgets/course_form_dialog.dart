import 'package:flutter/material.dart';

import '../../domain/entities/course.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_design_tokens.dart';

/// Diálogo modal unificado para registrar o actualizar un curso académico.
class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({super.key});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _professorCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _professorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;

    return AlertDialog(
      title: Text(l10n.newCourseTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _idCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(labelText: l10n.courseIdLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.requiredFieldError
                  : null,
            ),
            SizedBox(height: tokens.spaceSm),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: l10n.courseNameLabel),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.requiredFieldError
                  : null,
            ),
            SizedBox(height: tokens.spaceSm),
            TextFormField(
              controller: _professorCtrl,
              decoration: InputDecoration(labelText: l10n.courseProfessorLabel),
            ),
          ],
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
            Navigator.of(context).pop(
              Course.create(
                id: _idCtrl.text,
                name: _nameCtrl.text,
                professor: _professorCtrl.text,
              ),
            );
          },
          child: Text(l10n.saveCourseCta),
        ),
      ],
    );
  }
}
