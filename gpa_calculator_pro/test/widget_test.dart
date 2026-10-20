import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gpa_calculator_pro/main.dart';
import 'package:gpa_calculator_pro/models/course.dart';
import 'package:gpa_calculator_pro/models/semester.dart';
import 'package:gpa_calculator_pro/services/app_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('semester GPA is weighted by course credits', () {
    final semester = SemesterRecord(
      semester: 'Fall 2026',
      date: DateTime(2026, 9),
      courses: [
        Course(name: 'Biology', credit: 4, grade: 'A'),
        Course(name: 'History', credit: 2, grade: 'B'),
      ],
      scale: defaultScale,
    );

    expect(semester.totalCredits, 6);
    expect(semester.totalGradePoints, 22);
    expect(semester.gpa, closeTo(22 / 6, 0.0001));
  });

  test('semester records round-trip through JSON', () {
    final semester = SemesterRecord(
      semester: 'Spring 2026',
      date: DateTime(2026, 2, 10),
      courses: [Course(name: 'Math', code: 'M101', credit: 3, grade: 'A-')],
      scale: defaultScale,
    );

    final restored = SemesterRecord.fromJson(semester.toJson());

    expect(restored.semester, semester.semester);
    expect(restored.date, semester.date);
    expect(restored.courses.single.name, 'Math');
    expect(restored.courses.single.credit, 3);
    expect(restored.gpa, closeTo(3.7, 0.0001));
  });

  testWidgets('signup and login works for multiple users', (tester) async {
    final store = await AppStore.create();
    await store.signUp(
      name: 'Alice',
      email: 'alice@example.com',
      password: 'secure123',
    );

    expect(store.loggedIn, isTrue);
    expect(store.userEmail, 'alice@example.com');

    await store.logout();
    await store.loginWithEmail('alice@example.com', 'secure123');
    expect(store.studentName, 'Alice');

    await store.signUp(
      name: 'Bob',
      email: 'bob@example.com',
      password: 'strong456',
    );

    expect(store.studentName, 'Bob');
    expect(store.userEmail, 'bob@example.com');
  });

  testWidgets('onboarding advances and persists completion', (tester) async {
    final store = await AppStore.create();
    await tester.pumpWidget(GpaApp(store: store));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Calculate every semester'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('See your progress clearly'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(store.onboardingComplete, isTrue);
    expect(find.text('Email Address'), findsOneWidget);

    await tester.tap(find.text('Need an account? Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Student Name'), findsOneWidget);
  });

  test('notification is created when GPA is saved', () async {
    final store = await AppStore.create();
    await store.signUp(
      name: 'Amina',
      email: 'amina@example.com',
      password: 'secret123',
    );

    final record = SemesterRecord(
      semester: 'Spring 2026',
      date: DateTime(2026, 2, 10),
      courses: [
        Course(name: 'Math', code: 'M101', credit: 3, grade: 'A'),
      ],
      scale: defaultScale,
    );

    await store.addRecord(record);

    expect(store.notifications, isNotEmpty);
    expect(store.notifications.first.title, contains('GPA'));
  });

  test('profile and login state persist locally', () async {
    final store = await AppStore.create();
    await store.signUp(
      name: 'Amina',
      email: 'amina@example.com',
      password: 'secret123',
    );

    final restoredStore = await AppStore.create();

    expect(restoredStore.loggedIn, isTrue);
    expect(restoredStore.studentName, 'Amina');
    expect(restoredStore.userEmail, 'amina@example.com');
  });
}
