/*
import 'package:flutter/material.dart';
import 'package:modernapproval/models/password_group_model.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_approval_screen.dart';
import '../../app_localizations.dart';
import '../../models/form_report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/action_card.dart';
import '../../widgets/error_display.dart';
import '../../main.dart'; // لاستخدام دالة تغيير اللغة

class ApprovalsScreen extends StatefulWidget {
  final UserModel user;
  const ApprovalsScreen({super.key, required this.user});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late Future<List<FormReportItem>> _approvalsFuture;
  late Future<List<PasswordGroup>> _passwordGroupsFuture;
  PasswordGroup? _selectedPasswordGroup;
  final ApiService _apiService = ApiService();

  // <-- الخطوة 1: إضافة متغيرات لتخزين العدد وحالة التحميل
  final Map<int, int> _approvalCounts = {};
  bool _isCountLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _passwordGroupsFuture = _apiService.getUserPasswordGroups(widget.user.usersCode);
    _passwordGroupsFuture.then((groups) {
      if (groups.isNotEmpty) {
        // <-- التأكد من أن setState لا يتم استدعاؤه إذا تم الخروج من الشاشة
        if (!mounted) return;
        setState(() {
          _selectedPasswordGroup = groups.firstWhere(
                (g) => g.isDefault,
            orElse: () => groups.first,
          );
          // <-- الخطوة 2: جلب العدد لأول مرة بعد تحديد الفرع
          _fetchAndSetPurchaseRequestCount();
        });
      }
    }).catchError((e) {
      print("Error fetching password groups: $e");
    });

    _approvalsFuture = _fetchAndProcessApprovals();
  }

  // <-- الخطوة 3: دالة جديدة لجلب عدد طلبات الشراء
  Future<void> _fetchAndSetPurchaseRequestCount() async {
    if (_selectedPasswordGroup == null) return;
    if (!mounted) return;

    setState(() {
      _isCountLoading = true;
    });

    try {
      final requests = await _apiService.getPurchaseRequests(
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: _selectedPasswordGroup!.passwordNumber,
      );
      // <-- تخزين العدد في الخريطة
      _approvalCounts[101] = requests.length;
    } catch (e) {
      print("Error fetching purchase request count: $e");
      _approvalCounts[101] = 0; // وضع صفر في حالة الخطأ
    } finally {
      if (mounted) {
        setState(() {
          _isCountLoading = false;
        });
      }
    }
  }

  Future<List<FormReportItem>> _fetchAndProcessApprovals() async {
    final items = await _apiService.getFormsAndReports(widget.user.usersCode);
    final approvals = items.where((item) => item.type == 'F').toList();
    approvals.sort((a, b) => a.ord.compareTo(b.ord));
    return approvals;
  }

  void _fetchData() {
    setState(() {
      _approvalsFuture = _fetchAndProcessApprovals();
    });
  }

  void _handleNavigation(FormReportItem item) {
    if (_selectedPasswordGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('noPasswordGroups'))),
      );
      return;
    }
    if (item.pageId == 101) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchaseRequestApprovalScreen(
            user: widget.user,
            selectedPasswordNumber: _selectedPasswordGroup!.passwordNumber,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work in progress for: ${item.pageNameE}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: 'Change Language',
            onPressed: () {
              final myAppState = MyApp.of(context);
              if (myAppState != null) {
                myAppState.changeLanguage(
                    isArabic ? const Locale('en', '') : const Locale('ar', ''));
              }
            },
          ),
          _buildPasswordGroupDropdown(),
        ],
      ),
      bottomNavigationBar: _buildSelectedGroupFooter(l),
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
            return Center(child: Text(l.translate('noData')));
          }
          final approvals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final item = approvals[index];
              final colors = _getColorsForItem(item.pageId);

              return ActionCard(
                title: isArabic ? item.pageName : item.pageNameE,
                icon: _getIconForItem(item.pageId),
                iconColor: colors['icon']!,
                backgroundColor: colors['background']!,
                onTap: () => _handleNavigation(item),
                // <-- الخطوة 5: تمرير العدد وحالة التحميل إلى الكرت
                // نعرض العدد فقط إذا كانت pageId هي 101
                notificationCount: item.pageId == 101 ? _approvalCounts[101] : null,
                isCountLoading: item.pageId == 101 && _isCountLoading,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedGroupFooter(AppLocalizations l) {
    return Container(
      height: 50,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_mall_directory, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedPasswordGroup != null
                  ? "${l.translate('selectedBranch')}: ${_selectedPasswordGroup!.passwordName}"
                  : l.translate('noPasswordGroups'),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordGroupDropdown() {
    return FutureBuilder<List<PasswordGroup>>(
      future: _passwordGroupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Icon(Icons.error_outline, color: Colors.red);
        }
        final groups = snapshot.data!;
        if (_selectedPasswordGroup != null && !groups.any((g) => g.passwordNumber == _selectedPasswordGroup!.passwordNumber)) {
          _selectedPasswordGroup = groups.first;
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PasswordGroup>(
              value: _selectedPasswordGroup,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              dropdownColor: const Color(0xFF1A1F36),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (PasswordGroup? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPasswordGroup = newValue;
                    // <-- الخطوة 4: إعادة جلب العدد عند تغيير الفرع
                    _fetchAndSetPurchaseRequestCount();
                  });
                }
              },
              items: groups.map<DropdownMenuItem<PasswordGroup>>((PasswordGroup group) {
                return DropdownMenuItem<PasswordGroup>(
                  value: group,
                  child: Text(
                    group.passwordName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Amiri'),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForItem(int pageId) {
    switch (pageId) {
      case 101:
        return Icons.shopping_cart_outlined;
      case 102:
        return Icons.local_shipping_outlined;
      case 103:
        return Icons.attach_money;
      case 104:
        return Icons.inventory_2_outlined;
      case 105:
        return Icons.output_outlined;
      case 106:
        return Icons.input_outlined;
      case 107:
        return Icons.receipt_long_outlined;
      case 108:
        return Icons.point_of_sale;
      case 109:
        return Icons.event_busy_outlined;
      case 110:
        return Icons.badge_outlined;
      case 111:
        return Icons.payments_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Map<String, Color> _getColorsForItem(int pageId) {
    switch (pageId) {
      case 101:
        return {
          'background': const Color(0xFFE3F2FD),
          'icon': const Color(0xFF1976D2),
        };
      case 102:
        return {
          'background': const Color(0xFFE8F5E9),
          'icon': const Color(0xFF388E3C),
        };
      case 103:
        return {
          'background': const Color(0xFFE0F2F1),
          'icon': const Color(0xFF00897B),
        };
      case 104:
        return {
          'background': const Color(0xFFF3E5F5),
          'icon': const Color(0xFF7B1FA2),
        };
      case 105:
        return {
          'background': const Color(0xFFFFF3E0),
          'icon': const Color(0xFFF57C00),
        };
      case 106:
        return {
          'background': const Color(0xFFE1F5FE),
          'icon': const Color(0xFF0288D1),
        };
      case 107:
        return {
          'background': const Color(0xFFECEFF1),
          'icon': const Color(0xFF546E7A),
        };
      case 108:
        return {
          'background': const Color(0xFFFCE4EC),
          'icon': const Color(0xFFC2185B),
        };
      case 109:
        return {
          'background': const Color(0xFFFFF9C4),
          'icon': const Color(0xFFF9A825),
        };
      case 110:
        return {
          'background': const Color(0xFFEFEBE9),
          'icon': const Color(0xFF6D4C41),
        };
      case 111:
        return {
          'background': const Color(0xFFF0F4C3),
          'icon': const Color(0xFF9E9D24),
        };
      default:
        return {
          'background': const Color(0xFFF5F5F5),
          'icon': const Color(0xFF757575),
        };
    }
  }
}
*/
import 'package:flutter/material.dart';
import 'package:modernapproval/models/password_group_model.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_approval_screen.dart';
import '../../app_localizations.dart';
import '../../models/form_report_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/action_card.dart';
import '../../widgets/error_display.dart';
import '../../main.dart';

