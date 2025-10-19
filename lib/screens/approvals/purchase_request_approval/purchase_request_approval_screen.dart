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
    const Color(0xFFB39EB5), // بنفسجي فاتح
    const Color(0xFFFFDAB9), // خوخي
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
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
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // الأيقونة على اليسار
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: cardColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // المحتوى في المنتصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Store Name
                      Row(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 13,
                            color: cardColor,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              request.store_name ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        isArabic ? (request.descA ?? '') : (request.descE ?? ''),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // التاريخ
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            request.formattedReqDate,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // السهم على اليمين
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isArabic
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}