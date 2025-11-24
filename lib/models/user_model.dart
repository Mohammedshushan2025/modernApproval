class UserModel {
  final int usersCode;
  final String password;
  final String? empName;
  final String? empNameE;
  final String? role_name_a;
  final String? role_name_e;
  final String gender;
  final int? compEmpCode;
  final int? roleCode;

  UserModel({
    required this.usersCode,
    required this.password,
    required this.empName,
    this.empNameE,
    this.role_name_a,
    this.role_name_e,
    required this.gender,
    required this.compEmpCode,
    required this.roleCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      usersCode: json['users_code'],
      password: json['password'],
      empName: json['emp_name'],
      empNameE: json['emp_name_e'],
      role_name_a: json['role_name_a'],
      role_name_e: json['role_name_e'],
      gender: json['gender'],
      compEmpCode: json['comp_emp_code'],
      roleCode: json['role_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users_code': usersCode,
      'password': password,
      'emp_name': empName,
      'emp_name_e': empNameE,
      'role_name_a': role_name_a,
      'role_name_e': role_name_e,
      'gender': gender,
      'comp_emp_code': compEmpCode,
      'role_code': roleCode,
    };
  }
}
