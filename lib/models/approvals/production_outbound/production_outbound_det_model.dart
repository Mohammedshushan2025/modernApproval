class ProductionOutboundDetail {
  int? trnsSerial;
  int? trnsTypeCode;
  String? itemCode;
  String? itemName;
  String? unitName;
  num? quantity;
  num? unitCost;
  int? itemConfgId;
  String? projectId;
  String? mastBandCode;
  String? bandCode;
  num? consumableItemCode;
  num? total;

  ProductionOutboundDetail(
      {this.trnsSerial,
        this.trnsTypeCode,
        this.itemCode,
        this.itemName,
        this.unitName,
        this.quantity,
        this.unitCost,
        this.itemConfgId,
        this.projectId,
        this.mastBandCode,
        this.bandCode,
        this.consumableItemCode,
        this.total});

  factory ProductionOutboundDetail.fromJson(Map<String, dynamic> json) {
    return ProductionOutboundDetail(
      trnsSerial: json['trns_serial'],
      trnsTypeCode: json['trns_type_code'],
      itemCode: json['item_code'],
      itemName: json['item_name'],
      unitName: json['unit_name'],
      quantity: json['quantity'],
      unitCost: json['unit_cost'],
      itemConfgId: json['item_confg_id'],
      projectId: json['project_id'],
      mastBandCode: json['mast_band_code'],
      bandCode: json['band_code'],
      consumableItemCode: json['consumable_item_code'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['trns_serial'] = this.trnsSerial;
    data['trns_type_code'] = this.trnsTypeCode;
    data['item_code'] = this.itemCode;
    data['item_name'] = this.itemName;
    data['unit_name'] = this.unitName;
    data['quantity'] = this.quantity;
    data['unit_cost'] = this.unitCost;
    data['item_confg_id'] = this.itemConfgId;
    data['project_id'] = this.projectId;
    data['mast_band_code'] = this.mastBandCode;
    data['band_code'] = this.bandCode;
    data['consumable_item_code'] = this.consumableItemCode;
    data['total'] = this.total;
    return data;
  }
}
