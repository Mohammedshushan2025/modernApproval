import '../utils/package_utility.dart';

class PurchaseRequest {
  final int trnsTypeCode;
  final int trnsSerial;
  final int? storeCode;
  final String? descA;
  final String? descE;
  final DateTime? reqDate;
  final String authPk1;
  final String authPk2;
  // --- ✅ الإضافات الجديدة اللي كنا محتاجينها ---
  final int? prevSer;
  final int? lastLevel;
  final String? store_name;
  // ------------------------------------

  PurchaseRequest({
    required this.trnsTypeCode,
    required this.trnsSerial,
    this.storeCode,
    this.descA,
    this.descE,
    this.reqDate,
    required this.authPk1,
    required this.authPk2,
    // --- ✅ الإضافات الجديدة ---
    this.prevSer,
    this.lastLevel,
    this.store_name
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      descA: json['desc_a'],
      descE: json['desc_e'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      authPk1: json['auth_pk1'],
      authPk2: json['auth_pk2'],
      // --- ✅ الإضافات الجديدة ---
      prevSer: json['prev_ser'],
      lastLevel: json['last_level'],
      store_name: json['store_name'],
      // ------------------------------------
    );
  }

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}