import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/platform/platform_bootstrap.dart';
import 'domain/repositories/export_gateway_interface.dart';
import 'domain/repositories/schedule_repository_interface.dart';
import 'domain/repositories/user_profile_repository_interface.dart';
import 'presentation/bloc/agenda_bloc.dart';
import 'presentation/l10n/generated/app_localizations.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/theme/app_theme.dart';

/// Composition Root: inyecta dependencias DIP y configura l10n + ThemeData.
class App extends StatelessWidget {
  final IScheduleRepository? repository;
  final IUserProfileRepository? userProfileRepository;
  final IExportGateway? exportGateway;
  final Locale? locale;

  const App({
    super.key,
    this.repository,
    this.userProfileRepository,
    this.exportGateway,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedRepository =
        repository ?? createDefaultScheduleRepository();
    final resolvedProfileRepository =
        userProfileRepository ?? createDefaultUserProfileRepository();
    final resolvedExportGateway =
        exportGateway ?? createDefaultExportGateway();

    return BlocProvider(
      create: (_) => AgendaBloc(
        repository: resolvedRepository,
        userProfileRepository: resolvedProfileRepository,
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
