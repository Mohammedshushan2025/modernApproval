import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:modernapproval/screens/notifications_screen.dart';

import '../models/user_model.dart';
import '../app_localizations.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../widgets/profile_avatar.dart';

class HomeAppBar extends StatefulWidget {
  final UserModel user;

  const HomeAppBar({super.key, required this.user});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String currentTime = '';
  String currentLocation = '';
  Timer? _timer;
  bool _isLoadingLocation = true;
  int _notificationCount = 0;
  static final Set<String> _readNotifications = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
    _getCurrentLocation();
    _updateNotificationCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('h:mm a', 'ar');
    setState(() {
      currentTime = formatter.format(now);
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
          .where(
            (r) =>
                !_readNotifications.contains(
                  '${r.trnsTypeCode}_${r.trnsSerial}',
                ),
          )
          .length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = 'غير محدد';
            _isLoadingLocation = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = 'غير محدد';
          _isLoadingLocation = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final isRtl = Localizations.localeOf(context).languageCode == 'ar';
        String locationText =
            isRtl
                ? '${placemark.country ?? ''}, ${placemark.administrativeArea ?? ''}'
                : '${placemark.administrativeArea ?? ''}, ${placemark.country ?? ''}';
        setState(() {
          currentLocation = locationText.replaceAll(', ', ', ').trim();
          if (currentLocation.startsWith(','))
            currentLocation = currentLocation.substring(2);
          if (currentLocation.endsWith(','))
            currentLocation = currentLocation.substring(
              0,
              currentLocation.length - 2,
            );
          _isLoadingLocation = false;
        });
      } else {
        setState(() {
          currentLocation = 'غير محدد';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = 'غير محدد';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _updateNotificationCount() async {
    try {
      final count = await getUnreadCount(
        apiService: ApiService(),
        userId: widget.user.usersCode,
        roleId: widget.user.roleCode!,
        passwordNumber: 10327,
      );
      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      print('Error updating notification count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    final themeColor = const Color(0xFF6C63FF);

    final String displayName =
        (isRtl ? widget.user.empName : widget.user.empNameE) ??
        widget.user.empName;
    final String displayJob =
        (isRtl ? widget.user.role_name_a : widget.user.role_name_e) ??
        widget.user.role_name_a ??
        '';

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      pinned: false,
      automaticallyImplyLeading: false,
      expandedHeight: 200.0,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildModernBackground(
          context,
          displayName,
          displayJob,
          themeColor,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 25,
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBackground(
    BuildContext context,
    String name,
    String job,
    Color themeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColor,
            themeColor.withOpacity(0.85),
            const Color(0xFF8B5CF6),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          _buildMinimalDecorativeBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 15,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // _buildLocationTimeWidget(context),
                      Row(
                        children: [
                          _buildCompactUserAvatar(),
                          const SizedBox(width: 16),
                          _buildUserInfo(context, name, job),
                        ],
                      ),

                      _buildTopControlButtons(context),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(horizontal: 50),

                      decoration: BoxDecoration(
                        color: Color(0xFFFAFBFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                              2.0,
                              2.0,
                            ), // shadow direction: bottom right
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 1.0,
                            spreadRadius: 0.0,
                            offset: Offset(
                              -2.0,
                              3,
                            ), // shadow direction: bottom right
                          ),
                        ],
                      ),
                      child: _buildCompactUserAvatarpart2(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactUserAvatar() {
    final String profileImageUrl =
        'http://195.201.241.253:7001/ords/modern/Approval/emp_photo/${widget.user.usersCode}';
    final String fallbackImageAsset =
        (widget.user.gender == 'M')
            ? "assets/images/photo.jpg"
            : "assets/images/photo.jpg";

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox(
          width: 56,
          height: 56,
          child: Image.network(
            profileImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Image.asset(fallbackImageAsset, fit: BoxFit.cover);
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(fallbackImageAsset, fit: BoxFit.cover);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactUserAvatarpart2() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: ClipOval(
        child: SizedBox(height: 56, child: Image.asset("assets/images/lo.png")),
      ),
    );
  }

  Widget _buildLocationTimeWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                currentTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              _isLoadingLocation
                  ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(
                      currentLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalDecorativeBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, String name, String job) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      crossAxisAlignment:
          isRtl ? CrossAxisAlignment.center : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 4),
        if (job.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              job,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildTopControlButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactActionButton(
          icon: Icons.notifications_outlined,
          onTap: () async {
            HapticFeedback.lightImpact();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NotificationsScreen(
                      user: widget.user,
                      selectedPasswordNumber: 10327,
                    ),
              ),
            );
            _updateNotificationCount();
          },
          badgeCount: _notificationCount > 0 ? _notificationCount : null,
        ),
        const SizedBox(width: 8),
        _buildCompactActionButton(
          icon: Icons.language_outlined,
          onTap: () {
            HapticFeedback.lightImpact();
            final currentLocale = Localizations.localeOf(context);
            final newLocale =
                currentLocale.languageCode == 'en'
                    ? const Locale('ar', '')
                    : const Locale('en', '');
            MyApp.of(context)?.changeLanguage(newLocale);
          },
        ),
        const SizedBox(width: 8),
        _buildCompactActionButton(
          icon: Icons.logout_outlined,
          onTap: () {
            HapticFeedback.lightImpact();
            _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4757),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 1.5),
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Color(0xFF6C63FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
