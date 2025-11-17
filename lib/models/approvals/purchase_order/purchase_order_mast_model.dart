import '../../../utils/package_utility.dart';

class PurchaseOrderMaster {
  late final int trnsTypeCode;
  late final int trnsSerial;
  late final int storeCode;
  late final String storeName;
  DateTime? reqDate;
  late final   String descA;
  String? descE;
  late final int approveFlag;

  PurchaseOrderMaster(
      {required this.trnsTypeCode,
        required this.trnsSerial,
        required this.storeCode,
        required this.storeName,
         this.reqDate,
        required this.descA,
        this.descE,
        required this.approveFlag});

  PurchaseOrderMaster.fromJson(Map<String, dynamic> json) {
    trnsTypeCode = json['trns_type_code'];
    trnsSerial = json['trns_serial'];
    storeCode = json['store_code'];
    storeName = json['store_name'];
    reqDate = json['req_date']!= null ? DateTime.parse(json['req_date']) : null;
    descA = json['desc_a'];
    descE = json['desc_e'];
    approveFlag = json['approve_flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_serial'] = this.trnsSerial;
    data['store_code'] = this.storeCode;
    data['store_name'] = this.storeName;
    data['req_date'] = this.reqDate;
    data['desc_a'] = this.descA;
    data['desc_e'] = this.descE;
    data['approve_flag'] = this.approveFlag;
    return data;
  }
  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
