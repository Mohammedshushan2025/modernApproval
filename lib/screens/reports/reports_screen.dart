import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../models/form_report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/action_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_display.dart';

class ReportsScreen extends StatefulWidget {
  final UserModel user;
  const ReportsScreen({super.key, required this.user});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<FormReportItem>> _reportsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _reportsFuture = _fetchAndProcessReports();
    });
  }

  Future<List<FormReportItem>> _fetchAndProcessReports() async {
    final items = await _apiService.getFormsAndReports(widget.user.usersCode);
    final reports = (items as List)
        .whereType<FormReportItem>()
        .where((item) => item.type == 'R')
        .toList();
    reports.sort((a, b) => a.ord.compareTo(b.ord));
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(title: l.translate('reports')),
      body: FutureBuilder<List<FormReportItem>>(
        future: _reportsFuture,
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

          final reports = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final item = reports[index];
              final iconData = _getIconForReport(item.pageId);
              final colors = _getColorsForReport(item.pageId);

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

  // تحديد الأيقونة المناسبة لكل تقرير
  IconData _getIconForReport(int pageId) {
    switch (pageId) {
      case 201: // تقرير اوامر البيع
        return Icons.point_of_sale;
      case 202: // تقرير اوامر الشراء
        return Icons.shopping_cart_outlined;
      case 203: // تقرير ميزان العملاء
        return Icons.people_outline;
      default:
        return Icons.analytics_outlined;
    }
  }

  // تحديد الألوان المناسبة لكل تقرير (ألوان هادئة وراقية)
  Map<String, Color> _getColorsForReport(int pageId) {
    switch (pageId) {
      case 201: // تقرير اوامر البيع - وردي فاتح
        return {
          'background': const Color(0xFFFCE4EC),
          'icon': const Color(0xFFC2185B),
        };
      case 202: // تقرير اوامر الشراء - أزرق فاتح
        return {
          'background': const Color(0xFFE3F2FD),
          'icon': const Color(0xFF1976D2),
        };
      case 203: // تقرير ميزان العملاء - أخضر نعناعي
        return {
          'background': const Color(0xFFE0F2F1),
          'icon': const Color(0xFF00897B),
        };
      default: // افتراضي - رمادي
        return {
          'background': const Color(0xFFF5F5F5),
          'icon': const Color(0xFF757575),
        };
    }
  }
}