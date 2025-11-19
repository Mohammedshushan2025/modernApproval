import 'package:flutter/material.dart';
import 'package:modernapproval/models/approvals/sales_order/sales_order_model.dart';

import '../../../models/user_model.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final UserModel user;
  final SalesOrder request;

  const SalesOrderDetailScreen({super.key,
    required this.user,
    required this.request,});

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
