# Especificación de Tokens de Diseño — MemoTask

## 1. Paleta y Contraste WCAG AA

| Token lógico | Valor Hex | Rol | Contraste verificado |
| :--- | :--- | :--- | :--- |
| `brandNavy` | `#0B2239` | Fondo base (`scaffoldBackgroundColor`, `appBarTheme`) | Base oscura |
| `surfaceNavy` | `#12314F` | Superficie elevada (`Card`, `BottomSheet`, `Dialog`, `NavigationBar`) | Elevación tonal sobre base |
| `accentLime` | `#76B800` | Acento único para CTA primario, FAB y foco activo | — |
| `onSurfacePrimary` | `#FFFFFF` | Texto principal sobre `brandNavy` y `surfaceNavy` | $> 11:1$ (AAA / AA) |
| `onAccentLime` | `#0B2239` | Texto e íconos sobre `accentLime` | $> 6.5:1$ (AA+) |

## 2. Tokens Estructurales (`AppDesignTokens` ThemeExtension)

| Categoría | Token | Valor | Uso unificado |
| :--- | :--- | :--- | :--- |
| **Espaciado** | `spaceXs` / `spaceSm` / `spaceMd` / `spaceLg` | `4` / `8` / `16` / `24` dp | Gaps entre campos, paddings de tarjetas y pantallas |
| **Radios** | `radiusSm` / `radiusMd` / `radiusLg` | `8` / `14` / `20` dp | Inputs (`8`), `Card` (`14`), `BottomSheet` y `Dialog` (`20`) |
| **Tamaños táctiles** | `minTouchTarget` | `48.0` dp | `minimumSize` en `FilledButton`, `OutlinedButton`, `IconButton` |
| **Bordes** | `focusBorderWidth` | `2.0` dp | `InputDecorationTheme.focusedBorder` con `accentLime` |

## 3. Reglas Unificadas por Familia de Componentes

### Botones
- **CTA Primario (`FilledButton` / `FloatingActionButton`):** Fondo `accentLime`, primer plano `onAccentLime`, `fontWeight: FontWeight.w700`, `minimumSize: Size(64, 48)`. Máximo 1 por vista/modal.
- **Acción Secundaria (`OutlinedButton`):** Borde sutil derivado de `colorScheme.outline`, primer plano `onSurfacePrimary`, `minimumSize: Size(64, 48)`.

### Tarjetas (`CardThemeData`)
- Superficie `surfaceNavy`, `elevation: 2`, `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd))`, margen vertical `6 dp`.
- Contenido escaneable: `CircleAvatar` (prioridad), `title` (`w600`), `subtitle` (`Curso · HH:mm – HH:mm`), `trailing` (`IconButton` con `tooltip`).

### Modales (`BottomSheetThemeData` & `DialogThemeData`)
- Superficie `surfaceNavy`, bordes superiores redondeados `radiusLg` (`20 dp`), `showDragHandle: true`, `useSafeArea: true`.
- Respeto estricto de `MediaQuery.viewInsetsOf(context).bottom` para teclado en formularios.
