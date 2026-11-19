import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/config/app_config.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/course.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_design_tokens.dart';

/// Tarjeta escaneable de actividad académica con tokens unificados.
class ActivityCard extends StatelessWidget {
  final Activity activity;
  final Course? course;
  final VoidCallback onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.course,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens =
        Theme.of(context).extension<AppDesignTokens>() ?? AppDesignTokens.dark;
    final fmt = DateFormat(AppConfig.timePattern);
    final startText = fmt.format(activity.start);
    final endText = fmt.format(activity.end);
    final courseLabel = course?.name ?? activity.courseId;

    return Semantics(
      label: l10n.activityCardSemantics(
        activity.title,
        courseLabel,
        startText,
        endText,
      ),
      button: false,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: tokens.cardVerticalMargin),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: tokens.accentLime,
            foregroundColor: tokens.onLime,
            child: Text(
              '${activity.priority}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            activity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$courseLabel · $startText – $endText',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            tooltip: l10n.deleteActivityTooltip,
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
