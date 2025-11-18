import '../../../utils/package_utility.dart';

class PurchaseOrderMaster {
   final int trnsTypeCode;
   final int trnsSerial;
   final int storeCode;
   final String storeName;
  DateTime? reqDate;
   final   String descA;
  String? descE;
  final int? approveFlag;
   int? currencyCode;
   String? currencyDesc;
   int? supplierCode;
   String? supplierName;
   String? respName;
   num? taxSal;
   num? taxProft;
   int? discVal;
   int? totExp;
   int? closed;
  PurchaseOrderMaster(
      {required this.trnsTypeCode,
        required this.trnsSerial,
        required this.storeCode,
        required this.storeName,
         this.reqDate,
        required this.descA,
        this.descE,
        required this.approveFlag,
        this.currencyCode,
        this.currencyDesc,
        this.supplierCode,
        this.supplierName,
        this.respName,
        this.taxSal,
        this.taxProft,
        this.discVal,
        this.totExp,
        this.closed,
      
      
      });

   factory PurchaseOrderMaster.fromJson(Map<String, dynamic> json) {
     return PurchaseOrderMaster(
       trnsTypeCode: json['trns_type_code'],
       trnsSerial: json['trns_serial'],
       storeCode: json['store_code'],
       storeName: json['store_name'],
       reqDate: json['req_date'] != null ? DateTime.parse(json['req_date']) : null,
       descA: json['desc_a'],
       descE: json['desc_e'],
       approveFlag: json['approve_flag'] ?? 0,
       currencyCode: json['currency_code'],
       currencyDesc: json['currency_desc'],
       supplierCode: json['supplier_code'],
       supplierName: json['supplier_name'],
       respName: json['resp_name'],
       taxSal: json['tax_sal'],
       taxProft: json['tax_proft'],
       discVal: json['disc_val'],
       totExp: json['tot_exp'],
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
    data['currency_code'] = this.currencyCode;
    data['currency_desc'] = this.currencyDesc;
    data['supplier_code'] = this.supplierCode;
    data['supplier_name'] = this.supplierName;
    data['resp_name'] = this.respName;
    data['tax_sal'] = this.taxSal;
    data['tax_proft'] = this.taxProft;
    data['disc_val'] = this.discVal;
    data['tot_exp'] = this.totExp;
    data['closed'] = this.closed;
    return data;
  }
  String get formattedReqDate {
    return formatDate(reqDate);
  }
}
