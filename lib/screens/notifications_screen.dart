
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/purchase_request_model.dart';
import '../services/api_service.dart';
import '../screens/approvals/purchase_request_approval/purchase_request_detail_screen.dart';
import '../widgets/error_display.dart';

class NotificationsScreen extends StatefulWidget {
  final UserModel user;
  final int selectedPasswordNumber;

  const NotificationsScreen({
    super.key,
    required this.user,
    required this.selectedPasswordNumber,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<PurchaseRequest>> _requestsFuture;
  static final Set<String> _readNotifications = {};

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


  static Future<int> getUnreadCount({
    required ApiService apiService,
    required int userId,
    required int roleId,
    required int passwordNumber,
  }) async {
    try {
      final requests = await apiService.getPurchaseRequests(
        userId: userId,
        roleId: roleId,
        passwordNumber: passwordNumber,
      );
      return requests
          .where((r) => !_readNotifications
          .contains('${r.trnsTypeCode}_${r.trnsSerial}'))
          .length;
    } catch (e) {
      return 0;
    }
  }

  int _getUnreadCount(List<PurchaseRequest> requests) {
    return requests
        .where((r) => !_readNotifications.contains(_getRequestId(r)))
        .length;
  }

  String _getRequestId(PurchaseRequest request) {
    return '${request.trnsTypeCode}_${request.trnsSerial}';
  }

  void _markAsRead(PurchaseRequest request) {
    setState(() {
      _readNotifications.add(_getRequestId(request));
    });
  }

  void _markAllAsRead(List<PurchaseRequest> requests) {
    setState(() {
      for (var request in requests) {
        _readNotifications.add(_getRequestId(request));
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';

    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'اليوم ${DateFormat('h:mm a', 'ar').format(date)}';
      } else if (difference.inDays == 1) {
        return 'أمس ${DateFormat('h:mm a', 'ar').format(date)}';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return DateFormat('d MMM yyyy', 'ar').format(date);
      }
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<List<PurchaseRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return ErrorDisplay(
              errorMessageKey:
              snapshot.error.toString().contains('noInternet')
                  ? 'noInternet'
                  : 'serverError',
              onRetry: _fetchData,
            );
          }

          final requests = snapshot.data ?? [];
          final unreadCount = _getUnreadCount(requests);

          return CustomScrollView(
            slivers: [
              _buildAppBar(unreadCount, requests, isRtl),
              requests.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState())
                  : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildNotificationCard(
                          requests[index],
                          isRtl,
                        ),
                      );
                    },
                    childCount: requests.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF6C63FF),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
      int unreadCount, List<PurchaseRequest> requests, bool isRtl) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF6C63FF),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: () => _markAllAsRead(requests),
            icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
            label: Text(
              isRtl ? 'تحديد الكل كمقروء' : 'Mark all as read',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isRtl ? 'إشعارات طلبات الشراء' : 'Purchase Requests',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRtl
                              ? '$unreadCount إشعار غير مقروء'
                              : '$unreadCount unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(PurchaseRequest request, bool isRtl) {
    final requestId = _getRequestId(request);
    final isRead = _readNotifications.contains(requestId);

    return GestureDetector(
      onTap: () async {
        _markAsRead(request);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseRequestDetailScreen(
              user: widget.user,
              request: request,
            ),
          ),
        );

        _fetchData();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead
              ? Colors.white
              : const Color(0xFF6C63FF).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? Colors.grey.withOpacity(0.15)
                : const Color(0xFF6C63FF).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.grey.withOpacity(0.1)
                      : const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: isRead
                      ? Colors.grey.shade600
                      : const Color(0xFF6C63FF),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (request.store_name != null &&
                        request.store_name!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.store_outlined,
                            size: 16,
                            color: Color(0xFF6C63FF),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request.store_name!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: const Color(0xFF6C63FF),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (request.store_name != null &&
                        request.store_name!.isNotEmpty)
                      const SizedBox(height: 8),
                    Text(
                      isRtl
                          ? (request.descA ?? 'لا يوجد وصف')
                          : (request.descE ?? 'No description'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        isRead ? FontWeight.w500 : FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDate(request.reqDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${request.trnsSerial}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isRtl ? 'لا توجد إشعارات' : 'No Notifications',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRtl
                ? 'لا توجد طلبات شراء حالياً'
                : 'No purchase requests available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

