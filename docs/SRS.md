# Especificación de Requisitos de Software (SRS) — MemoTask

**Estándar de referencia:** ISO/IEC/IEEE 29148  
**Producto:** MemoTask · Agenda Estudiantil (`memo_task`)  
**Versión del documento:** 1.1.0 (Baseline Audit Remediado + Especificación Final)  
**Fecha:** 2026-11-19  
**Ámbito normativo:** `SYSTEM: Senior Engineer & UI Architect` (`UI_RULES`, `ARCHITECTURE_RULES`, `FORMAL_VERIFICATION`)

---

## 1. Caracterización del Proyecto y Estado Actual

### 1.1 Ficha Técnica del Sistema

| Atributo | Valor verificado en el repositorio |
| :--- | :--- |
| **Nombre del paquete** | `memo_task` (`pubspec.yaml:1`) |
| **Título de aplicación** | `MemoTask · Agenda Estudiantil` / `MemoTask · Student Agenda` (`l10n` ARB) |
| **Versión** | `1.0.0+1` (`pubspec.yaml:19`) |
| **SDK / Plataforma** | Dart `^3.12.0` + Flutter Material 3; target configurado para Android (`applicationId: com.memotask.memo_task`, `minSdk`/`targetSdk` de Flutter, JVM/Kotlin 17 en `android/app/build.gradle.kts`) |
| **Modelo de ejecución** | Aplicación móvil **offline-first** con base de datos SQLite local (`memotask.sqlite` en `getApplicationDocumentsDirectory()`) y exportación local de archivos |
| **Gestión de estado** | `flutter_bloc ^9.1.0` + `equatable ^2.0.7` (`AgendaBloc`, modelo unidireccional Evento → Estado vía puertos DIP) |
| **Persistencia** | `drift ^2.28.0` + `sqlite3_flutter_libs ^0.5.32` + `path_provider ^2.1.5` + `path ^1.9.1` |
| **Utilidades** | `intl ^0.20.2`, `uuid ^4.5.1`, `cupertino_icons ^1.0.8` |
| **Tooling / Dev** | `flutter_lints ^6.0.0`, `drift_dev ^2.28.0`, `build_runner ^2.4.15`, `flutter_test` |
| **Capas actuales** | `lib/domain/`, `lib/data/`, `lib/presentation/` (`bloc/`, `l10n/`, `models/`, `screens/`, `theme/`, `widgets/`), `lib/app.dart`, `lib/main.dart` |
| **Internacionalización (`l10n`)** | `flutter_localizations` + `l10n.yaml` + `app_es.arb` / `app_en.arb` + `initializeDateFormatting()` |
| **Conectividad / Auth** | Ninguna (sin endpoints remotos, sin autenticación, sin sincronización en la nube) |

### 1.2 Inventario de Módulos y Capacidades

1. **Núcleo de Dominio (`lib/domain/`)**:
   - **Configuración (`config/app_config.dart`)**: Constantes operativas centralizadas (`databaseFileName`, `minPriority..maxPriority`, `-PT30M` via `defaultAlarmLead`, patrones de fecha y años).
   - **Entidades (`entities/`)**: `Activity` (`Activity.create` y `copyWith` validando `start < end`, `1 <= priority <= 3` y campos no vacíos, `overlaps`) y `Course` (`Course.create` con normalización de `id`).
   - **Puertos DIP (`repositories/`)**: `IScheduleRepository` y `IExportGateway`.
   - **Casos de uso (`usecases/`)**: `ScheduleActivity` (inserción ordenada $O(n)$ sin solapamiento + `ActivityScheduleSuccess` + `ScheduleConflictException`) y `BuildExportFile`.
   - **Estrategias y Fábrica (`strategies/`)**: `ExportResult`, `ExportStrategy`, `IcsExportStrategy` (RFC 5545 `VCALENDAR`, `VEVENT`, `VALARM -PT30M`), `CsvExportStrategy` (RFC 4180) y `ExportStrategyFactory`.
   - **Algoritmos y Estructuras (`algorithms/`)**: `ConflictReport`, `ConflictDetector` (sweep-line $O(n \log n + k)$), `HeapQueue<T>`, `PriorityMinHeap` ($O(\log n)/O(1)$), `CourseIndex` ($O(1)$) y `DayScheduleIndex` ($O(n)/O(1)$).

2. **Capa de Datos (`lib/data/`)**:
   - **Fuente de datos (`datasources/app_database.dart` y `.g.dart`)**: Esquema Drift v1 con `@DataClassName('CourseRow')`, `@DataClassName('ActivityRow')`, FK `course_id -> courses.id`, `PRAGMA foreign_keys = ON` e índices en `start` y `course_id`.
   - **Repositorio (`repositories/drift_schedule_repository.dart`)**: `DriftScheduleRepository` implementando `IScheduleRepository`.
   - **Gateway (`services/local_export_gateway.dart`)**: `LocalExportGateway` implementando `IExportGateway` con `ExportStrategyFactory`.

