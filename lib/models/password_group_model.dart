class PasswordGroup {
  final int usersCode;
  final int passwordNumber;
  final String passwordName;
  final bool isDefault;

  PasswordGroup({
    required this.usersCode,
    required this.passwordNumber,
    required this.passwordName,
    required this.isDefault,
  });

  factory PasswordGroup.fromJson(Map<String, dynamic> json) {
    return PasswordGroup(
      usersCode: json['users_code'],
      passwordNumber: json['password_number'],
      passwordName: json['password_name'] ?? 'Unnamed Group', // اسم افتراضي
      isDefault: json['isdefault'] == 'Y',
    );
  }
}
