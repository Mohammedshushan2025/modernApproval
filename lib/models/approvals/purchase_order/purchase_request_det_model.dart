import '../../../utils/package_utility.dart';

class PurchaseOrderDetail {
  late final int trnsTypeCode;
  late final int trnsSerial;
  late final int storeCode;
  late final String storeName;
  DateTime? reqDate;
  late final int itemSerial;
  String? groupName;
  String? itemCode;
  int? groupCode;
  String? itemNameA;
  String? itemNameE;
  String? unitName;
  int? quantity;
  late final int approveFlag;
  int? vnPriceCurr;
  int? vnPrice;

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
        required this.approveFlag,
        this.vnPriceCurr,
        this.vnPrice});

  PurchaseOrderDetail.fromJson(Map<String, dynamic> json) {
    trnsTypeCode = json['trns_type_code'];
    trnsSerial = json['trns_serial'];
    storeCode = json['store_code'];
    storeName = json['store_name'];
    reqDate = json['req_date'] != null ? DateTime.parse(json['req_date']) : null;
    itemSerial = json['item_serial'];
    groupName = json['group_name'];
    itemCode = json['item_code'];
    groupCode = json['group_code'];
    itemNameA = json['item_name_a'];
    itemNameE = json['item_name_e'];
    unitName = json['unit_name'];
    quantity = json['quantity'];
    approveFlag = json['approve_flag'];
    vnPriceCurr = json['vn_price_curr'];
    vnPrice = json['vn_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_serial'] = this.trnsSerial;
    data['store_code'] = this.storeCode;
    data['store_name'] = this.storeName;
    data['req_date'] = this.reqDate;
    data['item_serial'] = this.itemSerial;
    data['group_name'] = this.groupName;
    data['item_code'] = this.itemCode;
    data['group_code'] = this.groupCode;
    data['item_name_a'] = this.itemNameA;
    data['item_name_e'] = this.itemNameE;
    data['unit_name'] = this.unitName;
    data['quantity'] = this.quantity;
    data['approve_flag'] = this.approveFlag;
    data['vn_price_curr'] = this.vnPriceCurr;
    data['vn_price'] = this.vnPrice;
    return data;
  }
  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
