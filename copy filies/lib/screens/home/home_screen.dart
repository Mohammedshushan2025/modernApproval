
import 'package:hexcolor/hexcolor.dart';
import 'package:modernapproval/models/dashboard_stats_model.dart';
import 'package:modernapproval/models/form_report_model.dart';
import 'package:modernapproval/screens/approvals/approvals_screen.dart';
import 'package:modernapproval/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modernapproval/screens/reports/reports_screen.dart';
import 'package:modernapproval/services/api_service.dart';
import '../../models/user_model.dart';
import '../../app_localizations.dart';
import '../../widgets/home_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // --- ✅ متغيرات جديدة لجلب البيانات ---
  final ApiService _apiService = ApiService();
  late Future<List<FormReportItem>> _formsReportsFuture;
  late Future<DashboardStats> _statsFuture;
  int _approvalsCount = 0;
  int _reportsCount = 0;
  bool _countsLoading = true;
  DashboardStats? _dashboardStats;
  bool _statsLoading = true;
  // ------------------------------------

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // --- ✅ جلب البيانات عند بدء الشاشة ---
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  // --- ✅ دالة جلب البيانات ---
  void _loadData() {
    if (!mounted) return; // التأكد من أن الويدجت ما زالت موجودة
    setState(() {
      _countsLoading = true;
      _statsLoading = true;
    });

    // جلب عدد الموافقات والتقارير
    _formsReportsFuture = _apiService.getFormsAndReports(widget.user.usersCode);
    _formsReportsFuture.then((items) {
      if (!mounted) return;
      setState(() {
        _approvalsCount = items.where((item) => item.type == 'F').length;
        _reportsCount = items.where((item) => item.type == 'R').length;
        _countsLoading = false;
      });
    }).catchError((e) {
      print("Error fetching forms/reports count: $e");
      if (!mounted) return;
      setState(() {
        _countsLoading = false; // حتى لو فشل، نوقف التحميل
        // عرض صفر في حالة الخطأ
        _approvalsCount = 0;
        _reportsCount = 0;
      });
    });

    // جلب إحصائيات الداشبورد
    _statsFuture = _apiService.getDashboardStats(widget.user.usersCode);
    _statsFuture.then((stats) {
      if (!mounted) return;
      setState(() {
        _dashboardStats = stats;
        _statsLoading = false;
      });
    }).catchError((e) {
      print("Error fetching dashboard stats: $e");
      if (!mounted) return;
      setState(() {
        _statsLoading = false; // نوقف التحميل
        _dashboardStats = DashboardStats(countAuth: 0, countReject: 0); // قيم صفرية عند الخطأ
      });
    });
  }


  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            HomeAppBar(user: widget.user),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildBody(isRtl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isRtl) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    final horizontalPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final verticalSpacing = isSmallScreen ? 14.0 : (isMediumScreen ? 18.0 : 22.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          verticalSpacing,
          horizontalPadding,
          verticalSpacing + 10
      ),
      child: Column(
        children: [

          _buildModernTopCards(isRtl, _approvalsCount, _reportsCount, _countsLoading),
          SizedBox(height: verticalSpacing),
          _buildModernProfileCard(
            title: localizations.translate('profile') ?? (isRtl ? 'الملف الشخصي' : 'Profile'),
            subtitle: isRtl ? 'إدارة حسابك الشخصي' : 'Manage your account',
            isRtl: isRtl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(

                  builder: (context) => ProfileScreen(user: widget.user.usersCode),
                ),
              );
            },
          ),
          SizedBox(height: verticalSpacing),

          _buildModernStats(isRtl, _dashboardStats, _statsLoading),
        ],
      ),
    );
  }


  Widget _buildModernTopCards(bool isRtl, int approvalsCount, int reportsCount, bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final spacing = isSmallScreen ? 10.0 : 14.0;

    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            title: isRtl ? 'الموافقات' : 'Approvals',
            subtitle: isRtl ? 'قيد الانتظار' : 'Waiting',
            icon: Icons.assignment_turned_in_outlined,
            // --- استخدام العدد الفعلي أو مؤشر تحميل ---
            count: isLoading ? '...' : approvalsCount.toString(),
            isRtl: isRtl,
            primaryColor: const Color(0xFF00BFA6),
            secondaryColor: const Color(0xFF00E5CC),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalsScreen(user: widget.user),
                ),
              );
            },
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _buildGlassCard(
            title: isRtl ? 'التقارير' : 'Reports',
            subtitle: isRtl ? 'التحليلات' : 'Analytics',
            icon: Icons.analytics_outlined,

            count: isLoading ? '...' : reportsCount.toString(),
            isRtl: isRtl,
            primaryColor: const Color(0xFFFF6B6B),
            secondaryColor: const Color(0xFFFF8787),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(user: widget.user),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String count,
    required bool isRtl,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    final isShortScreen = screenHeight < 700;

    final cardHeight = isShortScreen ? 100.0 : (isSmallScreen ? 108.0 : (isMediumScreen ? 120.0 : 135.0));
    final iconSize = isShortScreen ? 20.0 : (isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 26.0));
    final padding = isShortScreen ? 8.0 : (isSmallScreen ? 10.0 : 14.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        primaryColor.withOpacity(0.2),
                        primaryColor.withOpacity(0.0),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: isShortScreen ? 36 : (isSmallScreen ? 38 : 44),
                          height: isShortScreen ? 36 : (isSmallScreen ? 38 : 44),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: isShortScreen ? 20 : iconSize,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isShortScreen ? 8 : (isSmallScreen ? 10 : 12),
                                  vertical: isShortScreen ? 4 : (isSmallScreen ? 5 : 6),
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  count,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: isSmallScreen ? 13 : 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: isShortScreen ? 3 : 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Color(0xFF1A1F36),
                                fontSize: isShortScreen ? 13 : (isSmallScreen ? 14 : 17),
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 1),
                          Flexible(
                            child: Text(
                              subtitle,
                              style: TextStyle(
                                color: Color(0xFF8E95B2),
                                fontSize: isShortScreen ? 8 : (isSmallScreen ? 9 : 11),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildModernProfileCard({
    required String title,
    required String subtitle,
    required bool isRtl,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    final isShortScreen = screenHeight < 700;

    final cardHeight = isShortScreen ? 100.0 : (isSmallScreen ? 120.0 : (isMediumScreen ? 125.0 : 140.0));
    final avatarSize = isShortScreen ? 38.0 : (isSmallScreen ? 42.0 : (isMediumScreen ? 42.0 : 48.0));
    final padding = isShortScreen ? 12.0 : (isSmallScreen ? 16.0 : 22.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: HexColor('f1eefc'),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          children: [

            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.person,
                        color: const Color(0xFF667EEA),
                        size: isShortScreen ? 18 : (isSmallScreen ? 22 : 30),
                      ),
                    ),
                  ),
                  SizedBox(width: isShortScreen ? 8 : (isSmallScreen ? 12 : 18)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isShortScreen ? 15 : (isSmallScreen ? 17 : 20),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                        SizedBox(height: isShortScreen ? 2 : 5),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.9),
                              fontSize: isShortScreen ? 10 : (isSmallScreen ? 11 : 13),
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: isShortScreen ? 3 : 10),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isShortScreen ? 8 : 10,
                              vertical: isShortScreen ? 4 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: HexColor('97989c'),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isRtl ? 'فتح الملف' : 'Open Profile',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 6,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildModernStats(bool isRtl, DashboardStats? stats, bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final l = AppLocalizations.of(context)!;


    String approvedValue = isLoading ? '...' : (stats?.countAuth.toString() ?? '0');
    String rejectedValue = isLoading ? '...' : (stats?.countReject.toString() ?? '0');

    double total = ((stats?.countAuth ?? 0) + (stats?.countReject ?? 0)).toDouble();
    double approvedProgress = (isLoading || total == 0.0) ? 0.0 : (stats!.countAuth / total);
    double rejectedProgress = (isLoading || total == 0.0) ? 0.0 : (stats!.countReject / total);


    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF667EEA),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRtl ? 'إحصائيات' : "Stats",
                style: TextStyle(
                  color: const Color(0xFF1A1F36),
                  fontSize: isSmallScreen ? 16 : 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [

              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  value: approvedValue,
                  label: l.translate('approved'),
                  color: const Color(0xFF10B981),
                  progress: approvedProgress,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: _buildStatCard(
                  icon: Icons.highlight_off,
                  value: rejectedValue,
                  label: l.translate('rejected'),
                  color: const Color(0xFFFF6B6B),
                  progress: rejectedProgress,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double progress,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [

          value == '...'
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Icon(
            icon,
            color: color,
            size: isSmallScreen ? 20 : 22,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF1A1F36),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF8E95B2),
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),

            child: value == '...'
                ? const LinearProgressIndicator()
                : FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress.isNaN ? 0.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

