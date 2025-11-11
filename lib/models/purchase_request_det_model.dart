import '../utils/package_utility.dart';

class PurchaseRequestDetail {
  final int trnsTypeCode;
  final int trnsSerial;
  final int? storeCode;
  final String? storeName;
  final DateTime? reqDate;
  final int itemSerial;
  final String? groupName;
  final String? itemCode;
  final String? itemNameA;
  final String? itemNameE;
  final String? unitName;
  final num? quantity; // Using num to be safe (int or double)
  final String? note;
  final String? approveFlag;
  final num? last_pur;

  PurchaseRequestDetail({
    required this.trnsTypeCode,
    required this.trnsSerial,
    this.storeCode,
    this.storeName,
    this.reqDate,
    required this.itemSerial,
    this.groupName,
    this.itemCode,
    this.itemNameA,
    this.itemNameE,
    this.unitName,
    this.quantity,
    this.note,
    this.approveFlag,
    this.last_pur
  });

  factory PurchaseRequestDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseRequestDetail(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      storeName: json['store_name'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      itemSerial: json['item_serial'],
      groupName: json['group_name'],
      itemCode: json['item_code'],
      itemNameA: json['item_name_a'],
      itemNameE: json['item_name_e'],
      unitName: json['unit_name'],
      quantity: json['quantity'],
      note: json['note'],
      approveFlag: json['approve_flag'],
      last_pur: json['last_pur']
    );
  }

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}