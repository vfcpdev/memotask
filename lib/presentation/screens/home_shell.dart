import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course.dart';
import '../bloc/agenda_bloc.dart';
import '../l10n/failure_localizer.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/course_form_dialog.dart';
import '../widgets/new_activity_fab.dart';
import '../widgets/user_name_dialog.dart';
import 'export_screen.dart';
import 'timeline_screen.dart';
import 'week_calendar_screen.dart';

/// Shell principal con navegación inferior y escucha global de feedback BLoC.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.tabTimeline, l10n.tabCalendar, l10n.tabExport];

    return BlocListener<AgendaBloc, AgendaState>(
      listenWhen: (prev, curr) =>
          (curr.failure != null && curr.failure != prev.failure) ||
          (curr.exportedFilePath != null &&
              curr.exportedFilePath != prev.exportedFilePath),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.failure != null) {
          messenger.showSnackBar(
            SnackBar(content: Text(localizeAgendaFailure(l10n, state.failure!))),
          );
        } else if (state.exportedFilePath != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(l10n.exportedSnackBar(state.exportedFilePath!)),
            ),
          );
        }
        context.read<AgendaBloc>().add(const AgendaFeedbackCleared());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[_index]),
          actions: [
            Builder(
              builder: (ctx) {
                final userName = ctx.select(
                  (AgendaBloc b) => b.state.userProfile?.name,
                );
                return IconButton(
                  tooltip: l10n.profileTooltip,
                  icon: Icon(
                    userName == null ? Icons.person_outline : Icons.person,
                  ),
                  onPressed: () => UserNameDialog.showAndSubmit(
                    ctx,
                    initialName: userName,
                  ),
                );
              },
            ),
            IconButton(
              tooltip: l10n.manageCourseTooltip,
              icon: const Icon(Icons.school_outlined),
              onPressed: () async {
                final course = await showDialog<Course>(
                  context: context,
                  builder: (_) => const CourseFormDialog(),
                );
                if (course != null && context.mounted) {
                  context.read<AgendaBloc>().add(AgendaCourseUpserted(course));
                }
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _index,
          children: [
            const TimelineScreen(),
            WeekCalendarScreen(
              onDayPicked: () => setState(() => _index = 0),
            ),
            const ExportScreen(),
          ],
        ),
        floatingActionButton: _index == 0 ? const NewActivityFab() : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.view_timeline_outlined),
              selectedIcon: const Icon(Icons.view_timeline),
              label: l10n.tabTimeline,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.tabCalendar,
            ),
            NavigationDestination(
              icon: const Icon(Icons.ios_share_outlined),
              selectedIcon: const Icon(Icons.ios_share),
              label: l10n.tabExport,
            ),
          ],
        ),
      ),
    );
  }
}
