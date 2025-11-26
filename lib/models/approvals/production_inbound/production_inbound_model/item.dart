import 'package:modernapproval/utils/package_utility.dart';

class Item {
  int? trnsTypeCode;
  int? trnsSerial;
  DateTime? reqDate;
  int? insertUser;
  DateTime? insertDate;
  String? descA;
  dynamic descE;
  String? storeName;
  int? fileSerial;
  int? prevSer;
  dynamic usersCode;
  int? roleCode;
  String? authPk1;
  String? authPk2;
  int? lastLevel;
  dynamic trnsFlag;
  dynamic trnsStatus;

  Item({
    this.trnsTypeCode,
    this.trnsSerial,
    this.reqDate,
    this.insertUser,
    this.insertDate,
    this.descA,
    this.descE,
    this.storeName,
    this.fileSerial,
    this.prevSer,
    this.usersCode,
    this.roleCode,
    this.authPk1,
    this.authPk2,
    this.lastLevel,
    this.trnsFlag,
    this.trnsStatus,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    trnsTypeCode: json['trns_type_code'] as int?,
    trnsSerial: json['trns_serial'] as int?,
    reqDate: DateTime.parse(json['req_date'] as String),
    insertUser: json['insert_user'] as int?,
    insertDate: DateTime.parse(json['insert_date'] as String),
    descA: json['desc_a'] as String?,
    descE: json['desc_e'] as dynamic,
    storeName: json['store_name'] as String?,
    fileSerial: json['file_serial'] as int?,
    prevSer: json['prev_ser'] as int?,
    usersCode: json['users_code'] as dynamic,
    roleCode: json['role_code'] as int?,
    authPk1: json['auth_pk1'] as String?,
    authPk2: json['auth_pk2'] as String?,
    lastLevel: json['last_level'] as int?,
    trnsFlag: json['trns_flag'] as dynamic,
    trnsStatus: json['trns_status'] as dynamic,
  );

  Map<String, dynamic> toJson() => {
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

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
