import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/config/app_config.dart';
import '../../domain/entities/course.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/activity_draft.dart';
import '../theme/app_design_tokens.dart';

/// Modal de captura de nueva actividad unificado con tokens y l10n.
class ActivityFormModal extends StatefulWidget {
  final List<Course> courses;

  const ActivityFormModal({super.key, this.courses = const []});

  @override
  State<ActivityFormModal> createState() => _ActivityFormModalState();
}

class _ActivityFormModalState extends State<ActivityFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _courseCtrl = TextEditingController();
  late DateTime _start;
  late DateTime _end;
  int _priority = AppConfig.defaultPriority;
  bool _reminder = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = now.add(AppConfig.defaultInitialLead);
    _end = _start.add(AppConfig.defaultActivityDuration);
    if (widget.courses.isNotEmpty) {
      _courseCtrl.text = widget.courses.first.id;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _courseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final base = isStart ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(AppConfig.pickerMinYear),
      lastDate: DateTime(AppConfig.pickerMaxYear),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null || !mounted) return;
    setState(() {
      final picked = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (isStart) {
        _start = picked;
        if (!_end.isAfter(_start)) {
          _end = _start.add(AppConfig.defaultActivityDuration);
        }
      } else {
        _end = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;
    final fmt = DateFormat(AppConfig.dateTimePattern);
    final gap = SizedBox(height: tokens.spaceSm + tokens.spaceXs);

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.spaceMd,
        right: tokens.spaceMd,
        top: tokens.spaceMd,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.spaceMd,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.newActivityTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gap,
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l10n.titleLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.requiredFieldError
                    : null,
              ),
              gap,
              if (widget.courses.isNotEmpty) ...[
                Wrap(
                  spacing: tokens.spaceSm,
                  children: widget.courses
                      .map(
                        (course) => ActionChip(
                          label: Text(course.id),
                          onPressed: () =>
                              setState(() => _courseCtrl.text = course.id),
                        ),
                      )
                      .toList(growable: false),
                ),
                SizedBox(height: tokens.spaceSm),
              ],
              TextFormField(
                controller: _courseCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.courseIdLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.requiredFieldError
                    : null,
              ),
              gap,
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(labelText: l10n.descriptionLabel),
              ),
              gap,
              OutlinedButton(
                onPressed: () => _pickDate(true),
                child: Text(l10n.startLabel(fmt.format(_start))),
              ),
              SizedBox(height: tokens.spaceSm),
              OutlinedButton(
                onPressed: () => _pickDate(false),
                child: Text(l10n.endLabel(fmt.format(_end))),
              ),
              gap,
              DropdownButtonFormField<int>(
                initialValue: _priority,
                decoration: InputDecoration(labelText: l10n.priorityLabel),
                items: [
                  DropdownMenuItem(value: 1, child: Text(l10n.priorityHigh)),
                  DropdownMenuItem(value: 2, child: Text(l10n.priorityMedium)),
                  DropdownMenuItem(value: 3, child: Text(l10n.priorityLow)),
                ],
                onChanged: (v) =>
                    setState(() => _priority = v ?? AppConfig.defaultPriority),
              ),
              SwitchListTile(
                title: Text(l10n.reminderLabel),
                value: _reminder,
                onChanged: (v) => setState(() => _reminder = v),
              ),
              gap,
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  if (!_start.isBefore(_end)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invalidTimeRangeError)),
                    );
                    return;
                  }
                  Navigator.of(context).pop(
                    ActivityDraft(
                      courseId: _courseCtrl.text.trim().toUpperCase(),
                      title: _titleCtrl.text.trim(),
                      description: _descCtrl.text.trim(),
                      start: _start,
                      end: _end,
                      priority: _priority,
                      reminderEnabled: _reminder,
                    ),
                  );
                },
                child: Text(l10n.scheduleCta),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
