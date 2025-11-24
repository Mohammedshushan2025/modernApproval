import '../../../utils/package_utility.dart';

class SalesOrderMaster {
  String? salesOrderNo;
  DateTime? orderDate;
  int? customerCode;
  String? customerNameA;
  String? customerNameE;
  int? storeCode;
  String? storeNameA;
  String? storeNameE;
  String? managerSales;
  String? repSales;
  String? offerExpiry;
  num? taxSal;

  SalesOrderMaster({
    this.salesOrderNo,
    this.orderDate,
    this.customerCode,
    this.customerNameA,
    this.customerNameE,
    this.storeCode,
    this.storeNameA,
    this.storeNameE,
    this.managerSales,
    this.repSales,
    this.offerExpiry,
    this.taxSal,
  });

  SalesOrderMaster.fromJson(Map<String, dynamic> json) {
    salesOrderNo = json['sales_order_no'];
    orderDate =
        json['order_date'] != null ? DateTime.parse(json['order_date']) : null;
    customerCode = json['customer_code'];
    customerNameA = json['customer_name_a'];
    customerNameE = json['customer_name_e'];
    storeCode = json['store_code'];
    storeNameA = json['store_name_a'];
    storeNameE = json['store_name_e'];
    managerSales = json['manager_sales'];
    repSales = json['rep_sales'];
    offerExpiry = json['offer_expiry'];
    taxSal = json['tax_sal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sales_order_no'] = this.salesOrderNo;
    data['order_date'] = this.orderDate;
    data['customer_code'] = this.customerCode;
    data['customer_name_a'] = this.customerNameA;
    data['customer_name_e'] = this.customerNameE;
    data['store_code'] = this.storeCode;
    data['store_name_a'] = this.storeNameA;
    data['store_name_e'] = this.storeNameE;
    data['manager_sales'] = this.managerSales;
    data['rep_sales'] = this.repSales;
    data['offer_expiry'] = this.offerExpiry;
    data['tax_sal'] = this.taxSal;
    return data;
  }

  String get formattedOrderDate {
    return formatDate(orderDate);
  }
}
