# MemoTask — Regla Maestra de Control de Diseño e Ingeniería

```text
SYSTEM: Senior Engineer & UI Architect
TASK: Generate production-grade UI & core business code.

UI_RULES:
- Visual Hierarchy: High scannability, prominent primary CTA, concise labels, zero unprompted descriptions.
- Design System: Unified visual tokens across Buttons, Cards, Modals.
- Zero Hardcoding: Strict config/theme injection (ThemeData/tokens, l10n, env constants).

ARCHITECTURE_RULES:
- Separation of Concerns: Strict layers -> UI/Presentation, State/AppLogic, Domain/Data.
- OOP & SOLID: High cohesion, loose coupling, DIP via interfaces, SRP per class.
- Patterns: Context-driven design patterns (Factory, Strategy, Repository/BLoC/Store).
- Algorithmic Efficiency: Optimal time/space complexity (O(1)/O(n) bounds).

FORMAL_VERIFICATION:
- Hoare Triples: Document business-critical methods using:
  // {P} Precondition
  // C   Operation
  // {Q} Postcondition & Class Invariants
```

## 1. Documentos Normativos del Proyecto
- Especificación de Requisitos y Auditoría Baseline: [`docs/SRS.md`](./docs/SRS.md)
- Modelado UML y Arquitectura Objetivo: [`docs/UML.md`](./docs/UML.md)

## 2. Matriz Estricta de Importación por Capa

| Capa / Ruta | Permitido importar | Prohibido importar |
| :--- | :--- | :--- |
| **Domain** (`lib/domain/**`) | `dart:*`, `equatable`, `lib/domain/**`, constantes inyectadas | `flutter/*`, `drift/*`, `flutter_bloc`, `lib/data/**`, `lib/presentation/**` |
| **State / AppLogic** (`lib/presentation/bloc/**`) | `flutter_bloc`, `equatable`, `lib/domain/**` (interfaces y casos de uso) | `lib/data/**`, widgets de `flutter/material.dart` |
| **UI / Presentation** (`lib/presentation/screens/**`, `widgets/**`, `theme/**`) | `flutter/material.dart`, `flutter_bloc`, `l10n`, `lib/domain/entities/*`, `lib/presentation/bloc/*`, `theme/*` | `lib/data/**`, `drift/*`, implementaciones concretas de exportación |
| **Data** (`lib/data/**`) | `drift`, `path_provider`, `path`, `lib/domain/**` (implementa interfaces de dominio) | `lib/presentation/**` |
| **Composition Root** (`lib/app.dart`, `lib/main.dart`) | Capas necesarias solo para inyección de dependencias y bootstrap | Lógica de negocio, algoritmos o SQL directo |

## 3. Reglas Activas por Ámbito (`.agents/rules/`)
- **UI & Design System:** [`.agents/rules/ui-design-system.md`](./.agents/rules/ui-design-system.md) — aplica a `lib/presentation/**` y `lib/app.dart`.
- **Arquitectura, SOLID y Complejidad:** [`.agents/rules/architecture-solid.md`](./.agents/rules/architecture-solid.md) — aplica a todo `lib/**/*.dart`.
- **Verificación Formal (Triplas de Hoare):** [`.agents/rules/formal-verification-hoare.md`](./.agents/rules/formal-verification-hoare.md) — aplica a `lib/domain/**`, `lib/data/repositories/**` y `lib/presentation/bloc/**`.

## 4. Agentes y Skills de Control de Diseño (`.agents/`)

| Responsabilidad | Subagente (`.agents/agents/`) | Skill asociado (`.agents/skills/`) |
| :--- | :--- | :--- |
| Diseño UI, tokens, jerarquía, `l10n`, WCAG AA | `ui-architect` | `ui-design-control` |
| Capas, SOLID/DIP, patrones, cotas $O(1)/O(n)$ | `domain-architecture-auditor` | `architecture-solid-control` |
| Triplas de Hoare, invariantes y pruebas formales | `hoare-formal-verifier` | `hoare-verification-control` |
| Sincronización código ↔ SRS ↔ UML | — | `srs-uml-sync` |
| Veredicto final de entrega (`PASS` / `BLOCK`) | `design-gatekeeper` | `architecture-solid-control` (`audit_design_rules.ps1`) |

## 5. Protocolo Obligatorio Ante Cambios de Código
1. Antes de editar una capa, respetar su fila en la Matriz de Importación y la regla correspondiente en `.agents/rules/`.
2. Todo método crítico de negocio nuevo o modificado debe incluir la Tripla de Hoare exacta (`// {P}`, `// C`, `// {Q}`) y prueba unitaria asociada.
3. Toda cadena de texto visible en UI y todo valor visual (color, radio, espaciado) deben provenir de `l10n` / `Theme.of(context)` / `AppDesignTokens`.
4. Al finalizar cambios sustanciales, ejecutar el script `.agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1` y sincronizar `docs/SRS.md` + `docs/UML.md` mediante la skill `srs-uml-sync`.
