# Task Manager

An offline-first Flutter task manager built as a take-home assignment. Users can create, edit, delete, and complete tasks with local persistence — no network required.

## Features

- **Task CRUD** — Create, edit, delete, and mark tasks as completed
- **Task fields** — Title (required), description, due date, priority (Low / Medium / High)
- **Offline storage** — Tasks persist locally using Hive
- **Filtering** — View all, completed, or pending tasks
- **UI states** — Loading, empty, and error states with retry support
- **Animations** — Subtle transitions when switching views and displaying task items

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- A connected device or emulator (iOS, Android, macOS, etc.)

### Run the app

```bash
# Clone the repository
git clone <your-repo-url>
cd task_manager

# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

### Run tests

```bash
flutter test
```

### Analyze code

```bash
flutter analyze
```

## Architecture

The project follows a layered clean architecture:

```
lib/
├── domain/           # Business entities and contracts
│   ├── entities/     # Task model
│   ├── enums/        # TaskFilter (All / Completed / Pending)
│   └── repositories/ # TaskRepository abstract interface
├── data/             # Data layer implementations
│   └── repositories/ # TaskRepositoryImpl (Hive-backed)
├── services/         # Platform / infrastructure services
│   └── hive_service.dart
└── presentation/     # UI layer
    ├── providers/    # TaskProvider (ChangeNotifier)
    ├── screens/      # TaskListScreen, AddTaskScreen
    └── widgets/      # TaskCard, TaskFilterBar, EmptyTasksView
```

### Data flow

1. **UI** (`screens`, `widgets`) listens to `TaskProvider` and dispatches user actions.
2. **Provider** holds application state and business logic (filtering, CRUD).
3. **Repository** (`TaskRepository` interface) abstracts storage details.
4. **HiveService** reads/writes a JSON list of task maps to a Hive box.

### State management

[Provider](https://pub.dev/packages/provider) with `ChangeNotifier` (`TaskProvider`) keeps state management simple and appropriate for this scope — no over-engineering with heavier solutions.

### Local storage

[Hive](https://pub.dev/packages/hive) stores tasks as a single list of JSON-compatible maps under the key `task_list`. Each task is serialized via `toMap()` / `fromMap()` — no TypeAdapters or code generation.

## Assumptions & Trade-offs

| Decision | Rationale |
|---|---|
| **Hive over SQLite** | Simpler setup for a key-value list of tasks; no SQL schema or migrations needed for this data shape. |
| **Full-list save** | All tasks are saved as one list on every change. Simple and reliable for small task counts; would need per-item or paginated storage at scale. |
| **String-based priority** | Priority is stored as `"Low"`, `"Medium"`, `"High"` strings rather than an enum with Hive adapters — keeps serialization straightforward. |
| **ID via timestamp** | Task IDs are generated from `DateTime.now().millisecondsSinceEpoch` — sufficient for a local-only app with no sync. |
| **Provider over Bloc/Riverpod** | Matches assignment scope; avoids boilerplate for a single feature domain. |
| **No use-case layer** | Repository + Provider is enough separation for this app size; a use-case layer would add indirection without clear benefit here. |

## Project structure notes

- Business logic lives in `TaskProvider`, not in UI widgets.
- `AddTaskScreen` is reused for both creating and editing tasks (pass optional `taskId`).
- Reusable widgets: `TaskCard`, `TaskFilterBar`, `EmptyTasksView`.

## Screenshots

<!-- Optional: add screenshots or GIFs here before submission -->
_Screenshots can be added to this section._
