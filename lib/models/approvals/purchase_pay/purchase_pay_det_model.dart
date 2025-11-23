class PurchasePayDetail {
  final int trnsTypeCode;
  final int trnsSerial;
  int? itemSerial;
  int? itemGroupCode;
  String? groupName;
  String? itemCode;
  String? itemNameA;
  String? itemNameE;
  String? unitName;
  num? quantity;
  num? bonus;
  num? vnPrice;
  num? vnPriceCurr;
  num? taxSal;
  num? currencyRate;
  num? taxProft;
  num? othersVal;
  num? discVal;
  num? detDisc;
  String? notes;

  PurchasePayDetail(
      {required this.trnsTypeCode,
        required this.trnsSerial,
        this.itemSerial,
        this.itemGroupCode,
        this.groupName,
        this.itemCode,
        this.itemNameA,
        this.itemNameE,
        this.unitName,
        this.quantity,
        this.bonus,
        this.vnPrice,
        this.vnPriceCurr,
        this.taxSal,
        this.currencyRate,
        this.taxProft,
        this.othersVal,
        this.discVal,
        this.detDisc,
        this.notes});

  factory PurchasePayDetail.fromJson(Map<String, dynamic> json) {
    return PurchasePayDetail(
      trnsTypeCode: json['trns_type_code'],
      trnsSerial: json['trns_serial'],
      itemSerial: json['item_serial'],
      itemGroupCode: json['item_group_code'],
      groupName: json['group_name'],
      itemCode: json['item_code'],
      itemNameA: json['item_name_a'],
      itemNameE: json['item_name_e'],
      unitName: json['unit_name'],
      quantity: json['quantity'],
      bonus: json['bonus'],
      vnPrice: json['vn_price'],
      vnPriceCurr: json['vn_price_curr'],
      taxSal: json['tax_sal'],
      currencyRate: json['currency_rate'],
      taxProft: json['tax_proft'],
      othersVal: json['others_val'],
      discVal: json['disc_val'],
      detDisc: json['det_disc'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_serial'] = this.trnsSerial;
    data['item_serial'] = this.itemSerial;
    data['item_group_code'] = this.itemGroupCode;
    data['group_name'] = this.groupName;
    data['item_code'] = this.itemCode;
    data['item_name_a'] = this.itemNameA;
    data['item_name_e'] = this.itemNameE;
    data['unit_name'] = this.unitName;
    data['quantity'] = this.quantity;
    data['bonus'] = this.bonus;
    data['vn_price'] = this.vnPrice;
    data['vn_price_curr'] = this.vnPriceCurr;
    data['tax_sal'] = this.taxSal;
    data['currency_rate'] = this.currencyRate;
    data['tax_proft'] = this.taxProft;
    data['others_val'] = this.othersVal;
    data['disc_val'] = this.discVal;
    data['det_disc'] = this.detDisc;
    data['notes'] = this.notes;
    return data;
  }
}
