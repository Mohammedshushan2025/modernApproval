class DetailsItem {
  int? trnsSerial;
  int? trnsTypeCode;
  String? itemCode;
  String? itemName;
  String? unitName;
  int? quantity;
  double? unitCost;
  int? itemConfgId;
  String? projectId;
  String? mastBandCode;
  String? bandCode;
  String? consumableItemCode;
  double? total;

  DetailsItem({
    this.trnsSerial,
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
    this.total,
  });

  factory DetailsItem.fromJson(Map<String, dynamic> json) => DetailsItem(
    trnsSerial: json['trns_serial'] as int?,
    trnsTypeCode: json['trns_type_code'] as int?,
    itemCode: json['item_code'] as String?,
    itemName: json['item_name'] as String?,
    unitName: json['unit_name'] as String?,
    quantity: json['quantity'] as int?,
    unitCost: (json['unit_cost'] as num?)?.toDouble(),
    itemConfgId: json['item_confg_id'] as int?,
    projectId: json['project_id'] as String?,
    mastBandCode: json['mast_band_code'] as String?,
    bandCode: json['band_code'] as String?,
    consumableItemCode: json['consumable_item_code'] as String?,
    total: (json['total'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'trns_serial': trnsSerial,
    'trns_type_code': trnsTypeCode,
    'item_code': itemCode,
    'item_name': itemName,
    'unit_name': unitName,
    'quantity': quantity,
    'unit_cost': unitCost,
    'item_confg_id': itemConfgId,
    'project_id': projectId,
    'mast_band_code': mastBandCode,
    'band_code': bandCode,
    'consumable_item_code': consumableItemCode,
    'total': total,
  };
}
