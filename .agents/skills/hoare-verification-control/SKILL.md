---
name: hoare-verification-control
description: >-
  Use this skill when writing, reviewing, or testing Hoare Triples (// {P}, // C, // {Q}),
  class invariants, loop invariants, or formal pre/postconditions in MemoTask domain, data, or BLoC layers.
---

# Control de Verificación Formal con Triplas de Hoare (`FORMAL_VERIFICATION`)

Procedimiento para especificar, verificar y testear contratos formales en MemoTask.

## Referencias Normativas
- Catálogo canónico de triplas de MemoTask: [hoare-catalog.md](./references/hoare-catalog.md)
- Regla automática: [formal-verification-hoare.md](../../rules/formal-verification-hoare.md)

## Procedimiento Paso a Paso

1. **Identificar Métodos Críticos de Negocio**
   - Entidades: fábricas y mutadores (`Activity.create`, `Activity.copyWith`, `Activity.overlaps`).
   - Casos de uso: todos los métodos `call` (`ScheduleActivity`, `BuildExportFile`).
   - Algoritmos: `ConflictDetector.detect`, `PriorityMinHeap` (`add`, `peekNext`, `popNext`, `drain`), `CourseIndex` (`add`, `forCourse`).
   - Estrategias y Repositorios: `ExportStrategy.export`, `IScheduleRepository.insertActivity`, handlers de `AgendaBloc`.

2. **Aplicar la Sintaxis Exacta de 3 Líneas**
   Sobre cada método crítico, redactar exactamente:
   ```dart
   // {P} <Precondición formal>
   // C   <Operación>
   // {Q} <Postcondición ∧ Invariantes preservados>
   ```
   Si el método contiene un ciclo o heap, agregar `// Invariante de bucle: ...` dentro del cuerpo.

3. **Verificar Guardas en Tiempo de Ejecución y No Mutación**
   - Toda parte verificable de `{P}` debe validarse al inicio del método (ej. `!start.isBefore(end)`, `priority < 1 || priority > 3`, `activities.isEmpty`, solapamientos).
   - Ante violación de `{P}`, lanzar `ArgumentError` o excepción de dominio (`ScheduleConflictException`) antes de mutar colecciones, estado BLoC o base de datos.

4. **Verificar Corrección Matemática Específica**
   - **Intervalos semiabiertos `[start, end)`:** solapan ssi `a.start.isBefore(b.end) && b.start.isBefore(a.end)`.
   - **Minutos de sobrecarga en sweep-line:** para cada par `(open, current)` en conflicto, la intersección exacta es `min(open.end, current.end).difference(current.start).inMinutes` (nunca asumir `open.end <= current.end`).
   - **RFC 5545:** `count(BEGIN:VEVENT) == count(END:VEVENT) == |E|` y `count(BEGIN:VALARM) == |{a ∈ E | a.reminderEnabled}|`.

5. **Sincronizar con Pruebas Unitarias**
   - Confirmar en `test/domain_test.dart` y `test/bloc_test.dart` la existencia de pruebas tanto para el camino `{P} -> {Q}` como para el rechazo `¬{P} -> excepción ∧ estado intacto`.
