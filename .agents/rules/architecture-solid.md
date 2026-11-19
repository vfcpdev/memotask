---
trigger: glob
globs: "**/lib/**/*.dart"
---
# Reglas de Arquitectura, SOLID y Eficiencia (`ARCHITECTURE_RULES`)

Estas reglas rigen toda la estructura de `lib/`.

## 1. Separación Estricta de Capas y DIP
- **`lib/domain/` (Dart puro):** Cero imports de `flutter/*`, `drift/*`, `flutter_bloc/*`, `lib/data/*` o `lib/presentation/*`. Define entidades, algoritmos, estrategias, fábricas, casos de uso e **interfaces** (`IScheduleRepository`, `IExportGateway`).
- **`lib/presentation/bloc/` (`State/AppLogic`):** Depende exclusivamente de casos de uso e interfaces de `lib/domain/`. **Prohibido** importar `lib/data/*` o widgets de `flutter/material.dart`.
- **`lib/presentation/screens/` y `widgets/` (`UI/Presentation`):** Solo interactúan con `AgendaBloc` y entidades/DTOs de presentación. **Prohibido** importar `lib/data/*`, `drift/*` o instanciar estrategias de exportación concretas.
- **`lib/data/` (`Data`):** Implementa las interfaces de `lib/domain/` (`DriftScheduleRepository`, `LocalExportGateway`). **Prohibido** importar `lib/presentation/*`.

## 2. OOP, SOLID y SRP
- **SRP por archivo y clase:** Un archivo por pantalla (`timeline_screen.dart`, `week_calendar_screen.dart`, `export_screen.dart`), un archivo por estrategia (`ics_export_strategy.dart`, `csv_export_strategy.dart`) y un archivo por caso de uso.
- **Colisiones Drift:** Las tablas Drift deben declarar `@DataClassName('CourseRow')` y `@DataClassName('ActivityRow')` (o usar alias `as db`) para evitar ambigüedad con entidades de dominio.
- **Integridad de esquema Drift:** Declarar referencia FK `courseId` hacia `Courses.id` e índices en `start` y `course_id`.

## 3. Patrones Contextuales Obligatorios
- **Factory:** Usar `ExportStrategyFactory` para resolver estrategias de exportación por formato; no incrustar mapas fijos en servicios o BLoCs.
- **Strategy:** Toda exportación nueva implementa `ExportStrategy` como operación pura y determinista.
- **Repository / Gateway:** Encapsular persistencia e I/O tras interfaces de dominio, revalidando invariantes de dominio al leer (`Activity.create`).
- **BLoC:** Eventos sellados (`sealed class`), estado inmutable (`Equatable`), efectos efímeros (`errorCode`, `exportedFilePath`) limpiables explícitamente en `copyWith` o consumidos mediante evento de limpieza.

## 4. Presupuesto de Complejidad Algorítmica
- Búsqueda por curso (`CourseIndex`) o por fecha en calendario (`activitiesByDay`): **$O(1)$** por consulta tras construcción **$O(n)$**.
- Consulta de próxima actividad urgente (`PriorityMinHeap.peekNext`): **$O(1)$**; inserción/extracción **$O(\log n)$**.
- Agendamiento (`ScheduleActivity`): verificación de solapamiento e inserción ordenada preservando `isSortedByStart` sin reordenar innecesariamente en $O(n \log n)$ cuando el arreglo ya está ordenado.
- Detección de conflictos (`ConflictDetector`): sweep-line sin asignaciones muertas de memoria; cálculo exacto de intersección `min(open.end, current.end) - current.start`.
- Serialización de exportación: una sola pasada **$O(n)$** con `StringBuffer`.
