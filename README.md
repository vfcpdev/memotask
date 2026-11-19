# MemoTask · Agenda Estudiantil

Aplicación Flutter **offline-first** orientada a la gestión académica sin solapamientos, priorización de urgencias, detección sweep-line de conflictos y exportación estándar `.ics` (RFC 5545 con alarma `-PT30M`) / `.csv` (RFC 4180).

## Arquitectura y Control de Diseño

El proyecto sigue una arquitectura limpia en 4 capas estrictas con inversión de dependencias (DIP), verificación formal mediante Triplas de Hoare (`// {P}`, `// C`, `// {Q}`) y sistema de diseño unificado (`AppDesignTokens` + `AppLocalizations`):

- **Documentación normativa:** [`docs/SRS.md`](./docs/SRS.md) y [`docs/UML.md`](./docs/UML.md)
- **Regla maestra y matriz de capas:** [`AGENTS.md`](./AGENTS.md)
- **Agentes y Skills (`.agents/`):**
  - Reglas por capa en [`.agents/rules/`](./.agents/rules/)
  - Subagentes auditores en [`.agents/agents/`](./.agents/agents/)
  - Skills y auditor estático en [`.agents/skills/`](./.agents/skills/)

## Estructura de `lib/`

- `lib/domain/` — Entidades (`Activity`, `Course`), puertos DIP (`IScheduleRepository`, `IExportGateway`), algoritmos ($O(1)$/`O(log n)`/`O(n log n + k)`), estrategias (`IcsExportStrategy`, `CsvExportStrategy`), fábrica (`ExportStrategyFactory`) y casos de uso (`ScheduleActivity`, `BuildExportFile`).
- `lib/data/` — Persistencia SQLite con Drift (`AppDatabase`, `DriftScheduleRepository`) y adaptador de exportación (`LocalExportGateway`).
- `lib/presentation/` — Gestión de estado (`AgendaBloc`), internacionalización ARB (`l10n/`), tokens (`AppDesignTokens`, `AppTheme`), widgets y pantallas.

## Verificación y Pruebas

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Auditoría automatizada de cumplimiento (`UI_RULES`, `ARCHITECTURE_RULES`, `FORMAL_VERIFICATION`):

```powershell
powershell -ExecutionPolicy Bypass -File ".agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1" -Root "." -Strict
```
