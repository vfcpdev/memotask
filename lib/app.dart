import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/app_database.dart';
import 'data/repositories/drift_schedule_repository.dart';
import 'data/services/local_export_gateway.dart';
import 'domain/repositories/export_gateway_interface.dart';
import 'domain/repositories/schedule_repository_interface.dart';
import 'presentation/bloc/agenda_bloc.dart';
import 'presentation/l10n/generated/app_localizations.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/theme/app_theme.dart';

/// Composition Root: inyecta dependencias DIP y configura l10n + ThemeData.
class App extends StatelessWidget {
  final AppDatabase? db;
  final IScheduleRepository? repository;
  final IExportGateway? exportGateway;
  final Locale? locale;

  const App({
    super.key,
    this.db,
    this.repository,
    this.exportGateway,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedRepository =
        repository ?? DriftScheduleRepository(db ?? AppDatabase());
    final resolvedExportGateway = exportGateway ?? LocalExportGateway();

    return BlocProvider(
      create: (_) => AgendaBloc(
        repository: resolvedRepository,
        exportGateway: resolvedExportGateway,
      )..add(const AgendaLoaded()),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme(),
        home: const HomeShell(),
      ),
    );
  }
}
