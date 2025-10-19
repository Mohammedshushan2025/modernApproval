import '../utils/package_utility.dart';

class PurchaseRequestMaster {
  final int trnsTypeCode;
  final int trnsSerial;
  final int? storeCode;
  final String? storeName;
  final DateTime? reqDate;
  final String? descA;
  final String? descE;
  final String? approveFlag;

  PurchaseRequestMaster({
    required this.trnsTypeCode,
    required this.trnsSerial,
    this.storeCode,
    this.storeName,
    this.reqDate,
    this.descA,
    this.descE,
    this.approveFlag,
  });

  factory PurchaseRequestMaster.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestMaster(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      storeName: json['store_name'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      descA: json['desc_a'],
      descE: json['desc_e'],
      approveFlag: json['approve_flag'],
    );
  }

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}




