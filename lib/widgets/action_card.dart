import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // الأيقونة الرئيسية على اليسار
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // النص في المنتصف
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                      height: 1.4,
                    ),
                  ),
                ),
                // السهم على اليمين
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? Icons.arrow_back_ios_new
                        : Icons.arrow_forward_ios,
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