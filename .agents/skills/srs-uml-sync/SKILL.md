---
name: srs-uml-sync
description: >-
  Use this skill whenever code changes add, remove, or refactor MemoTask entities,
  usecases, strategies, BLoC events/states, Drift tables, or screens so docs/SRS.md and docs/UML.md remain synchronized.
---

# Sincronización Código ↔ SRS ↔ UML

Mantiene la trazabilidad bidireccional entre `lib/`, [docs/SRS.md](../../../docs/SRS.md) y [docs/UML.md](../../../docs/UML.md).

## Cuándo Activar
- Al modificar tablas o columnas en `lib/data/datasources/app_database.dart`.
- Al agregar eventos/estados en `AgendaBloc` o nuevas pantallas en `lib/presentation/screens/`.
- Al introducir nuevas estrategias (`ExportStrategy`), casos de uso, interfaces DIP o algoritmos.
- Al corregir defectos documentados en la tabla de Auditoría Baseline (`AUD-01..AUD-08`) de `docs/SRS.md`.

## Procedimiento

1. **Inspeccionar Cambios Estructurales**
   - Revisar `lib/domain/`, `lib/data/`, `lib/presentation/` y `test/`.
   - Listar diferencias en entidades, interfaces, eventos, estados, rutas/pestañas UI y dependencias (`pubspec.yaml`).

2. **Actualizar `docs/SRS.md`**
   - Actualizar estado de `AUD-01..AUD-08` (marcar remediados con evidencia de archivo y prueba).
   - Actualizar estado MoSCoW / Baseline de `RF-01..RF-12` y la Matriz de Trazabilidad.
   - Mantener intactas las cotas Big-O reales observadas en el código.

3. **Actualizar `docs/UML.md`**
   - Sincronizar `classDiagram`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram` y `flowchart` afectados.
   - Validar reglas de sintaxis Mermaid:
     - Solo tipos soportados (`flowchart`, `classDiagram`, `sequenceDiagram`, `stateDiagram-v2`, `erDiagram`).
     - Etiquetas con paréntesis o corchetes entre comillas (`id["Texto (extra)"]`).
     - Cero etiquetas HTML (`<br>`, `<b>`, etc.) dentro de nodos.

4. **Verificar Consistencia**
   - Confirmar que todos los símbolos y rutas mencionados en `SRS.md` y `UML.md` existen con ortografía exacta en `lib/` y `test/`.
