import '../../../utils/package_utility.dart';

class ProductionOutbound {
  final int trnsTypeCode;
  final int trnsSerial;
  final DateTime? reqDate;
  final int? insertUser;
  final DateTime? insertDate;
  final String? descA;
  final String? descE;
  final String? storeName;
  final int fileSerial;
  final int? prevSer;
  final int? usersCode;
  final int? roleCode;
  final String authPk1;
  final String authPk2;
  final int? lastLevel;
  final String? trnsFlag;
  final int? trnsStatus;

  ProductionOutbound({
    required this.trnsTypeCode,
    required this.trnsSerial,
    required this.reqDate,
    this.insertUser,
    required this.insertDate,
    required this.descA,
    this.descE,
    required this.storeName,
    required this.fileSerial,
    required this.prevSer,
    this.usersCode,
    required this.roleCode,
    required this.authPk1,
    required this.authPk2,
    required this.lastLevel,
    this.trnsFlag,
    this.trnsStatus,
  });

  factory ProductionOutbound.fromJson(Map<String, dynamic> json) {
    return ProductionOutbound(
      trnsTypeCode: json['trns_type_code'] ,
      trnsSerial: json['trns_serial'] ,
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      insertUser: json['insert_user'] ,
      insertDate: json['insert_date'] != null ? DateTime.parse(json['insert_date']) : null,
      descA: json['desc_a'] ,
      descE: json['desc_e'] ,
      storeName: json['store_name'] ,
      fileSerial: json['file_serial'] ,
      prevSer: json['prev_ser'] ,
      usersCode: json['users_code'] ,
      roleCode: json['role_code'] ,
      authPk1: json['auth_pk1'] ,
      authPk2: json['auth_pk2'] ,
      lastLevel: json['last_level'] ,
      trnsFlag: json['trns_flag'] ,
      trnsStatus: json['trns_status'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_serial'] = this.trnsSerial;
    data['req_date'] = this.reqDate;
    data['insert_user'] = this.insertUser;
    data['insert_date'] = this.insertDate;
    data['desc_a'] = this.descA;
    data['desc_e'] = this.descE;
    data['store_name'] = this.storeName;
    data['file_serial'] = this.fileSerial;
    data['prev_ser'] = this.prevSer;
    data['users_code'] = this.usersCode;
    data['role_code'] = this.roleCode;
    data['auth_pk1'] = this.authPk1;
    data['auth_pk2'] = this.authPk2;
    data['last_level'] = this.lastLevel;
    data['trns_flag'] = this.trnsFlag;
    data['trns_status'] = this.trnsStatus;
    return data;
  }
  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
