import '../utils/package_utility.dart';

///this class is for either Approval requests or Rejected requests
class RequestItem {
  int? systemNumber;
  int? fileSerial;
  int? usersCode;
  String? trnsDesc;
  String? authPk1;
  String? authPk2;
  DateTime? trnsDate;
  int? storeCode;
  String? storeName;

  RequestItem({
    this.systemNumber,
    this.fileSerial,
    this.usersCode,
    this.trnsDesc,
    this.authPk1,
    this.authPk2,
    this.trnsDate,
    this.storeCode,
    this.storeName,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      systemNumber: json['system_number'],
      fileSerial: json['file_serial'],
      usersCode: json['users_code'],
      trnsDesc: json['trns_desc'],
      authPk1: json['auth_pk1'],
      authPk2: json['auth_pk2'],
      trnsDate:
          json['trns_date'] != null ? DateTime.parse(json['trns_date']) : null,
      storeCode: json['store_code'],
      storeName: json['store_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['system_number'] = this.systemNumber;
    data['file_serial'] = this.fileSerial;
    data['users_code'] = this.usersCode;
    data['trns_desc'] = this.trnsDesc;
    data['auth_pk1'] = this.authPk1;
    data['auth_pk2'] = this.authPk2;
    data['trns_date'] = this.trnsDate;
    data['store_code'] = this.storeCode;
    data['store_name'] = this.storeName;
    return data;
  }

  String get formattedTrnsDate {
    return formatDate(trnsDate);
  }
}
