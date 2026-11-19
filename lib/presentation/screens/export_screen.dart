import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/config/app_config.dart';
import '../bloc/agenda_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_design_tokens.dart';

/// Vista de exportación con jerarquía clara: 1 CTA primario (.ics) y 1 secundario (.csv).
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;

    return BlocBuilder<AgendaBloc, AgendaState>(
      builder: (context, state) {
        final count = state.activities.length;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.exportTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: tokens.spaceSm),
                Text(
                  l10n.exportCount(count),
                  semanticsLabel: l10n.exportCountSemantics(count),
                ),
                SizedBox(height: tokens.spaceLg),
                FilledButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(l10n.exportIcsCta),
                  onPressed: count == 0
                      ? null
                      : () => context.read<AgendaBloc>().add(
                            const AgendaExportRequested(
                              AppConfig.icsFormatKey,
                            ),
                          ),
                ),
                SizedBox(height: tokens.spaceSm + tokens.spaceXs),
                OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart),
                  label: Text(l10n.exportCsvCta),
                  onPressed: count == 0
                      ? null
                      : () => context.read<AgendaBloc>().add(
                            const AgendaExportRequested(
                              AppConfig.csvFormatKey,
                            ),
                          ),
                ),
                if (state.exportedFilePath != null) ...[
                  SizedBox(height: tokens.spaceMd),
                  Text(
                    l10n.exportedPathLabel(state.exportedFilePath!),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
