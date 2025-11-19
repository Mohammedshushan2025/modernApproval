import '../../../utils/package_utility.dart';

class PurchaseOrderDetail {
  final int trnsTypeCode;
   final int trnsSerial;
   final int storeCode;
   final String? storeName;
  DateTime? reqDate;
   final int? itemSerial;
  String? groupName;
  String? itemCode;
  int? groupCode;
  String? itemNameA;
  String? itemNameE;
  String? unitName;
  int? quantity;
  int? approveFlag;
  num? vnPriceCurr;//the value is double but num cover both
  num? vnPrice;
  int? total;
  int? reqTrnsTypeCode;
  int? reqTrnsSerial;
  String? servicesDesc;
  String? notes;
  PurchaseOrderDetail(
      {required this.trnsTypeCode,
        required this.trnsSerial,
        required this.storeCode,
        required this.storeName,
         this.reqDate,
        required this.itemSerial,
        this.groupName,
        this.itemCode,
        this.groupCode,
        this.itemNameA,
        this.itemNameE,
        this.unitName,
        this.quantity,
        this.approveFlag,
        this.vnPriceCurr,
        this.vnPrice,
        this.total,
        this.reqTrnsTypeCode,
        this.reqTrnsSerial,
        this.servicesDesc,
        this.notes,
      });

  factory PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderDetail(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      storeCode: json['store_code'],
      storeName: json['store_name'],
      itemSerial: json['item_serial'],
      reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
      groupName: json['group_name'],
      itemCode: json['item_code'],
      groupCode: json['group_code'],
      itemNameA: json['item_name_a'],
      itemNameE: json['item_name_e'],
      unitName: json['unit_name'],
      quantity: json['quantity'],
      approveFlag: json['approve_flag'] ?? 0,
      vnPriceCurr: json['vn_price_curr'],
      vnPrice: json['vn_price'],
      total: json['total'],
      reqTrnsTypeCode: json['req_trns_type_code'],
      reqTrnsSerial: json['req_trns_serial'],
      servicesDesc: json['services_desc'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trns_type_code'] = trnsTypeCode;
    data['trns_serial'] = trnsSerial;
    data['store_code'] = storeCode;
    data['store_name'] = storeName;
    data['req_date'] = reqDate;
    data['item_serial'] = itemSerial;
    data['group_name'] = groupName;
    data['item_code'] = itemCode;
    data['group_code'] = groupCode;
    data['item_name_a'] = itemNameA;
    data['item_name_e'] = itemNameE;
    data['unit_name'] = unitName;
    data['quantity'] = quantity;
    data['approve_flag'] = approveFlag;
    data['vn_price_curr'] = vnPriceCurr;
    data['vn_price'] = vnPrice;
    data['total'] = total;
    data['req_trns_type_code'] = reqTrnsTypeCode;
    data['req_trns_serial'] = reqTrnsSerial;
    data['services_desc'] = servicesDesc;
    data['notes'] = notes;
    return data;
  }

  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
