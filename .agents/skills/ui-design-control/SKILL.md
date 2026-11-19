---
name: ui-design-control
description: >-
  Use this skill when designing, refactoring, or reviewing MemoTask Flutter UI screens,
  modals, theme tokens, localization, or accessibility under UI_RULES.
---

# Control de Diseño UI (`UI_RULES`) — MemoTask

Flujo normativo para producir y auditar interfaces Flutter de grado de producción en `lib/presentation/` y `lib/app.dart`.

## Referencias Normativas
- Especificación completa de tokens, contraste WCAG AA y anatomía de componentes: [design-tokens-spec.md](./references/design-tokens-spec.md)
- Regla automática de capa UI: [ui-design-system.md](../../rules/ui-design-system.md)

## Procedimiento Paso a Paso

1. **Verificar Tokens y Tema Unificado (`ThemeData` + `AppDesignTokens`)**
   - Comprobar que `lib/presentation/theme/app_theme.dart` expone `AppDesignTokens` (`ThemeExtension<AppDesignTokens>`) con tokens de color, espaciado, radios y tipografía.
   - Confirmar que están configurados en `ThemeData`: `filledButtonTheme`, `outlinedButtonTheme`, `floatingActionButtonTheme`, `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `navigationBarTheme`, `inputDecorationTheme` y `snackBarTheme`.
   - Reemplazar cualquier `Color.withOpacity(...)` por `Color.withValues(alpha: ...)`.

2. **Auditar Jerarquía Visual y Escaneabilidad**
   - Confirmar **un único CTA primario** (`FilledButton` o `FloatingActionButton`) por pantalla o modal.
   - En `ExportScreen`, el formato recomendado (`.ics`) usa `FilledButton.icon`; los formatos secundarios (`.csv`) usan `OutlinedButton.icon`.
   - En `TimelineScreen`, cada `Card` muestra máximo 3 elementos escaneables (prioridad, título, `curso · HH:mm – HH:mm`) sin descripciones extensas no solicitadas.
   - Eliminar cualquier jerga técnica en etiquetas de botones (ej. omitir `(RFC 5545, VALARM -PT30M)` de botones).

3. **Eliminar Hardcoding (`l10n` + `Theme.of(context)` + `AppConfig`)**
   - Sustituir todos los literales de texto de UI por getters de `AppLocalizations` (`l10n`).
   - Sustituir referencias estáticas `AppTheme.lime` / `AppTheme.onLime` en `screens/` por `Theme.of(context).colorScheme` o `Theme.of(context).extension<AppDesignTokens>()!`.
   - Extraer rangos de fechas (`firstDate`, `lastDate`), duración por defecto y configuraciones a `AppConfig`.
   - Asegurar `flutter_localizations` + `initializeDateFormatting` antes de usar `DateFormat(..., locale)`.

4. **Validar Complejidad de Renderizado y Accesibilidad**
   - Asegurar que `WeekCalendarScreen` lee un mapa pre-indexado `activitiesByDay` en $O(1)$ por celda (nunca `.where(...)` dentro de `days.map(...)`).
   - Verificar `Semantics`, `tooltip` en botones de ícono, área táctil mínima `48x48 dp` y contraste $\ge 4.5:1$.

5. **Verificación**
   - Ejecutar el auditor de diseño:
     `powershell -ExecutionPolicy Bypass -File ".agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1" -Root "."`
   - Ejecutar `flutter test test/widget_test.dart` tras cambios de UI.