3. **Capa de Presentación (`lib/presentation/`, `lib/app.dart`, `lib/main.dart`)**:
   - **Composition Root (`lib/app.dart`, `lib/main.dart`)**: Inyección de `IScheduleRepository`, `IExportGateway`, `AppLocalizations` y `AppTheme.theme()`.
   - **BLoC (`bloc/`)**: `AgendaBloc`, `AgendaEvent`, `AgendaState` (con índices precalculados), `AgendaFailure` (`AgendaErrorCode`).
   - **Tema y Tokens (`theme/`)**: `AppDesignTokens` (`ThemeExtension`) y `AppTheme` con estilos unificados para botones, tarjetas, modales y barra de navegación.
   - **Pantallas y Widgets (`screens/`, `widgets/`, `models/`)**: `HomeShell`, `TimelineScreen`, `WeekCalendarScreen`, `ExportScreen`, `ActivityFormModal`, `ActivityCard`, `NewActivityFab`, `CourseFormDialog`.

4. **Suite de Pruebas (`test/`) — 23 pruebas aprobadas (`flutter test`)**:
   - `test/domain_test.dart`: 16 pruebas de invariantes, `ScheduleActivity`, `ConflictDetector`, `PriorityMinHeap`, `CourseIndex`, `DayScheduleIndex`, `ExportStrategyFactory`, `IcsExportStrategy` y `CsvExportStrategy`.
   - `test/bloc_test.dart`: 4 pruebas de `AgendaBloc` con puertos DIP.
   - `test/data_test.dart`: 1 prueba de escritura `.ics`/`.csv` con `LocalExportGateway`.
   - `test/widget_test.dart`: 2 pruebas de widgets en español (Timeline, modal de agendamiento, Exportación y Calendario semanal).

### 1.3 Auditoría Baseline y Estado de Remediación

