import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/config/app_config.dart';

part 'app_database.g.dart';

@DataClassName('CourseRow')
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get professor => text().named('professor')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ActivityRow')
@TableIndex(name: 'idx_activities_start', columns: {#start})
@TableIndex(name: 'idx_activities_course_id', columns: {#courseId})
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get courseId =>
      text().named('course_id').references(Courses, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  BoolColumn get reminderEnabled =>
      boolean().named('reminder_enabled').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Courses, Activities])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static LazyDatabase _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, AppConfig.databaseFileName));
      return NativeDatabase.createInBackground(file);
    });
  }
}
