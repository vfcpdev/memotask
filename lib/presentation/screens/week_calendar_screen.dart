import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/algorithms/day_schedule_index.dart';
import '../../domain/config/app_config.dart';
import '../bloc/agenda_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_design_tokens.dart';

/// Vista Calendario semanal con consulta O(1) por día desde [AgendaState].
class WeekCalendarScreen extends StatelessWidget {
  final VoidCallback? onDayPicked;

  const WeekCalendarScreen({super.key, this.onDayPicked});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;
    final localeName = Localizations.localeOf(context).languageCode;

    final today = DayScheduleIndex.normalizeDay(DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(
      AppConfig.calendarDaysInWeek,
      (i) => weekStart.add(Duration(days: i)),
    );

    final headerFmt = DateFormat(AppConfig.weekHeaderPattern, localeName);
    final shortFmt = DateFormat(AppConfig.weekDayShortPattern, localeName);
    final fullFmt = DateFormat(AppConfig.weekDayFullPattern, localeName);

    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Text(
                l10n.weekOfLabel(headerFmt.format(weekStart)),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: tokens.calendarGridColumns,
                padding: EdgeInsets.all(tokens.spaceSm + tokens.spaceXs),
                children: days.map((day) {
                  // Consulta O(1) en mapa pre-indexado por día.
                  final count = state.activitiesByDay[day]?.length ?? 0;
                  final selected = state.selectedDay == day;

                  return Card(
                    shape: selected
                        ? RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(tokens.radiusMd),
                            side: BorderSide(
                              color: tokens.accentLime,
                              width: tokens.focusBorderWidth,
                            ),
                          )
                        : null,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      onTap: () {
                        context.read<AgendaBloc>().add(AgendaDaySelected(day));
                        onDayPicked?.call();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(tokens.spaceSm),
                        child: Column(
                          children: [
                            Text(
                              shortFmt.format(day),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: tokens.spaceXs),
                            Expanded(
                              child: Center(
                                child: Text(
                                  l10n.activitiesCountShort(count),
                                  semanticsLabel: l10n.dayActivitiesSemantics(
                                    count,
                                    fullFmt.format(day),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        );
      },
    );
  }
}