| ID | Severidad | Ubicación original | Regla / Criterio | Estado y remediación implementada |
| :--- | :--- | :--- | :--- | :--- |
| **AUD-01** | Crítica | `schedule_repository.dart` | Tipado Dart / Drift | **Remediado** en [app_database.dart](file:///d:/Documents/SideProjects/MemoTask/lib/data/datasources/app_database.dart) (`@DataClassName('CourseRow')`, `@DataClassName('ActivityRow')`) y [drift_schedule_repository.dart](file:///d:/Documents/SideProjects/MemoTask/lib/data/repositories/drift_schedule_repository.dart). |
| **AUD-02** | Crítica | `export_service.dart` | Imports / Estrategias | **Remediado** en [export_strategy_factory.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/strategies/export_strategy_factory.dart) y [local_export_gateway.dart](file:///d:/Documents/SideProjects/MemoTask/lib/data/services/local_export_gateway.dart). |
| **AUD-03** | Alta | `screens.dart` | Estabilidad / `Intl` | **Remediado** con `flutter_localizations`, `l10n.yaml`, ARB (`es`/`en`), `initializeDateFormatting()` en [main.dart](file:///d:/Documents/SideProjects/MemoTask/lib/main.dart) y [week_calendar_screen.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/screens/week_calendar_screen.dart). |
| **AUD-04** | Media | `agenda_bloc.dart`; `screens.dart` | Integridad de Estado | **Remediado** en [agenda_state.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/bloc/agenda_state.dart) (limpieza explícita de `failure`/`exportedFilePath`), [agenda_bloc.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/bloc/agenda_bloc.dart) (ordenación, `try/catch`, `AgendaCourseUpserted`, `AgendaDaySelected`), [timeline_screen.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/screens/timeline_screen.dart) y [course_form_dialog.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/widgets/course_form_dialog.dart). |
| **AUD-05** | Media | `schedule_algorithms.dart`; `schedule_activity.dart`; `screens.dart` | `ARCHITECTURE_RULES` (Complejidad) | **Remediado**: eliminado heap muerto y corregido cálculo de intersección en [conflict_detector.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/algorithms/conflict_detector.dart); inserción $O(n)$ sin `.sort()` en [schedule_activity.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/usecases/schedule_activity.dart); indexado por día $O(n)/O(1)$ en [day_schedule_index.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/algorithms/day_schedule_index.dart). |
| **AUD-06** | Media | `agenda_bloc.dart`; `screens.dart`; `app_database.dart` | `ARCHITECTURE_RULES` (Capas, DIP, SRP, Patrones) | **Remediado**: puertos DIP [IScheduleRepository](file:///d:/Documents/SideProjects/MemoTask/lib/domain/repositories/schedule_repository_interface.dart) y [IExportGateway](file:///d:/Documents/SideProjects/MemoTask/lib/domain/repositories/export_gateway_interface.dart), 1 clase por archivo (SRP), `ExportStrategyFactory`, FK e índices Drift, y rango `priority ∈ [1,3]` validado en [activity.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/entities/activity.dart). |
| **AUD-07** | Media | `app_theme.dart`; `screens.dart`; `activity_form_screen.dart` | `UI_RULES` (Jerarquía, Tokens, Zero Hardcoding) | **Remediado**: [app_design_tokens.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/theme/app_design_tokens.dart), [app_theme.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/theme/app_theme.dart) (`.withValues`, botones/cards/modales unificados), [app_config.dart](file:///d:/Documents/SideProjects/MemoTask/lib/domain/config/app_config.dart), `l10n` ARB, y jerarquía CTA en [export_screen.dart](file:///d:/Documents/SideProjects/MemoTask/lib/presentation/screens/export_screen.dart). |
| **AUD-08** | Media | `lib/domain/**`, `repositories/`, `bloc/` | `FORMAL_VERIFICATION` | **Remediado**: Triplas `// {P}`, `// C`, `// {Q}` en todos los métodos críticos de negocio, verificadas por `audit_design_rules.ps1 -Strict` (`0` violaciones). |

---

## 2. Introducción del SRS

### 2.1 Propósito
Definir de manera completa, verificable y trazable los requisitos funcionales, requisitos no funcionales, contratos formales (Triplas de Hoare) y restricciones arquitectónicas y visuales para llevar **MemoTask** desde su estado baseline actual hasta una arquitectura de producción gobernada por reglas, agentes y skills de control de diseño.

### 2.2 Alcance del Producto
**MemoTask** es una agenda estudiantil local (offline-first) que permite al estudiante:
1. Gestionar cursos académicos y actividades con control estricto de intervalos temporales y prioridades.
2. Prevenir conflictos de horario al agendar y detectar sobrecargas mediante barrido temporal (sweep-line).
3. Consultar actividades en vistas de **Timeline**, **Calendario Semanal** y **Prioridades Urgentes**.
4. Exportar la agenda a formatos estándar **iCalendar (`.ics`, RFC 5545 con alarma `-PT30M`)** y **CSV (RFC 4180)** de forma extensible mediante patrones Factory y Strategy.

### 2.3 Definiciones, Acrónimos y Glosario

| Término | Definición |
| :--- | :--- |
| **Actividad (`Activity`)** | Evento académico agendado con intervalo semiabierto `[start, end)`, curso asociado, prioridad `1..3` (`1` = máxima urgencia) y bandera de recordatorio. |
| **Curso (`Course`)** | Asignatura académica identificada unívocamente por `id` (`String` normalizado), nombre y docente. |
| **RFC 5545 / `.ics`** | Estándar iCalendar con líneas terminadas en CRLF (`\r\n`), componentes `VCALENDAR`, `VEVENT` y `VALARM` (`ACTION:DISPLAY`, `TRIGGER:-PT30M`). |
| **Tripla de Hoare** | Contrato formal `{P} C {Q}` donde `P` es la precondición previa a ejecutar la operación `C`, y `Q` la postcondición e invariantes garantizados tras `C`. |
| **DIP / SRP** | Principio de Inversión de Dependencias y Principio de Responsabilidad Única (SOLID). |
| **Tokens de Diseño** | Valores centralizados e inyectados vía `ThemeData` / `ThemeExtension` (`AppDesignTokens`) para color, tipografía, espaciado, radios y elevación. |
| **WCAG AA** | Nivel de accesibilidad que exige relación de contraste $\ge 4.5:1$ en texto normal y $\ge 3:1$ en texto grande / componentes gráficos. |

---

## 3. Descripción General

### 3.1 Perspectiva del Producto y Capas Estrictas
El sistema adopta una arquitectura limpia en capas con dirección única de dependencias hacia el dominio:
1. **`UI/Presentation` (`lib/presentation/screens/`, `widgets/`, `theme/`, `l10n/`)**: Renderizado pasivo basado en tokens, accesibilidad, captura de eventos y validación sintáctica de formularios. No importa `data/` ni lógica de persistencia.
2. **`State/AppLogic` (`lib/presentation/bloc/`)**: `AgendaBloc` orquesta eventos, invoca casos de uso de `domain/` y depende únicamente de **abstracciones (interfaces)** definidas en `domain/repositories/` y `domain/services/` (DIP).
3. **`Domain` (`lib/domain/`)**: Código Dart puro (cero dependencias de Flutter o Drift). Contiene entidades inmutables con invariantes, algoritmos, estrategias, fábricas, interfaces de repositorio/gateway y casos de uso con contratos Hoare.
4. **`Data` (`lib/data/`)**: Implementaciones concretas de las interfaces del dominio (`DriftScheduleRepository`, `LocalExportGateway`, `AppDatabase`, proveedores de sistema de archivos).

### 3.2 Actores y Usuarios
- **Estudiante (Actor primario):** Crea, consulta y elimina actividades y cursos; inspecciona conflictos y exporta su agenda a su calendario externo.
- **Agentes de Control de Diseño (Actores de ingeniería):** Subagentes y skills de Antigravity que auditan el código generado contra `UI_RULES`, `ARCHITECTURE_RULES`, `FORMAL_VERIFICATION` y este SRS/UML.

### 3.3 Restricciones de Diseño e Ingeniería (Normativas)

Todo código nuevo o refactorizado en MemoTask **DEBE** cumplir estrictamente:

- **UI_RULES:**
  - *Visual Hierarchy:* Alta escaneabilidad, un CTA primario prominente por superficie, etiquetas concisas y cero descripciones no solicitadas.
  - *Design System:* Tokens visuales unificados en Botones, Tarjetas y Modales mediante `ThemeData` y `ThemeExtension`.
  - *Zero Hardcoding:* Inyección estricta de configuración y tema (`ThemeData`/tokens, `l10n`, constantes de entorno/configuración `AppConfig`).
- **ARCHITECTURE_RULES:**
  - *Separation of Concerns:* Capas estrictas `UI/Presentation` -> `State/AppLogic` -> `Domain` <- `Data`.
  - *OOP & SOLID:* Alta cohesión, bajo acoplamiento, DIP mediante interfaces, SRP estricto por clase y archivo.
  - *Patterns:* Patrones guiados por contexto (`Factory`, `Strategy`, `Repository`, `BLoC`).
  - *Algorithmic Efficiency:* Cotas óptimas de tiempo y espacio ($O(1)$ / $O(n)$ en consultas, indexación y serialización; $O(n \log n)$ acotado solo donde la ordenación o sweep-line lo requiera).
- **FORMAL_VERIFICATION:**
  - *Hoare Triples:* Documentar métodos críticos de negocio usando exactamente:
    ```dart
    // {P} Precondition
    // C   Operation
    // {Q} Postcondition & Class Invariants
    ```

### 3.4 Supuestos y Dependencias
- Ejecución local sin conexión en dispositivos Android (extensible a otros targets Flutter estándar).
- Zona horaria local del dispositivo para captura y visualización; conversión a UTC (`YYYYMMDDTHHMMSSZ`) para exportación RFC 5545.
- Disponibilidad de directorio de documentos del sistema operativo vía `path_provider`.

---

## 4. Requisitos Funcionales (`RF-01` a `RF-12`)

| ID | Nombre | Prioridad (MoSCoW) | Estado Actual |
| :--- | :--- | :--- | :--- |
| `RF-01` | Gestión CRUD de Actividades con invariantes de dominio | Must | Implementado (`Activity.create`, `copyWith`) |
| `RF-02` | Agendamiento sin solapamientos | Must | Implementado (`ScheduleActivity`) |
| `RF-03` | Detección de conflictos y sobrecarga temporal | Should | Implementado y conectado (`ConflictDetector`) |
| `RF-04` | Cola de prioridad de próxima actividad urgente | Should | Implementado y conectado (`PriorityMinHeap`) |
| `RF-05` | Gestión de Cursos e indexación $O(1)$ por curso | Should | Implementado (`Course.create`, `CourseFormDialog`, `CourseIndex`) |
| `RF-06` | Vista Timeline diario escaneable | Must | Implementado (`TimelineScreen` con filtro $O(1)$ por día) |
| `RF-07` | Vista Calendario semanal localizado | Must | Implementado (`WeekCalendarScreen` + `DayScheduleIndex`) |
| `RF-08` | Exportación `.ics` RFC 5545 con alarma `-PT30M` | Must | Implementado (`IcsExportStrategy` + `AppConfig`) |
| `RF-09` | Exportación `.csv` y selector polimórfico por Factory | Should | Implementado (`ExportStrategyFactory` + `CsvExportStrategy`) |
| `RF-10` | Persistencia SQLite/Drift íntegra y migrable | Must | Implementado (`AppDatabase` FK/índices + `DriftScheduleRepository`) |
| `RF-11` | Internacionalización completa (`l10n`) | Must | Implementado (`app_es.arb` / `app_en.arb` + `AppConfig`) |
| `RF-12` | Accesibilidad (WCAG AA y `Semantics`) | Must | Implementado (`AppDesignTokens` + `Semantics` localizados) |

#### `RF-01` — Gestión de Actividades Académicas
- **Descripción:** Permitir crear, listar, actualizar y eliminar actividades académicas (`id`, `courseId`, `title`, `description`, `start`, `end`, `priority`, `reminderEnabled`).
- **Pre/Postcondiciones:** `title.trim().isNotEmpty`, `courseId.trim().isNotEmpty`, `start < end`, `1 <= priority <= 3`. Al crear o editar, el invariante de clase se valida en `Activity.create` / `Activity.copyWith` antes de alcanzar estado o persistencia.
- **Criterios de Aceptación:**
  - Intentar construir una `Activity` con `start >= end` o `priority ∉ {1, 2, 3}` lanza `ArgumentError`.
  - Eliminar una actividad la remueve de SQLite y del estado activo de `AgendaBloc` sin dejar huérfanos en índices.

#### `RF-02` — Agendamiento Libre de Solapamientos
- **Descripción:** Al agendar o reprogramar una actividad `a` sobre una agenda `S`, el sistema debe verificar que `a` no se solapa con ninguna otra actividad existente (`existing.id != a.id`).
- **Criterios de Aceptación:**
  - Dos actividades con borde compartido (`a.end == b.start`) **no** se consideran solapadas (`overlaps == false`).
  - Ante solapamiento, se lanza `ScheduleConflictException`, `S` permanece inmutable y la UI comunica el conflicto con mensaje localizado.

#### `RF-03` — Análisis de Conflictos y Sobrecarga (`ConflictDetector`)
- **Descripción:** Proveer análisis sweep-line sobre un conjunto arbitrario de actividades (p. ej., tras importación o carga masiva), reportando pares solapados y minutos exactos de sobrecarga acumulada.
- **Criterios de Aceptación:**
  - La intersección de dos intervalos `[a.start, a.end)` y `[b.start, b.end)` aporta `min(a.end, b.end).difference(max(a.start, b.start)).inMinutes` (no `open.end - current.start`).
  - Sin asignaciones muertas de memoria ni heaps sin uso.

#### `RF-04` — Priorización de Próxima Actividad (`PriorityMinHeap`)
- **Descripción:** Exponer la actividad más urgente en tiempo $O(1)$ (`peekNext`) priorizando menor valor numérico de `priority` (`1` antes que `2` y `3`) y desempatando por `start` más cercano.
- **Criterios de Aceptación:**
  - Extraer secuencialmente vía `drain()` produce el orden total estrictamente no decreciente por `(priority, start)`.

#### `RF-05` — Gestión e Indexación de Cursos
- **Descripción:** Permitir registrar/editar cursos (`id`, `name`, `professor`) y mantener un `CourseIndex` en $O(1)$ para filtrar Timeline y formularios por curso sin recorrer toda la lista.
- **Criterios de Aceptación:**
  - El formulario de actividad ofrece selector de cursos existentes con opción de alta rápida.
  - Consultar actividades de un curso desde `CourseIndex` tiene tiempo constante amortizado en búsqueda por clave.

#### `RF-06` — Vista Timeline Diario
- **Descripción:** Presentar las actividades del día seleccionado ordenadas cronológicamente por `start`, con selector de día (Hoy / fecha), resumen de la próxima actividad prioritaria y un único CTA primario (`+`) para agendar.
- **Criterios de Aceptación:**
  - Las etiquetas en tarjeta muestran título, curso y rango horario concisos (sin párrafos descriptivos no solicitados).
  - La lista de tarjetas usa los tokens unificados de `CardTheme` y `AppDesignTokens`.

#### `RF-07` — Vista Calendario Semanal
- **Descripción:** Mostrar la semana de lunes a domingo con fecha localizada (`es` o locale activo) y conteo de actividades por día, permitiendo seleccionar un día para inspeccionar su detalle.
- **Criterios de Aceptación:**
  - No produce `LocaleDataException` bajo ningún locale soportado.
  - La agrupación de actividades por día se realiza en una sola pasada $O(n)$ (o pre-indexada en estado), con consulta $O(1)$ por celda de día.

#### `RF-08` — Exportación `.ics` Conforme a RFC 5545
- **Descripción:** Generar archivo `.ics` UTF-8 con terminaciones CRLF (`\r\n`), cabecera `VCALENDAR 2.0`, un `VEVENT` por actividad y un subcomponente `VALARM` (`ACTION:DISPLAY`, `TRIGGER:-PT30M` inyectado desde configuración) cuando `reminderEnabled == true`.
- **Criterios de Aceptación:**
  - Escapa `\`, `,`, `;` y `\n` según RFC 5545 TEXT.
  - `count(BEGIN:VEVENT) == count(END:VEVENT) == |activities|`.
  - Si `activities` está vacío, falla en precondición (`ArgumentError`) antes de escribir archivos.

#### `RF-09` — Exportación `.csv` y Fábrica de Estrategias
- **Descripción:** Soportar exportación `.csv` RFC 4180 con comillas escapadas (`""`) y desacoplar la instanciación de exportadores mediante `ExportStrategyFactory`.
- **Criterios de Aceptación:**
  - En `ExportScreen`, `.ics` se presenta como **CTA primario** (`FilledButton`) y `.csv` como **acción secundaria** (`OutlinedButton`), respetando la jerarquía visual (`UI_RULES`).
  - La confirmación de archivo exportado se muestra una sola vez y limpia su señal efímera tras ser consumida.

#### `RF-10` — Persistencia SQLite/Drift con Integridad Referencial
- **Descripción:** Persistir `Courses` y `Activities` en `memotask.sqlite` con integridad referencial (`course_id` referenciando `courses.id`), índices sobre `start` y `course_id`, y reconstrucción validada vía `Activity.create`.
- **Criterios de Aceptación:**
  - Ninguna colisión de nombres entre clases Drift (`*Row`) y entidades de dominio.
  - Fallos de disco o SQL se capturan y mapean a fallos tipados sin corromper el estado en memoria.

#### `RF-11` — Internacionalización y Cero Hardcoding (`l10n` + `AppConfig`)
- **Descripción:** Externalizar el 100% de cadenas de usuario a archivos ARB (`AppLocalizations`), colores/espaciados/radios a `AppTheme`/`AppDesignTokens`, y constantes técnicas (p. ej. nombre de BD, prefijos de exportación, `-PT30M`, rango de años del picker) a `AppConfig`.
- **Criterios de Aceptación:**
  - Cero literales de texto visible al usuario o colores hexadecimales dentro de `lib/presentation/screens/`.

#### `RF-12` — Accesibilidad
- **Descripción:** Garantizar contraste WCAG AA ($\ge 4.5:1$), áreas táctiles mínimas de `48x48 dp`, `tooltip` en botones de ícono y etiquetas `Semantics` localizadas en tarjetas, celdas del calendario, FAB y acciones de exportación.

---

## 5. Requisitos No Funcionales (`RNF-01` a `RNF-09`)

### `RNF-01` — Jerarquía Visual (`UI_RULES`)
- Cada pantalla debe tener un único punto focal primario y **un CTA primario prominente** (`FilledButton` o `FloatingActionButton` con token `accentPrimary`). Las acciones alternativas usan `OutlinedButton` o `TextButton`.
- Las tarjetas de actividad muestran máximo 3 elementos escaneables: badge de prioridad, título conciso y subtítulo `Curso · HH:mm – HH:mm`.
- Prohibidas descripciones, subtítulos explicativos o avisos técnicos (p. ej., "RFC 5545, VALARM -PT30M") dentro de botones o cabeceras no solicitadas.

### `RNF-02` — Sistema de Diseño y Zero Hardcoding (`UI_RULES`)
- Todo componente visual consume `Theme.of(context)` y `AppDesignTokens` (`ThemeExtension<AppDesignTokens>`).
- Unificación obligatoria de estilos en `AppTheme`: `filledButtonTheme`, `outlinedButtonTheme`, `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `inputDecorationTheme`, `navigationBarTheme`, `floatingActionButtonTheme`, `snackBarTheme`.
- Contraste validado: Navy `#0B2239` / Surface `#12314F` con texto blanco (`> 11:1`), Lime `#76B800` con texto `#0B2239` (`> 6.5:1`), cumpliendo WCAG AA.
- Prohibido `Color.withOpacity(...)` (usar `Color.withValues(alpha: ...)` compatible con Dart 3.12 / Flutter actual).

### `RNF-03` — Separación de Capas, OOP y SOLID (`ARCHITECTURE_RULES`)
Matriz estricta de importación permitida:

| Capa | Carpeta | Puede importar | Prohibido importar |
| :--- | :--- | :--- | :--- |
| **Domain** | `lib/domain/` | `dart:*`, `equatable`, `lib/domain/**`, `AppConfig` (solo constantes puras o inyectadas) | `flutter/*`, `drift/*`, `flutter_bloc`, `lib/data/*`, `lib/presentation/*` |
| **State / AppLogic** | `lib/presentation/bloc/` | `flutter_bloc`, `equatable`, `lib/domain/**` (incl. interfaces) | `lib/data/*`, `flutter/material.dart` (widgets) |
| **UI / Presentation** | `lib/presentation/screens/`, `widgets/`, `theme/` | `flutter/material.dart`, `flutter_bloc`, `l10n`, `lib/domain/entities/*`, `lib/presentation/bloc/*`, `theme/*` | `lib/data/*`, `drift/*`, estrategias de exportación concretas |
| **Data** | `lib/data/` | `drift`, `path_provider`, `path`, `lib/domain/**` (implementa interfaces de dominio) | `lib/presentation/*` |
| **Composition Root** | `lib/app.dart`, `lib/main.dart` | Todas las capas exclusivamente para cablear DI e inicializar la app | Lógica de negocio o algoritmos |

- **SRP:** Máximo una clase pública principal por archivo en `screens/`, `strategies/`, `usecases/` y `widgets/`.

### `RNF-04` — Patrones de Diseño Contextuales (`ARCHITECTURE_RULES`)
- **Strategy:** `ExportStrategy` desacopla formatos `.ics`, `.csv` y futuros exportadores sin modificar `BuildExportFile`.
- **Factory:** `ExportStrategyFactory` resuelve la estrategia por clave (`ExportFormat` enum / clave tipada), evitando mapas rígidos dentro de servicios.
- **Repository & Gateway (DIP):** `IScheduleRepository` y `IExportGateway` residen en `lib/domain/repositories/` y son implementados en `lib/data/`.
- **BLoC:** Eventos sellados (`sealed class AgendaEvent`), estados inmutables (`Equatable`), efectos efímeros modelados con limpieza explícita o `BlocListener` seguro.

### `RNF-05` — Presupuesto de Complejidad Algorítmica (`ARCHITECTURE_RULES`)

| Operación / Estructura | Complejidad Temporal | Complejidad Espacial | Justificación |
| :--- | :--- | :--- | :--- |
| Consulta de actividades por curso (`CourseIndex.forCourse`) | $O(1)$ lookup ($O(m_c)$ copia inmutable) | $O(n)$ total | `HashMap<String, List<Activity>>` |
| Agrupación de actividades por día en calendario | $O(n)$ construcción, $O(1)$ por día | $O(n)$ | `Map<DateTime, List<Activity>>` en 1 pasada |
| Consulta de próxima actividad urgente (`PriorityMinHeap.peekNext`) | $O(1)$ | $O(n)$ | Min-heap binario ordenado por `(priority, start)` |
| Inserción/Extracción en `PriorityMinHeap` / `HeapQueue` | $O(\log n)$ | $O(1)$ auxiliar | Sift-up / sift-down sobre arreglo contiguo |
| Verificación + inserción ordenada en agenda (`ScheduleActivity`) | $O(n)$ (o $O(\log n)$ búsqueda binaria + $O(n)$ inserción) | $O(n)$ nueva lista inmutable | Evita reordenamiento $O(n \log n)$ cuando `S` ya cumple `isSortedByStart(S)` |
| Detección sweep-line (`ConflictDetector.detect`) | $O(n \log n + k)$ | $O(n + k)$ | $k$ = pares solapados; elimina heap muerto |
| Exportación `.ics` / `.csv` (`ExportStrategy.export`) | $O(n)$ | $O(n)$ | Recorrido único con `StringBuffer` y lookup $O(1)$ en `coursesById` |

### `RNF-06` — Verificación Formal con Triplas de Hoare (`FORMAL_VERIFICATION`)
Todo método crítico de negocio en `entities/`, `usecases/`, `algorithms/`, `strategies/`, `repositories/` y `bloc/` **DEBE** estar documentado con el bloque estandarizado:
```dart
// {P} <Precondición formal sobre entradas y estado previo>
// C   <Operación / comando ejecutado>
// {Q} <Postcondición formal ∧ Invariantes de clase preservados>
```

### `RNF-07` — Rendimiento y Escalabilidad
- Mantenimiento de 60 fps ($\le 16\text{ ms}$ por frame) con agendas de hasta $1,000$ actividades y $50$ cursos en dispositivos móviles Android de gama media.
- Prohibido ejecutar `DateFormat(...)`, ordenaciones o filtrados completos por cada celda dentro de `Widget.build` cuando puedan memorizarse o pre-indexarse en estado/selector.

### `RNF-08` — Confiabilidad e Integridad
- Ninguna operación fallida (conflicto de horario, lista vacía al exportar, error de I/O SQLite) puede dejar estado parcialmente mutado ni perder datos persistidos.
- Al reconstruir filas de SQLite hacia el dominio, `Activity.create` actúa como barrera defensiva de invariantes.

### `RNF-09` — Calidad, Testing y Gobernanza Automatizada
- Cobertura objetivo: 100% de triplas de Hoare verificadas por pruebas unitarias en `test/domain_test.dart`, pruebas de `AgendaBloc` (`test/bloc_test.dart`) y pruebas de widgets (`test/widget_test.dart`).
- Auditoría automatizada ejecutada mediante `.agents/skills/architecture-solid-control/scripts/audit_design_rules.ps1` y validada por los agentes `.agents/agents/`.

---

## 6. Modelo de Dominio y Catálogo de Triplas de Hoare

### 6.1 Invariantes de Dominio
- **INV-ACT-1:** $\forall a \in \text{Activity}: a.\text{start} < a.\text{end}$.
- **INV-ACT-2:** $\forall a \in \text{Activity}: 1 \le a.\text{priority} \le 3$.
- **INV-ACT-3:** $\forall a \in \text{Activity}: a.\text{id}.\text{isNotEmpty} \land a.\text{courseId}.\text{isNotEmpty} \land a.\text{title}.\text{trim}().\text{isNotEmpty}$.
- **INV-SCH-1:** $\text{isSortedByStart}(S) \equiv \forall i \in [0, |S|-2]: S[i].\text{start} \le S[i+1].\text{start}$.
- **INV-SCH-2:** $\text{disjoint}(S) \equiv \forall i \ne j: \neg S[i].\text{overlaps}(S[j])$.

### 6.2 Triplas de Hoare Canónicas

1. **`Activity.create`:**
   - `// {P} id.isNotEmpty ∧ courseId.isNotEmpty ∧ title.trim().isNotEmpty ∧ start < end ∧ 1 <= priority <= 3`
   - `// C   Activity.create(...)`
   - `// {Q} result ∈ Activity ∧ INV-ACT-1..3(result) (throws ArgumentError without side effects otherwise)`

2. **`Activity.overlaps`:**
   - `// {P} INV-ACT-1(this) ∧ INV-ACT-1(other)`
   - `// C   overlaps(other)`
   - `// {Q} result ⟺ ([this.start, this.end) ∩ [other.start, other.end) ≠ ∅)`

3. **`ScheduleActivity.call`:**
   - `// {P} INV-ACT-1(a) ∧ isSortedByStart(S) ∧ ¬overlap(a, S \ {x ∈ S | x.id == a.id})`
   - `// C   scheduleActivity(S, a)`
   - `// {Q} S' = (S \ {x | x.id == a.id}) ∪ {a} ∧ isSortedByStart(S') ∧ disjoint(S')`

4. **`ConflictDetector.detect`:**
   - `// {P} ∀ a ∈ E: INV-ACT-1(a)`
   - `// C   detect(E)`
   - `// {Q} (∀ i < j sobre sorted(E): E[i].overlaps(E[j]) ⟺ (E[i], E[j]) ∈ report.conflicts) ∧ report.overloadedMinutes == Σ overlapMinutes(pair)`

5. **`PriorityMinHeap.peekNext` / `popNext`:**
   - `// {P} isNotEmpty ∧ minHeapInvariant(_heap)`
   - `// C   peekNext / popNext()`
   - `// {Q} result == min_{(priority, start)}(_heap) ∧ minHeapInvariant(_heap')`

6. **`CourseIndex.add` / `forCourse`:**
   - `// {P} courseId.isNotEmpty`
   - `// C   forCourse(courseId)`
   - `// {Q} result == List.unmodifiable({a ∈ indexed | a.courseId == courseId}) in O(1) lookup`

7. **`IcsExportStrategy.export`:**
   - `// {P} |E| >= 1 ∧ ∀ a ∈ E: INV-ACT-1(a)`
   - `// C   export(E, coursesById)`
   - `// {Q} validRFC5545(result.content) ∧ count(VEVENT) == |E| ∧ count(VALARM) == |{a ∈ E | a.reminderEnabled}|`

8. **`IScheduleRepository.insertActivity`:**
   - `// {P} INV-ACT-1..3(a)`
   - `// C   insertActivity(a)`
   - `// {Q} persisted(a) in SQLite ∧ toDomain(row(a.id)) == a`

---

## 7. Matriz de Trazabilidad

| Req. ID | Capa / Módulo Responsable | Patrón / Algoritmo | Verificación (Test / Auditoría) |
| :--- | :--- | :--- | :--- |
| `RF-01` | `Domain` (`Activity`) + `Data` (`DriftScheduleRepository`) | Factory Method (`Activity.create`) + Repository | `test/domain_test.dart` (invariantes), Hoare `INV-ACT-*` |
| `RF-02` | `Domain` (`ScheduleActivity`) + `State` (`AgendaBloc`) | UseCase + BLoC | `test/domain_test.dart` (`scheduleActivity`) + `test/bloc_test.dart` |
| `RF-03` | `Domain` (`ConflictDetector`, `HeapQueue`) | Sweep-line + Min-Heap $O(n \log n + k)$ | `test/domain_test.dart` (`Sweep-line`) + cálculo de intersección exacta |
| `RF-04` | `Domain` (`PriorityMinHeap`) + `UI` (resumen Timeline) | Min-Heap binario $O(\log n) / O(1)$ | `test/domain_test.dart` (`PriorityMinHeap`) |
| `RF-05` | `Domain` (`Course`, `CourseIndex`) + `Data` + `UI` | HashMap Index $O(1)$ + Repository | `test/domain_test.dart` (`CourseIndex`) + `audit_design_rules.ps1` |
| `RF-06` | `Presentation` (`TimelineScreen`, `NewActivityFab`) | BLoC Consumer + `AppDesignTokens` | `test/widget_test.dart` + `ui-architect` |
| `RF-07` | `Presentation` (`WeekCalendarScreen`) + `Intl` | Indexado por día $O(n) / O(1)$ | `test/widget_test.dart` (locale `es` sin excepción) |
| `RF-08` | `Domain` (`IcsExportStrategy`, `BuildExportFile`) | Strategy + UseCase $O(n)$ | `test/domain_test.dart` (`buildIcsFile`) |
| `RF-09` | `Domain` (`ExportStrategyFactory`, `CsvExportStrategy`) + `UI` | Factory + Strategy + Jerarquía CTA | `test/domain_test.dart` + `ui-architect` |
| `RF-10` | `Data` (`AppDatabase`, `DriftScheduleRepository`, `LocalExportGateway`) | Repository + DIP (`IScheduleRepository`, `IExportGateway`) | `test/data_test.dart` (`LocalExportGateway`) + `domain-architecture-auditor` |
| `RF-11` | `Presentation/l10n` + `Core/AppConfig` | Inyección `ThemeData` / `ARB` / Config | `audit_design_rules.ps1` (cero strings/colores hardcoded) |
| `RF-12` | `Presentation` (`AppTheme`, Screens) | `Semantics` + WCAG AA + `ThemeExtension` | `test/widget_test.dart` (Semantics finder) + `ui-architect` |
| `RNF-01..09` | Transversal (`.agents/rules/`, `.agents/agents/`, `.agents/skills/`) | Gobernanza multi-agente + Script estático | `design-gatekeeper` + `audit_design_rules.ps1` |
