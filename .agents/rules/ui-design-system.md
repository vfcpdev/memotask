---
trigger: glob
globs: "**/lib/presentation/**/*.dart, **/lib/app.dart"
---
# Reglas de UI y Sistema de Diseño (`UI_RULES`)

Estas reglas son obligatorias al crear o modificar código en `lib/presentation/` y `lib/app.dart`.

## 1. Jerarquía Visual (`Visual Hierarchy`)
- **Alta escaneabilidad:** Máximo 3 datos por tarjeta de actividad (badge de prioridad, título conciso, horario/curso). Evitar párrafos largos en listas y grillas.
- **CTA Primario único:** Cada pantalla o modal debe resaltar **un único CTA primario** (`FilledButton` o `FloatingActionButton`). Las acciones alternativas deben usar `OutlinedButton` o `TextButton` (nunca dos `FilledButton` con igual peso jerárquico salvo acciones simétricas explícitas).
- **Etiquetas concisas y cero descripciones no solicitadas:** Prohibido insertar jerga técnica interna (ej. `(RFC 5545, VALARM -PT30M)`) o textos explicativos en botones o cabeceras salvo requerimiento explícito.

## 2. Sistema de Diseño Unificado (`Design System`)
- Consumir tokens vía `Theme.of(context)` (`ColorScheme`, `TextTheme`) y `Theme.of(context).extension<AppDesignTokens>()!`.
- Mantener consistencia de tokens entre **Botones** (`filledButtonTheme`, `outlinedButtonTheme`, `floatingActionButtonTheme`), **Tarjetas** (`cardTheme`), **Modales** (`bottomSheetTheme`, `dialogTheme`) y **Navegación** (`navigationBarTheme`).
- **Prohibido `Color.withOpacity(...)`** (deprecado): usar `Color.withValues(alpha: ...)`.
- **Prohibido acceder directamente a estáticos `AppTheme.lime` o `AppTheme.navy`** dentro de `screens/` o `widgets/`.

## 3. Cero Hardcoding (`Zero Hardcoding`)
- **Textos:** Prohibidos strings literales de UI (`Text('...')`, `labelText: '...'`, `tooltip: '...'`, mensajes de `SnackBar`). Usar `AppLocalizations.of(context)` (ARB).
- **Colores, dimensiones y límites:** Prohibidos `Color(0x...)` fuera de `lib/presentation/theme/`, y prohibidos rangos o parámetros fijos (`DateTime(2024)`, `'es'`) dentro de widgets; inyectar desde `AppConfig` y `Localizations.localeOf(context)`.
- **Intl seguro:** Nunca llamar `DateFormat(..., locale)` sin haber configurado `flutter_localizations` e inicializado `initializeDateFormatting`.

## 4. Accesibilidad y Rendimiento en UI
- Contraste WCAG AA ($\ge 4.5:1$), áreas táctiles $\ge 48 \times 48\text{ dp}$, `Semantics` y `tooltip` localizados en botones de ícono, tarjetas y celdas.
- **Cero loops $O(n)$ por celda dentro de `build()`:** las agrupaciones por día o curso se consumen pre-indexadas desde `AgendaState` ($O(1)$ por lookup).
