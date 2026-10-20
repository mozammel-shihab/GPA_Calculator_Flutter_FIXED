class Course {
  String name;
  String code;
  double credit;
  String grade;

  Course({
    this.name = '',
    this.code = '',
    this.credit = 3.0,
    this.grade = 'A',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
        'credit': credit,
        'grade': grade,
      };

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      credit: (json['credit'] as num?)?.toDouble() ?? 3.0,
      grade: json['grade']?.toString() ?? 'A',
    );
  }
}
