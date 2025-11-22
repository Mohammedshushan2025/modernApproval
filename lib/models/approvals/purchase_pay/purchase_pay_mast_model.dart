import '../../../utils/package_utility.dart';

class PurchasePayMaster {
  final int trnsTypeCode;
  final int trnsSerial;
  final int storeCode;
  final String storeName;
  DateTime? reqDate;
  String? descA;
  String? descE;
  final int? approveFlag;
  int? orderTrnsType;
  int? orderTrnsSerial;
  String? vnTrnsName;
  String? insertUser;
  String? supplierName;
  DateTime? insertDate;
  String? currencyDesc;
  DateTime? dueDate;
  num? valueCurr;
  num? value;
  num? currencyRate;
  String? payMethod;
  String? payFlag;
  int? closed;

  PurchasePayMaster(
      {required this.trnsTypeCode,
        required this.trnsSerial,
        required this.storeCode,
        required this.storeName,
        this.reqDate,
        this.descA,
        this.descE,
        this.approveFlag,
        this.orderTrnsType,
        this.orderTrnsSerial,
        this.vnTrnsName,
        this.insertUser,
        this.supplierName,
        this.insertDate,
        this.currencyDesc,
        this.dueDate,
        this.valueCurr,
        this.value,
        this.currencyRate,
        this.payMethod,
        this.payFlag,
        this.closed});

  factory PurchasePayMaster.fromJson(Map<String, dynamic> json) {
    return PurchasePayMaster(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      storeName: json['store_name'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      descA: json['desc_a'],
      descE: json['desc_e'],
      approveFlag: json['approve_flag'] ?? 0,
      orderTrnsType: json['order_trns_type'],
      orderTrnsSerial: json['order_trns_serial'],
      vnTrnsName: json['vn_trns_name'],
      insertUser: json['insert_user'],
      supplierName: json['supplier_name'],
      insertDate: json['insert_date'] != null ? DateTime.parse(json['insert_date']) : null,
      currencyDesc: json['currency_desc'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      valueCurr: json['value_curr'],
      value: json['value'],
      currencyRate: json['currency_rate'],
      payMethod: json['pay_method'],
      payFlag: json['pay_flag'] ?? 0,
      closed: json['closed'],
    );
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
    data['order_trns_type'] = this.orderTrnsType;
    data['order_trns_serial'] = this.orderTrnsSerial;
    data['vn_trns_name'] = this.vnTrnsName;
    data['insert_user'] = this.insertUser;
    data['supplier_name'] = this.supplierName;
    data['insert_date'] = this.insertDate;
    data['currency_desc'] = this.currencyDesc;
    data['due_date'] = this.dueDate;
    data['value_curr'] = this.valueCurr;
    data['value'] = this.value;
    data['currency_rate'] = this.currencyRate;
    data['pay_method'] = this.payMethod;
    data['pay_flag'] = this.payFlag;
    data['closed'] = this.closed;
    return data;
  }
  String get formattedReqDate {
    return formatDate(reqDate);
  }
  String get formattedInsertDate {
    return formatDate(insertDate);
  }
  String get formattedDueDate {
    return formatDate(dueDate);
  }
}
