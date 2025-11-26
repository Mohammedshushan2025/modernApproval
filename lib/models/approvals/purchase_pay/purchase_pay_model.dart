import '../../../utils/package_utility.dart';

class PurchasePay {
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
  final dynamic trnsFlag;
  final dynamic trnsStatus;

  PurchasePay({
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

  factory PurchasePay.fromJson(Map<String, dynamic> json) {
    return PurchasePay(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      reqDate:
          json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      insertUser: json['insert_user'],
      insertDate:
          json['insert_date'] != null
              ? DateTime.parse(json['insert_date'])
              : null,
      descA: json['desc_a'],
      descE: json['desc_e'],
      storeName: json['store_name'],
      fileSerial: json['file_serial'],
      prevSer: json['prev_ser'],
      usersCode: json['users_code'],
      roleCode: json['role_code'],
      authPk1: json['auth_pk1'],
      authPk2: json['auth_pk2'],
      lastLevel: json['last_level'],
      trnsFlag: json['trns_flag'],
      trnsStatus: json['trns_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trns_type_code': trnsTypeCode,
      'trns_serial': trnsSerial,
      'req_date': reqDate,
      'insert_user': insertUser,
      'insert_date': insertDate,
      'desc_a': descA,
      'desc_e': descE,
      'store_name': storeName,
      'file_serial': fileSerial,
      'prev_ser': prevSer,
      'users_code': usersCode,
      'role_code': roleCode,
      'auth_pk1': authPk1,
      'auth_pk2': authPk2,
      'last_level': lastLevel,
      'trns_flag': trnsFlag,
      'trns_status': trnsStatus,
    };
  }

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
