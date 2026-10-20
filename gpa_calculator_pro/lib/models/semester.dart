import 'course.dart';

const Map<String, double> defaultScale = {
  'A+': 4.00,
  'A': 4.00,
  'A-': 3.70,
  'B+': 3.30,
  'B': 3.00,
  'B-': 2.70,
  'C+': 2.30,
  'C': 2.00,
  'D': 1.00,
  'F': 0.00,
};

class SemesterRecord {
  final String semester;
  final DateTime date;
  final List<Course> courses;
  final Map<String, double> scale;

  SemesterRecord({
    required this.semester,
    required this.date,
    required this.courses,
    required this.scale,
  });

  double get totalCredits => courses.fold(0.0, (sum, c) => sum + c.credit);

  double get totalGradePoints => courses.fold(
        0.0,
        (sum, c) => sum + c.credit * (scale[c.grade] ?? 0.0),
      );

  double get gpa => totalCredits <= 0 ? 0.0 : totalGradePoints / totalCredits;

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'date': date.toIso8601String(),
        'courses': courses.map((c) => c.toJson()).toList(),
        'scale': scale,
      };

  factory SemesterRecord.fromJson(Map<String, dynamic> json) {
    final rawScale = json['scale'];
    final scale = <String, double>{};
    if (rawScale is Map) {
      rawScale.forEach((key, value) {
        if (value is num) scale[key.toString()] = value.toDouble();
      });
    }
    if (scale.isEmpty) scale.addAll(defaultScale);

    final rawCourses = json['courses'];
    final courses = <Course>[];
    if (rawCourses is List) {
      for (final item in rawCourses) {
        if (item is Map) {
          courses.add(Course.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SemesterRecord(
      semester: json['semester']?.toString() ?? 'Semester',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      courses: courses,
      scale: scale,
    );
  }
}
