---
trigger: glob
globs: "**/lib/domain/**/*.dart, **/lib/data/repositories/**/*.dart, **/lib/presentation/bloc/**/*.dart"
---
# Reglas de Verificación Formal con Triplas de Hoare (`FORMAL_VERIFICATION`)

Todo método o fábrica crítica de negocio en entidades, algoritmos, estrategias, casos de uso, repositorios y handlers del BLoC **DEBE** incluir documentación formal de Hoare.

## 1. Formato Normativo Obligatorio
Usar exactamente esta sintaxis de comentario de tres líneas encima del método o constructor fábrica:

```dart
// {P} <Precondición lógica sobre entradas, estado e invariantes previos>
// C   <Nombre de la operación / comando ejecutado>
// {Q} <Postcondición garantizada ∧ invariantes de clase/estructura preservados>
```

## 2. Reglas de Invariantes y Fallo Seguro
1. **Invariantes de `Activity`:**
   - `start < end` (`INV-ACT-1`)
   - `1 <= priority <= 3` (`INV-ACT-2`)
   - `id.isNotEmpty && courseId.isNotEmpty && title.trim().isNotEmpty` (`INV-ACT-3`)
2. **Invariantes de Agenda (`S`):**
   - `isSortedByStart(S)` (`INV-SCH-1`)
   - `disjoint(S)`: ningún par distinto se solapa (`INV-SCH-2`)
3. **Preservación ante fallo de precondición:** Si `{P}` no se cumple, la operación **DEBE** lanzar excepción tipada (`ArgumentError`, `ScheduleConflictException`) sin efectos laterales sobre `S`, el estado del BLoC o SQLite.
4. **Invariantes de bucle:** Todo algoritmo iterativo o de heap (`ConflictDetector.detect`, `HeapQueue._siftUp/_siftDown`) debe declarar el invariante del bucle/heap inmediatamente sobre el ciclo.

## 3. Trazabilidad a Pruebas
- Cada método anotado con `// {P}`, `// C`, `// {Q}` debe contar con al menos un caso de prueba en `test/` que verifique:
  - Caso nominal: `{P}` verdadero $\implies$ `{Q}` verdadero.
  - Caso borde / rechazo: `{P}` falso $\implies$ excepción esperada y estado intacto.
