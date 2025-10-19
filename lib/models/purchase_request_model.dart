// سننشئ هذا الملف لتنسيق التاريخ

import '../utils/package_utility.dart';

class PurchaseRequest {
  final int trnsTypeCode;
  final int trnsSerial;
  final int? storeCode;
  final String? docNo;
  final DateTime? reqDate;
  final String? descA;
  final String? descE;
  final int? insertUser;
  final String? authPk1;
  final String? authPk2;
  final String store_name;

  // يمكنك إضافة باقي الحقول هنا بنفس الطريقة إذا احتجتها مستقبلاً

  PurchaseRequest({
    required this.trnsTypeCode,
    required this.trnsSerial,
    required this.store_name,
    this.storeCode,
    this.docNo,
    this.reqDate,
    this.descA,
    this.descE,
    this.insertUser,
    this.authPk1,
    this.authPk2,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      docNo: json['doc_no'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      descA: json['desc_a'],
      descE: json['desc_e'],
      insertUser: json['insert_user'],
      authPk1: json['auth_pk1'],
      authPk2: json['auth_pk2'],
      store_name: json['store_name'],
    );
  }

  // دالة مساعدة لتنسيق التاريخ
  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
