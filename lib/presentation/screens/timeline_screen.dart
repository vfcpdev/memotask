import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/algorithms/day_schedule_index.dart';
import '../../domain/config/app_config.dart';
import '../bloc/agenda_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_design_tokens.dart';
import '../widgets/activity_card.dart';
import '../widgets/user_name_dialog.dart';

/// Vista Timeline escaneable con filtro por día O(1) y próxima prioridad O(1).
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;
    final today = DayScheduleIndex.normalizeDay(DateTime.now());

    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final visible = state.visibleActivities;
        final isAll = state.selectedDay == null;
        final isToday = state.selectedDay == today;
        final customDay = (!isAll && !isToday) ? state.selectedDay : null;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceMd,
                tokens.spaceSm,
                tokens.spaceMd,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: state.userProfile == null
                    ? ActionChip(
                        avatar: const Icon(Icons.person_add_outlined, size: 18),
                        label: Text(l10n.registerNamePrompt),
                        onPressed: () => UserNameDialog.showAndSubmit(context),
                      )
                    : ActionChip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(
                          l10n.greetingUser(state.userProfile!.name),
                        ),
                        onPressed: () => UserNameDialog.showAndSubmit(
                          context,
                          initialName: state.userProfile!.name,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.spaceMd,
                tokens.spaceSm,
                tokens.spaceMd,
                0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(l10n.filterAll),
                      selected: isAll,
                      onSelected: (_) => context
                          .read<AgendaBloc>()
                          .add(const AgendaDaySelected(null)),
                    ),
                    SizedBox(width: tokens.spaceSm),
                    ChoiceChip(
                      label: Text(l10n.filterToday),
                      selected: isToday,
                      onSelected: (_) => context
                          .read<AgendaBloc>()
                          .add(AgendaDaySelected(today)),
                    ),
                    if (customDay != null) ...[
                      SizedBox(width: tokens.spaceSm),
                      ChoiceChip(
                        label: Text(
                          DateFormat(AppConfig.weekHeaderPattern)
                              .format(customDay),
                        ),
                        selected: true,
                        onSelected: (_) => context
                            .read<AgendaBloc>()
                            .add(const AgendaDaySelected(null)),
                      ),
                    ],
                    if (state.nextUrgentActivity != null) ...[
                      SizedBox(width: tokens.spaceSm),
                      Chip(
                        avatar: const Icon(Icons.bolt, size: 16),
                        label: Text(
                          l10n.nextUrgentLabel(state.nextUrgentActivity!.title),
                        ),
                      ),
                    ],
                    if (state.conflictReport.conflicts.isNotEmpty) ...[
                      SizedBox(width: tokens.spaceSm),
                      Chip(
                        avatar: const Icon(Icons.warning_amber, size: 16),
                        label: Text(
                          l10n.conflictsBanner(
                            state.conflictReport.conflicts.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceLg),
                        child: Text(
                          l10n.emptyTimelineMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final activity = visible[i];
                        return ActivityCard(
                          activity: activity,
                          course: state.courses[activity.courseId],
                          onDelete: () => context.read<AgendaBloc>().add(
                                AgendaActivityDeleted(activity.id),
                              ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
