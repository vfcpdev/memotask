---
name: architecture-solid-control
description: >-
  Use this skill when authoring or auditing MemoTask domain/data/BLoC architecture,
  SOLID/DIP boundaries, design patterns (Factory, Strategy, Repository, BLoC),
  algorithmic complexity bounds, or running the automated design-control audit script.
---

# Control de Arquitectura, SOLID y Complejidad (`ARCHITECTURE_RULES`)

Procedimiento de verificación estructural para MemoTask.

## Referencias Normativas
- Regla automática de capa: [architecture-solid.md](../../rules/architecture-solid.md)
- Script de auditoría automatizada: [audit_design_rules.ps1](./scripts/audit_design_rules.ps1)

## Procedimiento Paso a Paso

1. **Ejecutar Auditoría Estática Automatizada**
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1" -Root "."
   ```
   Para modo estricto en CI/gatekeeper (retorna exit code 1 ante violaciones):
   ```powershell
   powershell -ExecutionPolicy Bypass -File ".agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1" -Root "." -Strict
   ```

2. **Validar Separación de Capas y DIP**
   - `domain/` sin dependencias de Flutter, Drift o BLoC.
   - `AgendaBloc` inyectado con interfaces `IScheduleRepository` e `IExportGateway` (nunca clases concretas de `data/`).
   - `DriftScheduleRepository` sin colisiones de símbolos (`@DataClassName` o alias `as db`).

3. **Validar SRP y Patrones**
   - Cada pantalla, estrategia de exportación, caso de uso y repositorio en su propio archivo cohesivo.
   - Instanciación de exportadores delegada a `ExportStrategyFactory`.
   - Efectos de una sola vez en `AgendaState` (`errorCode`, `exportedFilePath`) limpiables explícitamente.

4. **Auditar Complejidad Algorítmica**
   - Confirmar ausencia de heaps o colecciones muertas en `ConflictDetector`.
   - Confirmar inserción ordenada sin `.sort()` completo en `ScheduleActivity` cuando la agenda ya está ordenada.
   - Confirmar indexado $O(n)$ + lookup $O(1)$ en `CourseIndex` y `WeekCalendarScreen`.

5. **Validar Compilación y Pruebas**
   - Tras refactorizaciones de código Dart, validar con `dart analyze` / `flutter test` en entorno con acceso al toolchain.
