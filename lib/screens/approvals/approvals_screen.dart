import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../models/form_report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/action_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_display.dart';

class ApprovalsScreen extends StatefulWidget {
  final UserModel user;
  const ApprovalsScreen({super.key, required this.user});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late Future<List<FormReportItem>> _approvalsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _approvalsFuture = _fetchAndProcessApprovals();
    });
  }

  Future<List<FormReportItem>> _fetchAndProcessApprovals() async {
    final items = await _apiService.getFormsAndReports(widget.user.usersCode);
    final approvals = (items as List)
        .whereType<FormReportItem>()
        .where((item) => item.type == 'F')
        .toList();
    approvals.sort((a, b) => a.ord.compareTo(b.ord));
    return approvals;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(title: l.translate('approvals')),
      body: FutureBuilder<List<FormReportItem>>(
        future: _approvalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              errorMessageKey: snapshot.error.toString().contains('noInternet')
                  ? 'noInternet'
                  : 'serverError',
              onRetry: _fetchData,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                l.translate('noData'),
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
            );
          }

          final approvals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final item = approvals[index];
              final iconData = _getIconForItem(item.pageId);
              final colors = _getColorsForItem(item.pageId);

              return ActionCard(
                title: isArabic ? item.pageName : item.pageNameE,
                icon: iconData,
                backgroundColor: colors['background']!,
                iconColor: colors['icon']!,
                onTap: () {
                  print("Tapped on ${item.pageId}: ${item.pageNameE}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigating to ${item.pageNameE}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // تحديد الأيقونة المناسبة لكل page_id
  IconData _getIconForItem(int pageId) {
    switch (pageId) {
      case 101: // اعتماد طلب شراء
        return Icons.shopping_cart_outlined;
      case 102: // اعتماد أمر التوريد
        return Icons.local_shipping_outlined;
      case 103: // اعتماد رسائل واردة تكاليف
        return Icons.attach_money;
      case 104: // اعتماد صرف المخازن
        return Icons.inventory_2_outlined;
      case 105: // اعتماد صادر إنتاج
        return Icons.output_outlined;
      case 106: // اعتماد وارد إنتاج
        return Icons.input_outlined;
      case 107: // اعتماد طلب الصرف اليومية العامة
        return Icons.receipt_long_outlined;
      case 108: // اعتماد أمر البيع
        return Icons.point_of_sale;
      case 109: // اعتماد ملف الإجازات والانقطاعات
        return Icons.event_busy_outlined;
      case 110: // اعتماد ملف الأذونات والمأموريات
        return Icons.badge_outlined;
      case 111: // اعتماد طلب الصرف النقدية
        return Icons.payments_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  // تحديد الألوان المناسبة لكل page_id (ألوان هادئة وراقية)
  Map<String, Color> _getColorsForItem(int pageId) {
    switch (pageId) {
      case 101: // طلب شراء - أزرق فاتح
        return {
          'background': const Color(0xFFE3F2FD),
          'icon': const Color(0xFF1976D2),
        };
      case 102: // أمر التوريد - أخضر فاتح
        return {
          'background': const Color(0xFFE8F5E9),
          'icon': const Color(0xFF388E3C),
        };
      case 103: // تكاليف - أخضر نعناعي
        return {
          'background': const Color(0xFFE0F2F1),
          'icon': const Color(0xFF00897B),
        };
      case 104: // صرف المخازن - بنفسجي فاتح
        return {
          'background': const Color(0xFFF3E5F5),
          'icon': const Color(0xFF7B1FA2),
        };
      case 105: // صادر إنتاج - برتقالي فاتح
        return {
          'background': const Color(0xFFFFF3E0),
          'icon': const Color(0xFFF57C00),
        };
      case 106: // وارد إنتاج - أزرق سماوي
        return {
          'background': const Color(0xFFE1F5FE),
          'icon': const Color(0xFF0288D1),
        };
      case 107: // اليومية العامة - رمادي أزرق
        return {
          'background': const Color(0xFFECEFF1),
          'icon': const Color(0xFF546E7A),
        };
      case 108: // أمر البيع - وردي فاتح
        return {
          'background': const Color(0xFFFCE4EC),
          'icon': const Color(0xFFC2185B),
        };
      case 109: // الإجازات - أصفر فاتح
        return {
          'background': const Color(0xFFFFF9C4),
          'icon': const Color(0xFFF9A825),
        };
      case 110: // الأذونات - بني فاتح
        return {
          'background': const Color(0xFFEFEBE9),
          'icon': const Color(0xFF6D4C41),
        };
      case 111: // النقدية - أخضر ليموني
        return {
          'background': const Color(0xFFF0F4C3),
          'icon': const Color(0xFF9E9D24),
        };
      default: // افتراضي - رمادي
        return {
          'background': const Color(0xFFF5F5F5),
          'icon': const Color(0xFF757575),
        };
    }
  }
}