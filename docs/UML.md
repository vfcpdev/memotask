# Arquitectura y Modelado UML — MemoTask

**Propósito:** Proveer la vista estructural, comportamental, de datos y de gobernanza para la arquitectura objetivo SOLID de MemoTask (`UI/Presentation`, `State/AppLogic`, `Domain`, `Data`), trazable al [SRS.md](file:///d:/Documents/SideProjects/MemoTask/docs/SRS.md).

---

## 1. Diagrama de Casos de Uso

```mermaid
flowchart LR
    Estudiante(["Estudiante"])
    Sistema["Sistema de Archivos / Calendario Externo"]

    subgraph MemoTask["MemoTask · Agenda Estudiantil"]
        UC1(["UC-01: Consultar Timeline Diario"])
        UC2(["UC-02: Agendar Actividad sin Solapamiento"])
        UC3(["UC-03: Eliminar o Editar Actividad"])
        UC4(["UC-04: Gestionar Cursos"])
        UC5(["UC-05: Consultar Calendario Semanal"])
        UC6(["UC-06: Detectar Conflictos y Sobrecarga"])
        UC7(["UC-07: Priorizar Próxima Actividad Urgente"])
        UC8(["UC-08: Exportar Agenda .ics / .csv"])
    end

    Estudiante --> UC1
    Estudiante --> UC2
    Estudiante --> UC3
    Estudiante --> UC4
    Estudiante --> UC5
    Estudiante --> UC8
    UC2 -.->|"include: valida invariantes y orden"| UC6
    UC1 -.->|"include: consulta min-heap O(1)"| UC7
    UC8 --> Sistema
```

---

## 2. Arquitectura en Capas e Inversión de Dependencias (DIP)

```mermaid
flowchart TB
    subgraph UI["UI / Presentation Layer (Flutter Material 3 + l10n + AppDesignTokens)"]
        Screens["TimelineScreen / WeekCalendarScreen / ExportScreen / ActivityFormModal"]
        Theme["AppTheme + AppDesignTokens"]
    end

    subgraph State["State / AppLogic Layer (BLoC)"]
        Bloc["AgendaBloc / AgendaEvent / AgendaState"]
    end

    subgraph Domain["Domain Layer (Dart Puro — Cero Flutter/Drift)"]
        Entities["Activity / Course"]
        Algorithms["ConflictDetector / PriorityMinHeap / DayScheduleIndex / CourseIndex"]
        UseCases["ScheduleActivity / BuildExportFile"]
        Strategies["ExportStrategy / ExportStrategyFactory / ICS / CSV"]
        Ports["Interfaces DIP: IScheduleRepository / IExportGateway"]
    end

    subgraph Data["Data Layer (Platform Bootstrap: Drift SQLite IO / Web localStorage)"]
        RepoImpl["DriftScheduleRepository / WebScheduleRepository"]
        ExportImpl["LocalExportGateway / WebExportGateway"]
        DB["AppDatabase (Courses, Activities) / Web localStorage"]
    end

    Screens -->|"Dispatch Events / Observe State"| Bloc
    Screens -->|"Consume tokens vía Theme.of"| Theme
    Bloc -->|"Ejecuta"| UseCases
    Bloc -->|"Consulta"| Algorithms
    Bloc -->|"Depende de abstracciones (DIP)"| Ports
    UseCases -->|"Usa"| Entities
    UseCases -->|"Usa"| Strategies
    RepoImpl -.->|"implements"| Ports
    ExportImpl -.->|"implements"| Ports
    RepoImpl -->|"Mapea *Row <-> Entity"| DB
    ExportImpl -->|"Invoca Factory + Strategy"| Strategies
```

---

## 3. Diagrama de Clases Completo (Arquitectura Objetivo SOLID + Patrones)

```mermaid
classDiagram
    direction TB

    class Activity {
        +String id
        +String courseId
        +String title
        +String description
        +DateTime start
        +DateTime end
        +int priority
        +bool reminderEnabled
        -Activity._()
        +create(...) Activity$
        +overlaps(Activity other) bool
        +copyWith(...) Activity
    }

    class Course {
        +String id
        +String name
        +String professor
    }

    class IScheduleRepository {
        <<interface>>
        +getCourses() Future~List~Course~~
        +upsertCourse(Course course) Future~void~
        +getActivities() Future~List~Activity~~
        +insertActivity(Activity activity) Future~void~
        +deleteActivity(String id) Future~void~
    }

    class IExportGateway {
        <<interface>>
        +availableFormats() Set~String~
        +exportToFile(String formatKey, List~Activity~ activities, Map~String, Course~ coursesById) Future~String~
    }

    class ScheduleActivity {
        +call(List~Activity~ schedule, Activity a) ActivityScheduleSuccess
    }

    class BuildExportFile {
        +ExportStrategy strategy
        +call(List~Activity~ activities, Map~String, Course~ coursesById) ExportResult
    }

    class ExportStrategy {
        <<abstract>>
        +String fileExtension
        +String mimeType
        +export(List~Activity~ activities, Map~String, Course~ coursesById) ExportResult
    }

    class IcsExportStrategy {
        +Duration alarmLead
        +export(List~Activity~ activities, Map~String, Course~ coursesById) ExportResult
    }

    class CsvExportStrategy {
        +export(List~Activity~ activities, Map~String, Course~ coursesById) ExportResult
    }

    class ExportStrategyFactory {
        -Map~String, ExportStrategy~ _registry
        +strategyFor(String formatKey) ExportStrategy
        +availableFormats() Set~String~
    }

    class ConflictDetector {
        +detect(List~Activity~ activities) ConflictReport
    }

    class PriorityMinHeap {
        -HeapQueue~Activity~ _heap
        +bool isNotEmpty
        +Activity peekNext
        +add(Activity a) void
        +popNext() Activity
        +drain() List~Activity~
    }

    class DayScheduleIndex {
        -Map~DateTime, List~Activity~~ _byDay
        +normalizeDay(DateTime dt)$ DateTime
        +fromActivities(List~Activity~ activities)$ DayScheduleIndex
        +forDay(DateTime day) List~Activity~
    }

    class CourseIndex {
        -HashMap~String, List~Activity~~ _byCourse
        +add(Activity a) void
        +forCourse(String courseId) List~Activity~
    }

    class DriftScheduleRepository {
        -AppDatabase _db
        +getCourses() Future~List~Course~~
        +upsertCourse(Course course) Future~void~
        +getActivities() Future~List~Activity~~
        +insertActivity(Activity activity) Future~void~
        +deleteActivity(String id) Future~void~
    }

    class LocalExportGateway {
        +ExportStrategyFactory factory
        +exportToFile(...) Future~String~
    }

    class WebScheduleRepository {
        +getCourses() Future~List~Course~~
        +upsertCourse(Course course) Future~void~
        +getActivities() Future~List~Activity~~
        +insertActivity(Activity activity) Future~void~
        +deleteActivity(String id) Future~void~
    }

    class WebExportGateway {
        +ExportStrategyFactory factory
        +exportToFile(...) Future~String~
    }

    class AppDatabase {
        +int schemaVersion
        +Courses courses
        +Activities activities
    }

    class AgendaBloc {
        +IScheduleRepository repository
        +IExportGateway exportGateway
        +ScheduleActivity scheduleActivity
        +ConflictDetector conflictDetector
        +onLoaded()
        +onActivityCreated()
        +onActivityDeleted()
        +onCourseUpserted()
        +onDaySelected()
        +onExportRequested()
        +onFeedbackCleared()
    }

    class AgendaFailure {
        +AgendaErrorCode code
        +String? conflictExistingTitle
        +String? conflictIncomingTitle
    }

    class AgendaState {
        +List~Activity~ activities
        +Map~String, Course~ courses
        +Map~DateTime, List~Activity~~ activitiesByDay
        +DateTime? selectedDay
        +Activity? nextUrgentActivity
        +ConflictReport conflictReport
        +bool loading
        +AgendaFailure? failure
        +String? exportedFilePath
        +visibleActivities() List~Activity~
    }

    class AppDesignTokens {
        +Color brandNavy
        +Color surfaceNavy
        +Color accentLime
        +Color onNavy
        +Color onLime
        +double spaceSm
        +double spaceMd
        +double radiusMd
    }

    IScheduleRepository <|.. DriftScheduleRepository
    IScheduleRepository <|.. WebScheduleRepository
    IExportGateway <|.. LocalExportGateway
    IExportGateway <|.. WebExportGateway
    ExportStrategy <|-- IcsExportStrategy
    ExportStrategy <|-- CsvExportStrategy
    ExportStrategyFactory --> ExportStrategy : creates
    BuildExportFile --> ExportStrategy : uses
    LocalExportGateway --> ExportStrategyFactory : resolves
    LocalExportGateway --> BuildExportFile : executes
    WebExportGateway --> ExportStrategyFactory : resolves
    WebExportGateway --> BuildExportFile : executes
    DriftScheduleRepository --> AppDatabase : persists
    AgendaBloc --> IScheduleRepository : depends on
    AgendaBloc --> IExportGateway : depends on
    AgendaBloc --> ScheduleActivity : executes
    AgendaBloc --> ConflictDetector : analyzes
    AgendaBloc --> PriorityMinHeap : prioritizes
    AgendaBloc --> DayScheduleIndex : indexes by day
    AgendaBloc --> AgendaState : emits
    AgendaState --> AgendaFailure : carries
    ScheduleActivity --> Activity : validates
    AgendaState --> Activity : holds
    AgendaState --> Course : holds
```

---

## 4. Diagrama de Secuencia — Agendar Actividad con Verificación Hoare

```mermaid
sequenceDiagram
    actor U as Estudiante
    participant F as ActivityFormModal
    participant A as ActivityCreateAdapter
    participant B as AgendaBloc
    participant UC as ScheduleActivity
    participant R as IScheduleRepository
    participant DB as AppDatabase

    U->>F: Completa título, curso, [start, end), prioridad
    F->>F: Valida campos obligatorios y start < end
    F-->>A: ActivityDraft
    A->>A: Activity.create() [Hoare: start < end ∧ priority in 1..3]
    A-->>B: AgendaActivityCreated(activity)

    B->>UC: call(state.activities, activity)
    alt Precondición fallida (solapamiento detectado)
        UC-->>B: throws ScheduleConflictException
        B-->>F: AgendaState(failure: scheduleConflict, schedule intacto)
    else Precondición satisfecha (disjoint ∧ sorted)
        UC-->>B: ActivityScheduleSuccess(newSchedule)
        B->>R: insertActivity(activity)
        R->>DB: transaction(insertOrIgnore Course + insertOnConflictUpdate Activity)
        DB-->>R: OK
        R-->>B: Future<void>
        B->>B: Reconstruye PriorityMinHeap, DayScheduleIndex y ConflictReport
        B-->>F: AgendaState(activities: newSchedule, failure: null)
    end
```

---

## 5. Diagrama de Secuencia — Exportación Polimórfica (Factory + Strategy)

```mermaid
sequenceDiagram
    actor U as Estudiante
    participant UI as ExportScreen
    participant B as AgendaBloc
    participant GW as IExportGateway
    participant F as ExportStrategyFactory
    participant UC as BuildExportFile
    participant S as ExportStrategy (ICS o CSV)
    participant FS as FileSystem

    U->>UI: Pulsa CTA Exportar (.ics o .csv)
    UI->>B: AgendaExportRequested(formatKey)
    alt state.activities.isEmpty
        B-->>UI: AgendaState(errorCode: emptyExport)
    else |activities| >= 1
        B->>GW: exportToFile(formatKey, activities, courses)
        GW->>F: strategyFor(formatKey)
        F-->>GW: IcsExportStrategy o CsvExportStrategy
        GW->>UC: BuildExportFile(strategy).call(activities, courses)
        UC->>S: export(activities, courses)
        S-->>UC: ExportResult(content, fileName, mimeType)
        UC-->>GW: ExportResult
        GW->>FS: writeAsString(content, flush: true)
        FS-->>GW: filePath
        GW-->>B: filePath
        B-->>UI: AgendaState(exportedFilePath: filePath)
        UI->>UI: Muestra SnackBar localizado
        UI->>B: AgendaFeedbackCleared()
        B-->>UI: AgendaState(exportedFilePath: null)
    end
```

---

## 6. Diagrama de Secuencia — Inicialización, Carga e Indexación

```mermaid
sequenceDiagram
    participant M as main.dart
    participant App as App (Composition Root)
    participant B as AgendaBloc
    participant R as IScheduleRepository
    participant Alg as Domain Algorithms

    M->>App: App(db: AppDatabase())
    App->>B: create AgendaBloc + add(AgendaLoaded())
    B-->>App: AgendaState(loading: true)
    B->>R: getActivities() & getCourses()
    R-->>B: activities (revalidadas vía Activity.create), courses
    B->>B: Ordena activities por start [INV-SCH-1]
    B->>Alg: Construye PriorityMinHeap + DayScheduleIndex O(n)
    B->>Alg: ConflictDetector.detect(activities)
    Alg-->>B: nextUrgentActivity + conflictReport
    B-->>App: AgendaState(loading: false, data listo)
```

---

## 7. Diagrama de Estados — `AgendaBloc`

```mermaid
stateDiagram-v2
    [*] --> Initial
    Initial --> Loading : AgendaLoaded
    Loading --> Ready : loadSuccess (ordenado e indexado)
    Loading --> Error : loadFailure

    Ready --> Scheduling : AgendaActivityCreated
    Scheduling --> Ready : scheduleSuccess ∧ persisted
    Scheduling --> Error : ScheduleConflictException / IOError

    Ready --> Updating : AgendaActivityDeleted / AgendaCourseUpserted / AgendaDaySelected
    Updating --> Ready : mutationSuccess
    Updating --> Error : IOError

    Ready --> Exporting : AgendaExportRequested
    Exporting --> ExportSuccess : fileWritten
    Exporting --> Error : emptyList / IOError
    ExportSuccess --> Ready : AgendaFeedbackCleared

    Error --> Ready : AgendaFeedbackCleared
    Error --> Loading : AgendaLoaded
```

---

## 8. Diagrama Entidad-Relación — Esquema SQLite / Drift

```mermaid
erDiagram
    COURSES {
        TEXT id PK "Identificador normalizado (ej. MAT101)"
        TEXT name "Nombre de la asignatura"
        TEXT professor "Docente responsable"
    }

    ACTIVITIES {
        TEXT id PK "UUID v4"
        TEXT course_id FK "Referencia a COURSES.id (INDEX)"
        TEXT title "Título conciso de la actividad"
        TEXT description "Detalle opcional"
        INTEGER start "Timestamp epoch (INDEX, CHECK start < end)"
        INTEGER end "Timestamp epoch"
        INTEGER priority "Rango 1..3 (1 = máxima)"
        INTEGER reminder_enabled "Booleano 0/1 (VALARM -PT30M)"
    }

    COURSES ||--o{ ACTIVITIES : "agrupa"
```

---

## 9. Flujo de Gobernanza de Diseño (Agentes y Skills)

```mermaid
flowchart LR
    Req["Cambio o Feature en MemoTask"] --> Rules["Reglas Automáticas (.agents/rules/ + AGENTS.md)"]
    Rules --> UIAgent["ui-architect (Skill: ui-design-control)"]
    Rules --> ArchAgent["domain-architecture-auditor (Skill: architecture-solid-control)"]
    Rules --> HoareAgent["hoare-formal-verifier (Skill: hoare-verification-control)"]
    UIAgent --> Sync["Skill: srs-uml-sync"]
    ArchAgent --> Sync
    HoareAgent --> Sync
    Sync --> Script["audit_design_rules.ps1 + flutter test"]
    Script --> Gate["design-gatekeeper"]
    Gate -->|"PASS"| Ready["Código Listo para Producción"]
    Gate -->|"BLOCK"| Req
```
