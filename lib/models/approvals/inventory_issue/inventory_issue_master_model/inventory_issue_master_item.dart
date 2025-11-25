import 'package:modernapproval/utils/package_utility.dart';

class InventoryIssueMasterItem {
  int? trnsSerial;
  int? trnsTypeCode;
  DateTime? trnsDate;
  int? storeCode;
  String? storeName;
  int? costCode2;
  int? docNo;
  String? costCode2Name;
  String? descA;
  dynamic descE;
  String? insertUser;
  int? updateUser;
  DateTime? insertDate;
  dynamic auth1Name;
  dynamic auth2Name;

  InventoryIssueMasterItem({
    this.trnsSerial,
    this.trnsTypeCode,
    this.trnsDate,
    this.storeCode,
    this.storeName,
    this.costCode2,
    this.docNo,
    this.costCode2Name,
    this.descA,
    this.descE,
    this.insertUser,
    this.updateUser,
    this.insertDate,
    this.auth1Name,
    this.auth2Name,
  });

  factory InventoryIssueMasterItem.fromJson(Map<String, dynamic> json) =>
      InventoryIssueMasterItem(
        trnsSerial: json['trns_serial'] as int?,
        trnsTypeCode: json['trns_type_code'] as int?,
        trnsDate:
            json['trns_date'] != null
                ? DateTime.parse(json['trns_date'])
                : null,
        storeCode: json['store_code'] as int?,
        storeName: json['store_name'] as String?,
        costCode2: json['cost_code2'] as int?,
        docNo: json['doc_no'] as int?,
        costCode2Name: json['cost_code2_name'] as String?,
        descA: json['desc_a'] as String?,
        descE: json['desc_e'] as dynamic,
        insertUser: json['insert_user'] as String?,
        updateUser: json['update_user'] as int?,
        insertDate:
            json['insert_date'] != null
                ? DateTime.parse(json['insert_date'])
                : null,
        auth1Name: json['auth1_name'] as dynamic,
        auth2Name: json['auth2_name'] as dynamic,
      );

  Map<String, dynamic> toJson() => {
    'trns_serial': trnsSerial,
    'trns_type_code': trnsTypeCode,
    'trns_date': trnsDate,
    'store_code': storeCode,
    'store_name': storeName,
    'cost_code2': costCode2,
    'doc_no': docNo,
    'cost_code2_name': costCode2Name,
    'desc_a': descA,
    'desc_e': descE,
    'insert_user': insertUser,
    'update_user': updateUser,
    'insert_date': insertDate,
    'auth1_name': auth1Name,
    'auth2_name': auth2Name,
  };

  String get formattedTrnsDate {
    return formatDate(trnsDate);
  }

  String get formattedInsertDate {
    return formatDate(insertDate);
  }
}