class ApprovalsScreen extends StatefulWidget {
  final UserModel user;
  const ApprovalsScreen({super.key, required this.user});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  late Future<List<FormReportItem>> _approvalsFuture;
  late Future<List<PasswordGroup>> _passwordGroupsFuture;
  PasswordGroup? _selectedPasswordGroup;
  final ApiService _apiService = ApiService();

  final Map<int, int> _approvalCounts = {};
  bool _isCountLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _passwordGroupsFuture = _apiService.getUserPasswordGroups(widget.user.usersCode);
    _passwordGroupsFuture.then((groups) {
      if (groups.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _selectedPasswordGroup = groups.firstWhere(
                (g) => g.isDefault,
            orElse: () => groups.first,
          );
          _fetchAndSetPurchaseRequestCount();
        });
      }
    }).catchError((e) {
      print("Error fetching password groups: $e");
    });

    _approvalsFuture = _fetchAndProcessApprovals();
  }

  Future<void> _refreshCounts() async {
    await _fetchAndSetPurchaseRequestCount();
  }

  Future<void> _fetchAndSetPurchaseRequestCount() async {
    if (_selectedPasswordGroup == null) return;
    if (!mounted) return;

    setState(() {
      _isCountLoading = true;
    });

    try {
      final requests = await _apiService.getPurchaseRequests(
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: _selectedPasswordGroup!.passwordNumber,
      );
      _approvalCounts[101] = requests.length;
    } catch (e) {
      print("Error fetching purchase request count: $e");
      _approvalCounts[101] = 0;
    } finally {
      if (mounted) {
        setState(() {
          _isCountLoading = false;
        });
      }
    }
  }

  Future<List<FormReportItem>> _fetchAndProcessApprovals() async {
    final items = await _apiService.getFormsAndReports(widget.user.usersCode);
    final approvals = items.where((item) => item.type == 'F').toList();
    approvals.sort((a, b) => a.ord.compareTo(b.ord));
    return approvals;
  }

  void _fetchData() {
    setState(() {
      _approvalsFuture = _fetchAndProcessApprovals();
    });
  }

  void _handleNavigation(FormReportItem item) async {
    if (_selectedPasswordGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('noPasswordGroups'))),
      );
      return;
    }
    if (item.pageId == 101) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchaseRequestApprovalScreen(
            user: widget.user,
            selectedPasswordNumber: _selectedPasswordGroup!.passwordNumber,
          ),
        ),
      );
      if (mounted) {
        _refreshCounts();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Work in progress for: ${item.pageNameE}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: _buildAppBar(context, isArabic),
      bottomNavigationBar: _buildSelectedGroupFooter(l, isArabic),
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
            return Center(child: Text(l.translate('noData')));
          }
          final approvals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final item = approvals[index];
              final colors = _getColorsForItem(item.pageId);

              return ActionCard(
                title: isArabic ? item.pageName : item.pageNameE,
                icon: _getIconForItem(item.pageId),
                iconColor: colors['icon']!,
                backgroundColor: colors['background']!,
                onTap: () => _handleNavigation(item),
                notificationCount: item.pageId == 101 ? _approvalCounts[101] : null,
                isCountLoading: item.pageId == 101 && _isCountLoading,
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isArabic) {
    return AppBar(
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 2,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isArabic ? 'الموافقات' : 'Approvals',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        _buildPasswordGroupDropdown(isArabic),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.language, color: Colors.white, size: 24),
          tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
          onPressed: () {
            final myAppState = MyApp.of(context);
            if (myAppState != null) {
              myAppState.changeLanguage(
                  isArabic ? const Locale('en', '') : const Locale('ar', ''));
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSelectedGroupFooter(AppLocalizations l, bool isArabic) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.store,
              color: Color(0xFF6C63FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedPasswordGroup != null
                  ? "${l.translate('selectedBranch')}: ${_selectedPasswordGroup!.passwordName}"
                  : l.translate('noPasswordGroups'),
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordGroupDropdown(bool isArabic) {
    return FutureBuilder<List<PasswordGroup>>(
      future: _passwordGroupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.error_outline, color: Colors.white70, size: 22),
          );
        }
        final groups = snapshot.data!;
        if (_selectedPasswordGroup != null &&
            !groups.any((g) => g.passwordNumber == _selectedPasswordGroup!.passwordNumber)) {
          _selectedPasswordGroup = groups.first;
        }

        return PopupMenuButton<PasswordGroup>(
          onSelected: (PasswordGroup newValue) {
            setState(() {
              _selectedPasswordGroup = newValue;
              _fetchAndSetPurchaseRequestCount();
            });
          },
          offset: const Offset(0, 48),
          color: const Color(0xFF5850E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.store_mall_directory,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          itemBuilder: (BuildContext context) {
            return groups.map((PasswordGroup group) {
              final isSelected = _selectedPasswordGroup?.passwordNumber == group.passwordNumber;
              return PopupMenuItem<PasswordGroup>(
                value: group,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          group.passwordName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  IconData _getIconForItem(int pageId) {
    switch (pageId) {
      case 101:
        return Icons.shopping_cart_outlined;
      case 102:
        return Icons.local_shipping_outlined;
      case 103:
        return Icons.attach_money;
      case 104:
        return Icons.inventory_2_outlined;
      case 105:
        return Icons.output_outlined;
      case 106:
        return Icons.input_outlined;
      case 107:
        return Icons.receipt_long_outlined;
      case 108:
        return Icons.point_of_sale;
      case 109:
        return Icons.event_busy_outlined;
      case 110:
        return Icons.badge_outlined;
      case 111:
        return Icons.payments_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Map<String, Color> _getColorsForItem(int pageId) {
    switch (pageId) {
      case 101:
        return {
          'background': const Color(0xFFE3F2FD),
          'icon': const Color(0xFF1976D2),
        };
      case 102:
        return {
          'background': const Color(0xFFE8F5E9),
          'icon': const Color(0xFF388E3C),
        };
      case 103:
        return {
          'background': const Color(0xFFE0F2F1),
          'icon': const Color(0xFF00897B),
        };
      case 104:
        return {
          'background': const Color(0xFFF3E5F5),
          'icon': const Color(0xFF7B1FA2),
        };
      case 105:
        return {
          'background': const Color(0xFFFFF3E0),
          'icon': const Color(0xFFF57C00),
        };
      case 106:
        return {
          'background': const Color(0xFFE1F5FE),
          'icon': const Color(0xFF0288D1),
        };
      case 107:
        return {
          'background': const Color(0xFFECEFF1),
          'icon': const Color(0xFF546E7A),
        };
      case 108:
        return {
          'background': const Color(0xFFFCE4EC),
          'icon': const Color(0xFFC2185B),
        };
      case 109:
        return {
          'background': const Color(0xFFFFF9C4),
          'icon': const Color(0xFFF9A825),
        };
      case 110:
        return {
          'background': const Color(0xFFEFEBE9),
          'icon': const Color(0xFF6D4C41),
        };
      case 111:
        return {
          'background': const Color(0xFFF0F4C3),
          'icon': const Color(0xFF9E9D24),
        };
      default:
        return {
          'background': const Color(0xFFF5F5F5),
          'icon': const Color(0xFF757575),
        };
    }
  }
}