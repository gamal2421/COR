import 'dart:developer';

class CVDetails {
  final String level;
  final String role;
  final String skillset;
  final List<String> additionalDetails;

  CVDetails({
    required this.level,
    required this.role,
    required this.skillset,
    this.additionalDetails = const [],
  });

  factory CVDetails.fromString(String details) {
    // إزالة أي علامات اقتباس حول السلسلة
    details = details.replaceAll(RegExp(r'^"|"$'), '');

    log('details>>>>>>: $details');
    // تقسيم السلسلة حسب الفواصل
    List<String> processedDetails = details.split('\\n');

    // تحديد التفاصيل الأساسية
    String level = '';
    String role = '';
    String skillset = '';
    List<String> additionalDetails = [];

    // معالجة التفاصيل حسب التنسيق
    for (var detail in processedDetails) {
      if (detail.startsWith('Level:')) {
        level = _extractValue(detail, 'Level:');
      } else if (detail.startsWith('Developer Role:')) {
        role = _extractValue(detail, 'Developer Role:');
      } else if (detail.startsWith('Skillset:')) {
        skillset = _extractValue(detail, 'Skillset:');
      } else {
        additionalDetails.add(detail.trim()); // إضافة التفاصيل الإضافية
      }
    }

    // التحقق من وجود تفاصيل أساسية
    if (level.isEmpty || role.isEmpty || skillset.isEmpty) {
      throw ArgumentError('Missing required CV details');
    }

    return CVDetails(
      level: level,
      role: role,
      skillset: skillset,
      additionalDetails: additionalDetails,
    );
  }

  static String _extractValue(String detail, String label) {
    return detail.substring(detail.indexOf(label) + label.length).trim();
  }

  @override
  String toString() {
    return 'CVDetails(level: $level, role: $role, skillset: $skillset, additionalDetails: $additionalDetails)';
  }
}
