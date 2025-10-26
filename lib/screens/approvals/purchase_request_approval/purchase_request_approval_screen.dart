/*
import 'package:flutter/material.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_detail_screen.dart';
import '../../../app_localizations.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/error_display.dart';

class PurchaseRequestApprovalScreen extends StatefulWidget {
  final UserModel user;
  final int selectedPasswordNumber;

  const PurchaseRequestApprovalScreen({
    super.key,
    required this.user,
    required this.selectedPasswordNumber,
  });

  @override
  State<PurchaseRequestApprovalScreen> createState() =>
      _PurchaseRequestApprovalScreenState();
}

class _PurchaseRequestApprovalScreenState
    extends State<PurchaseRequestApprovalScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PurchaseRequest>> _requestsFuture;

  // ألوان واضحة وقوية
  final List<Color> _cardColors = [
    const Color(0xFF5B9BD5), // أزرق
    const Color(0xFF70AD47), // أخضر
    const Color(0xFFF4A460), // برتقالي
    const Color(0xFF8E8EBD), // بنفسجي
    const Color(0xFFE67E7E), // أحمر فاتح
    const Color(0xFF9B9B9B), // رمادي
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _requestsFuture = _apiService.getPurchaseRequests(
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: widget.selectedPasswordNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l.translate('purchaseRequestApproval')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<PurchaseRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF7CB9E8),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.translate('loading') ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7CB9E8).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: const Color(0xFF7CB9E8).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.translate('noData'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.translate('noRequestsAvailable') ?? 'No requests available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildPurchaseRequestCard(context, requests[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseRequestCard(BuildContext context, PurchaseRequest request, int index) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final cardColor = _cardColors[index % _cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PurchaseRequestDetailScreen(
                  user: widget.user,
                  request: request,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // الأيقونة على اليسار/اليمين حسب اللغة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: cardColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // المحتوى في المنتصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name مع الأيقونة
                      Row(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 15,
                            color: cardColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request.store_name ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        isArabic ? (request.descA ?? '') : (request.descE ?? ''),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // التاريخ مع الأيقونة
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            request.formattedReqDate,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // السهم على اليمين/اليسار حسب اللغة
                Icon(
                  isArabic
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

 */


/*
import 'package:flutter/material.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_detail_screen.dart';
import '../../../app_localizations.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/error_display.dart';

class PurchaseRequestApprovalScreen extends StatefulWidget {
  final UserModel user;
  final int selectedPasswordNumber;

  const PurchaseRequestApprovalScreen({
    super.key,
    required this.user,
    required this.selectedPasswordNumber,
  });

  @override
  State<PurchaseRequestApprovalScreen> createState() =>
      _PurchaseRequestApprovalScreenState();
}

class _PurchaseRequestApprovalScreenState
    extends State<PurchaseRequestApprovalScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PurchaseRequest>> _requestsFuture;

  // ألوان هادية ومتنوعة
  final List<Color> _cardColors = [
    const Color(0xFF7CB9E8), // أزرق فاتح
    const Color(0xFF88D8B0), // أخضر نعناعي
    const Color(0xFFFFC09F), // برتقالي هادي
    const Color(0xFFAEC6CF), // رمادي مزرق
    const Color(0xFFFFDAB9), // خوخي
    const Color(0xFFE6E6FA), // بنفسجي فاتح
    const Color(0xFFC8A2C8), // ليلاك
    const Color(0xFFB2C248), // أخضر زيتوني
    const Color(0xFFC3B1E1), // بنفسجي شاحب
    const Color(0xFFF4C2C2), // وردي
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _requestsFuture = _apiService.getPurchaseRequests(
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: widget.selectedPasswordNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l.translate('purchaseRequestApproval')),
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<List<PurchaseRequest>>(
        future: _requestsFuture,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    l.translate('noData'),
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            // تغيير الـ padding ليناسب التصميم
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];
              // اختيار اللون بناءً على الـ index
              final color = _cardColors[index % _cardColors.length];
              return _buildPurchaseRequestCard(context, item, color);
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseRequestCard(
      BuildContext context, PurchaseRequest request, Color color) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // استخدام التصميم الخاص بك
    return Card(
      elevation: 2.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          // --- ✅ --- تعديل دالة onTap --- ✅ ---
          onTap: () async {
            // الانتقال إلى شاشة التفاصيل وانتظار النتيجة
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PurchaseRequestDetailScreen(
                  user: widget.user,
                  request: request, // تمرير الطلب كاملاً
                ),
              ),
            );

            // إذا كانت النتيجة true (تم الاعتماد/الرفض بنجاح)
            if (result == true) {
              print("✅ Navigated back with success, refreshing list...");
              _fetchData(); // أعد تحميل البيانات لتحديث القائمة
            }
          },
          // --- ✅ --- نهاية تعديل onTap --- ✅ ---
          borderRadius: BorderRadius.circular(12),
          child: Container(
            // تعديل الـ padding ليناسب التصميم
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // الدائرة الملونة على اليمين/اليسار
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shopping_cart_checkout_outlined,
                    color: color.withOpacity(1),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 15),
                // النصوص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الوصف
                      Text(
                        isArabic ? (request.descA ?? '') : (request.descE ?? ''),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // التاريخ مع الأيقونة
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            request.formattedReqDate,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // السهم على اليمين/اليسار حسب اللغة
                Icon(
                  isArabic
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

*/

