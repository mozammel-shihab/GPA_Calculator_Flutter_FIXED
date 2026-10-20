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

  testWidgets('default login opens the dashboard', (tester) async {
    final store = await AppStore.create();
    await store.completeOnboarding();
    await tester.pumpWidget(GpaApp(store: store));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Email Address'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      AppStore.defaultEmail,
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      AppStore.defaultPassword,
    );
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(store.loggedIn, isTrue);
    expect(store.userEmail, AppStore.defaultEmail);
    expect(find.text('Welcome back, Student 👋'), findsOneWidget);
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
  });

  test('default signup and login persist locally', () async {
    final store = await AppStore.create();

    await store.signUp(
      name: 'Kazi Shihab',
      email: AppStore.defaultEmail,
      password: AppStore.defaultPassword,
      id: 'ST-12',
      uni: 'Example University',
    );

    expect(store.loggedIn, isTrue);
    expect(store.studentName, 'Kazi Shihab');
    expect(store.userEmail, AppStore.defaultEmail);

    await store.logout();
    await store.loginWithEmail(AppStore.defaultEmail, AppStore.defaultPassword);

    expect(store.loggedIn, isTrue);
    expect(store.studentName, 'Kazi Shihab');
  });

  test('other credentials are rejected', () async {
    final store = await AppStore.create();

    expect(
      () async => store.loginWithEmail('someoneelse@gmail.com', '12345678'),
      throwsA(isA<Exception>()),
    );

    expect(
      () async => store.signUp(
        name: 'Other User',
        email: 'someoneelse@gmail.com',
        password: '12345678',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('profile and login state persist locally', () async {
    final store = await AppStore.create();
    await store.loginWithEmail(AppStore.defaultEmail, AppStore.defaultPassword);

    final restoredStore = await AppStore.create();

    expect(restoredStore.loggedIn, isTrue);
    expect(restoredStore.studentName, 'Student');
    expect(restoredStore.userEmail, AppStore.defaultEmail);
  });
}
