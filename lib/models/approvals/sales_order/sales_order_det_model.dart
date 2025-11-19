class SalesOrderDetails {
  int? trnsTypeCode;
  int? trnsSerial;
  int? itemGroupCode;
  String? groupName;
  String? itemCode;
  String? itemName;
  String? unitName;
  int? qty;
  num? price;
  num? totPrice;
  String? note;

  SalesOrderDetails(
      {this.trnsTypeCode,
        this.trnsSerial,
        this.itemGroupCode,
        this.groupName,
        this.itemCode,
        this.itemName,
        this.unitName,
        this.qty,
        this.price,
        this.totPrice,
        this.note});

  SalesOrderDetails.fromJson(Map<String, dynamic> json) {
    trnsTypeCode = json['trns_type_code'];
    trnsSerial = json['trns_serial'];
    itemGroupCode = json['item_group_code'];
    groupName = json['group_name'];
    itemCode = json['item_code'];
    itemName = json['item_name'];
    unitName = json['unit_name'];
    qty = json['qty'];
    price = json['price'];
    totPrice = json['tot_price'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_type_code'] = this.trnsTypeCode;
    data['trns_serial'] = this.trnsSerial;
    data['item_group_code'] = this.itemGroupCode;
    data['group_name'] = this.groupName;
    data['item_code'] = this.itemCode;
    data['item_name'] = this.itemName;
    data['unit_name'] = this.unitName;
    data['qty'] = this.qty;
    data['price'] = this.price;
    data['tot_price'] = this.totPrice;
    data['note'] = this.note;
    return data;
  }
}