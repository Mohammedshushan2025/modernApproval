import '../../../utils/package_utility.dart';

class ProductionOutboundMaster {
  int? trnsSerial;
  int? trnsTypeCode;
  DateTime? trnsDate;
  int? storeCode;
  String? storeName;
  String? costCode2;
  int? docNo;
  String? costCode2Name;
  String? descA;
  String? descE;
  String? insertUser;
  String? updateUser;
  DateTime? insertDate;
  String? auth1Name;
  String? auth2Name;

  ProductionOutboundMaster({
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

  factory ProductionOutboundMaster.fromJson(Map<String, dynamic> json) {
    return ProductionOutboundMaster(
      trnsSerial: json['trns_serial'],
      trnsTypeCode: json['trns_type_code'],
      trnsDate:
          json['trns_date'] != null ? DateTime.parse(json['trns_date']) : null,
      storeCode: json['store_code'],
      storeName: json['store_name'],
      costCode2: json['cost_code2'],
      docNo: json['doc_no'],
      costCode2Name: json['cost_code2_name'],
      descA: json['desc_a'],
      descE: json['desc_e'],
      insertUser: json['insert_user'],
      updateUser: json['update_user'],
      insertDate:
          json['insert_date'] != null
              ? DateTime.parse(json['insert_date'])
              : null,
      auth1Name: json['auth1_name'],
      auth2Name: json['auth2_name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_serial'] = this.trnsSerial;
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_date'] = this.trnsDate;
    data['store_code'] = this.storeCode;
    data['store_name'] = this.storeName;
    data['cost_code2'] = this.costCode2;
    data['doc_no'] = this.docNo;
    data['cost_code2_name'] = this.costCode2Name;
    data['desc_a'] = this.descA;
    data['desc_e'] = this.descE;
    data['insert_user'] = this.insertUser;
    data['update_user'] = this.updateUser;
    data['insert_date'] = this.insertDate;
    data['auth1_name'] = this.auth1Name;
    data['auth2_name'] = this.auth2Name;
    return data;
  }

  String get formattedTrnsDate {
    return formatDate(trnsDate);
  }

  String get formattedInsertDate {
    return formatDate(insertDate);
  }
}
