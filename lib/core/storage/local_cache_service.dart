import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

class LocalCacheService {
  static const String _userBox = 'userBox';
  static const String _bookmarksBox = 'bookmarksBox';
  static const String _reportsBox = 'reportsBox';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBox);
    await Hive.openBox(_bookmarksBox);
    await Hive.openBox(_reportsBox);
  }

  // Generic methods
  Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  dynamic getData(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  Future<void> deleteData(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // Pre-defined accessors for features
  Box get userBox => Hive.box(_userBox);
  Box get bookmarksBox => Hive.box(_bookmarksBox);
  Box get reportsBox => Hive.box(_reportsBox);

  Future<void> clearAll() async {
    await userBox.clear();
    await bookmarksBox.clear();
    await reportsBox.clear();
  }
}
