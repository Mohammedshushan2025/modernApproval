import 'package:flutter/material.dart';
import '../main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? filterWidget;

  const CustomAppBar({super.key, required this.title, this.filterWidget});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 2,
      actions: [
        if (filterWidget != null) filterWidget!,
        IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          tooltip: 'Change Language',
          onPressed: () {
            final myAppState = MyApp.of(context);
            if (myAppState != null) {
              if (currentLocale.languageCode == 'ar') {
                myAppState.changeLanguage(const Locale('en', ''));
              } else {
                myAppState.changeLanguage(const Locale('ar', ''));
              }
            } else {
              print("Error: MyAppState not found in context.");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not change language.')),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
