import 'package:hive_flutter/hive_flutter.dart';

class PreferencesService {
  static const String boxName = 'preferences';
  static const String themeModeKey = 'theme_mode';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  static String? getThemeMode() => _box.get(themeModeKey) as String?;

  static Future<void> saveThemeMode(String mode) async {
    await _box.put(themeModeKey, mode);
  }
}