import 'package:flutter/material.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_detail_screen.dart';
import '../../../app_localizations.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/error_display.dart';

class PurchaseRequestApprovalScreen extends StatefulWidget {
  final UserModel user;
  final int selectedPasswordNumber;

  const PurchaseRequestApprovalScreen({
    super.key,
    required this.user,
    required this.selectedPasswordNumber,
  });

  @override
  State<PurchaseRequestApprovalScreen> createState() =>
      _PurchaseRequestApprovalScreenState();
}

class _PurchaseRequestApprovalScreenState
    extends State<PurchaseRequestApprovalScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PurchaseRequest>> _requestsFuture;

  // ألوان واضحة وقوية
  final List<Color> _cardColors = [
    const Color(0xFF5B9BD5), // أزرق
    const Color(0xFF70AD47), // أخضر
    const Color(0xFFF4A460), // برتقالي
    const Color(0xFF8E8EBD), // بنفسجي
    const Color(0xFFE67E7E), // أحمر فاتح
    const Color(0xFF9B9B9B), // رمادي
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _requestsFuture = _apiService.getPurchaseRequests(
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: widget.selectedPasswordNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(title: l.translate('purchaseRequestApproval')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<List<PurchaseRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF7CB9E8),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.translate('loading') ?? 'Loading...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7CB9E8).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: const Color(0xFF7CB9E8).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.translate('noData'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.translate('noRequestsAvailable') ?? 'No requests available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildPurchaseRequestCard(context, requests[index], index);
            },
          );
        },
      ),
    );
  }

  Widget _buildPurchaseRequestCard(BuildContext context, PurchaseRequest request, int index) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final cardColor = _cardColors[index % _cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // --- ✅ --- التعديل هنا في onTap --- ✅ ---
          onTap: () async { // <-- إضافة async
            // الانتقال إلى شاشة التفاصيل وانتظار النتيجة
            final result = await Navigator.push( // <-- إضافة await
              context,
              MaterialPageRoute(
                builder: (context) => PurchaseRequestDetailScreen(
                  user: widget.user,
                  request: request,
                ),
              ),
            );

            // إذا كانت النتيجة true (تم الاعتماد/الرفض بنجاح)
            if (result == true) { // <-- التحقق من النتيجة
              print("✅ Navigated back from Details, refreshing list...");
              _fetchData(); // <-- إعادة تحميل البيانات
            }
          },
          // --- ✅ --- نهاية التعديل --- ✅ ---
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // الأيقونة على اليسار/اليمين حسب اللغة
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: cardColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // المحتوى في المنتصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name مع الأيقونة
                      Row(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 15,
                            color: cardColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request.store_name ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        isArabic ? (request.descA ?? '') : (request.descE ?? ''),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // التاريخ مع الأيقونة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                request.formattedReqDate,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                request.authPk1+" / "+request.authPk2,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // السهم على اليمين/اليسار حسب اللغة
                Icon(
                  isArabic
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

