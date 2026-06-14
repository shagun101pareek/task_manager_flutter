# Offline First Task Manager

A Flutter application for managing tasks with offline persistence using Hive.

## Features

* Create Tasks
* Edit Tasks
* Delete Tasks
* Mark Tasks as Completed
* Filter Tasks (All, Completed, Pending)
* Search Tasks by Title
* Sort Tasks by Priority or Due Date
* Swipe to Delete with Undo
* Dark Mode Support
* Local Notifications for Due Tasks
* Offline Storage using Hive
* Form Validation
* Priority Levels (Low, Medium, High)
* Responsive UI with Glass-style Cards
* Basic Animations

## Tech Stack

* Flutter
* Dart
* Provider (State Management)
* Hive (Local Storage)
* flutter_local_notifications (Due Date Reminders)

## Project Structure

```
lib/
├── data/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── enums/
│   └── repositories/
├── presentation/
│   ├── providers/
│   ├── screens/
│   ├── theme/
│   └── widgets/
├── services/
└── main.dart
```

## Setup Instructions

1. Clone the repository

```bash
git clone <repository-url>
```

2. Navigate to the project

```bash
cd task_manager
```

3. Install dependencies

```bash
flutter pub get
```

4. Run the application

```bash
flutter run
```

5. Run tests (optional)

```bash
flutter test
```

## Architectural Decisions

* Provider is used for state management due to its simplicity and readability.
* Hive is used for local persistence to support offline-first functionality.
* Tasks are stored as JSON maps using `toMap()` and `fromMap()` without TypeAdapters.
* A repository layer separates business logic from storage implementation.
* Business logic lives in providers; UI widgets remain presentation-focused.
* Folder structure follows separation of concerns (data, domain, presentation, services).

## Assumptions & Trade-offs

* No backend integration was implemented as per assignment requirements.
* Authentication was intentionally omitted.
* Tasks are saved as a full list on each change — simple and reliable for small datasets.
* Notification reminders are scheduled for 9:00 AM on the due date.
* Focus was placed on maintainable architecture and offline functionality rather than pixel-perfect UI.

## Future Improvements

* Task categories or tags
* Recurring tasks
* Cloud sync and backup
* Widget / home screen shortcuts
