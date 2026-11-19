import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/agenda_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/activity_create_adapter.dart';
import '../models/activity_draft.dart';
import '../screens/activity_form_modal.dart';

/// CTA primario flotante para agendar una nueva actividad.
class NewActivityFab extends StatelessWidget {
  const NewActivityFab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final courses = context.select(
      (AgendaBloc bloc) => bloc.state.courses.values.toList(growable: false),
    );

    return FloatingActionButton(
      tooltip: l10n.newActivityTooltip,
      onPressed: () async {
        final created = await showModalBottomSheet<ActivityDraft>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => ActivityFormModal(courses: courses),
        );
        if (created != null && context.mounted) {
          final activity = ActivityCreateAdapter.toDomain(
            created,
            const Uuid().v4(),
          );
          context.read<AgendaBloc>().add(AgendaActivityCreated(activity));
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
