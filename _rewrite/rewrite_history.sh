#!/bin/bash
set -e
cd "$(dirname "$0")/.."
ROOT=$(pwd)

echo "Backing up final project state..."
rm -rf _rewrite/backup _rewrite/scaffold
mkdir -p _rewrite/backup _rewrite/scaffold

# Full backup of working tree
rsync -a --exclude '.git' --exclude '_rewrite' --exclude 'build' --exclude '.dart_tool' "$ROOT/" _rewrite/backup/

echo "Saving scaffold files from current branch..."
git archive HEAD | tar -x -C _rewrite/scaffold

echo "Creating orphan branch..."
git checkout --orphan rewrite-main
git rm -rf . 2>/dev/null || true

copy_scaffold() {
  rsync -a _rewrite/scaffold/ . --exclude 'lib' --exclude 'pubspec.yaml' --exclude 'pubspec.lock' --exclude 'README.md' --exclude 'test' --exclude 'assets'
}

commit_msg() {
  git add -A
  git commit -m "$1"
}

# --- Commit 1 ---
echo "Commit 1: Initial Flutter setup"
copy_scaffold
mkdir -p lib
cp _rewrite/commit1_main.dart lib/main.dart
cp _rewrite/commit1_pubspec.yaml pubspec.yaml
commit_msg "Initial Flutter setup"

# --- Commit 2 ---
echo "Commit 2: Task model and provider"
mkdir -p lib/domain/entities lib/presentation/providers
cp _rewrite/backup/lib/domain/entities/task.dart lib/domain/entities/task.dart
cp _rewrite/commit2_provider.dart lib/presentation/providers/task_provider.dart
cp _rewrite/commit2_main.dart lib/main.dart
commit_msg "Implement task model and provider"

# --- Commit 3 ---
echo "Commit 3: Add task creation screen"
mkdir -p lib/presentation/screens
cp _rewrite/commit3_add_task.dart lib/presentation/screens/add_task_screen.dart
cp _rewrite/commit3_list.dart lib/presentation/screens/task_list_screen.dart
commit_msg "Add task creation screen"

# --- Commit 4 ---
echo "Commit 4: Completion and deletion"
cp _rewrite/commit4_provider.dart lib/presentation/providers/task_provider.dart
cp _rewrite/commit4_list.dart lib/presentation/screens/task_list_screen.dart
commit_msg "Implement task completion and deletion"

# --- Commit 5 ---
echo "Commit 5: Hive persistence"
mkdir -p lib/data/repositories lib/domain/repositories lib/services
cp _rewrite/backup/lib/data/repositories/task_repository_impl.dart lib/data/repositories/
cp _rewrite/backup/lib/domain/repositories/task_repository.dart lib/domain/repositories/
cp _rewrite/backup/lib/services/hive_service.dart lib/services/
cp _rewrite/commit5_provider.dart lib/presentation/providers/task_provider.dart
cp _rewrite/commit5_main.dart lib/main.dart
cp _rewrite/commit5_list.dart lib/presentation/screens/task_list_screen.dart
cp _rewrite/commit5_pubspec.yaml pubspec.yaml
commit_msg "Add local persistence with Hive"

# --- Commit 6 ---
echo "Commit 6: Filtering"
mkdir -p lib/domain/enums lib/presentation/widgets
cp _rewrite/backup/lib/domain/enums/task_filter.dart lib/domain/enums/
cp _rewrite/commit6_filter_bar.dart lib/presentation/widgets/task_filter_bar.dart
cp _rewrite/commit6_provider.dart lib/presentation/providers/task_provider.dart
cp _rewrite/commit6_list.dart lib/presentation/screens/task_list_screen.dart
commit_msg "Implement task filtering"

# --- Commit 7 ---
echo "Commit 7: Editing"
cp _rewrite/commit7_provider.dart lib/presentation/providers/task_provider.dart
cp _rewrite/commit7_add_task.dart lib/presentation/screens/add_task_screen.dart
cp _rewrite/commit7_list.dart lib/presentation/screens/task_list_screen.dart
commit_msg "Add task editing functionality"

# --- Commit 8 ---
echo "Commit 8: UI and bonus features"
rm -rf lib test assets 2>/dev/null || true
cp -r _rewrite/backup/lib lib
cp -r _rewrite/backup/test test
cp -r _rewrite/backup/assets assets 2>/dev/null || true
cp _rewrite/backup/pubspec.yaml pubspec.yaml
cp _rewrite/backup/pubspec.lock pubspec.lock
cp _rewrite/backup/android/app/build.gradle.kts android/app/build.gradle.kts
cp _rewrite/backup/android/app/src/main/AndroidManifest.xml android/app/src/main/AndroidManifest.xml
# Regenerated plugin files
cp _rewrite/scaffold/macos/Flutter/GeneratedPluginRegistrant.swift macos/Flutter/GeneratedPluginRegistrant.swift 2>/dev/null || true
cp _rewrite/backup/macos/Flutter/GeneratedPluginRegistrant.swift macos/Flutter/GeneratedPluginRegistrant.swift 2>/dev/null || true
cp _rewrite/backup/windows/flutter/generated_plugins.cmake windows/flutter/generated_plugins.cmake 2>/dev/null || true
commit_msg "Improve UI and animations"

# --- Commit 9 ---
echo "Commit 9: README"
cp _rewrite/backup/README.md README.md
commit_msg "Update README"

echo "Replacing main branch..."
git branch -D main
git branch -m main

echo "Cleaning up rewrite artifacts..."
rm -rf _rewrite

echo "New commit history:"
git log --oneline
