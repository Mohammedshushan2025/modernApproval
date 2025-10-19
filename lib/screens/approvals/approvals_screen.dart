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

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // 1. جلب مجموعات الباسورد (الفروع)
    _passwordGroupsFuture = _apiService.getUserPasswordGroups(widget.user.usersCode);

    // 2. بعد جلب الفروع، حدد الافتراضي
    _passwordGroupsFuture.then((groups) {
      if (groups.isNotEmpty) {
        setState(() {
          _selectedPasswordGroup = groups.firstWhere(
                (g) => g.isDefault,
            orElse: () => groups.first,
          );
        });
      }
    }).catchError((e) {
      // معالجة خطأ جلب الفروع
      print("Error fetching password groups: $e");
    });

    // 3. جلب قائمة الموافقات
    _approvalsFuture = _fetchAndProcessApprovals();
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
    // تأكد من أن المستخدم اختار فرعاً
    if (_selectedPasswordGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('noPasswordGroups'))),
      );
      return;
    }

    if (item.pageId == 101) { // اعتماد طلب شراء
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PurchaseRequestApprovalScreen(
            user: widget.user,
            // تمرير الرقم فقط
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
      // ==== بناء AppBar مخصص هنا ====
      appBar: AppBar(
        title: Text(l.translate('approvals')),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 2,
        actions: [
          // زر تغيير اللغة
          IconButton(
            icon: const Icon(Icons.language,color: Colors.white,),
            tooltip: 'Change Language',
            onPressed: () {
              final myAppState = MyApp.of(context);
              if (myAppState != null) {
                if (isArabic) {
                  myAppState.changeLanguage(const Locale('en', ''));
                } else {
                  myAppState.changeLanguage(const Locale('ar', ''));
                }
              }
            },
          ),
          // ==== Dropdown لاختيار الفرع ====
          _buildPasswordGroupDropdown(),
        ],
      ),
      // ==== الشريط السفلي الثابت ====
      bottomNavigationBar: _buildSelectedGroupFooter(l),
      body: FutureBuilder<List<FormReportItem>>(
        future: _approvalsFuture,
        builder: (context, snapshot) {
          // ... (نفس كود FutureBuilder الخاص بقائمة الموافقات)
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
              );
            },
          );
        },
      ),
    );
  }

  // ==== ودجت الشريط السفلي ====
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

  // ==== ودجت الـ Dropdown ====
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
        // تأكد من أن _selectedPasswordGroup له قيمة من القائمة
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
                  });
                }
              },
              items: groups.map<DropdownMenuItem<PasswordGroup>>((PasswordGroup group) {
                return DropdownMenuItem<PasswordGroup>(
                  value: group,
                  child: Text(
                    group.passwordName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'Amiri'), // استخدام الخط العربي
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
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
        title: Text(l.translate('approvals')),
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

