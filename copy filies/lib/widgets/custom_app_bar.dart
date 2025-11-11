import 'package:flutter/material.dart';
import '../main.dart'; // تأكد من أن هذا المسار صحيح لملف main.dart

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    return AppBar(
      centerTitle: true,
      title: Text(title,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),),
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.language,color: Colors.white,),
          tooltip: 'Change Language',
          onPressed: () {
            // ✅ الكود الجديد الأكثر أمانًا لتغيير اللغة
            final myAppState = MyApp.of(context);
            if (myAppState != null) {
              if (currentLocale.languageCode == 'ar') {
                myAppState.changeLanguage(const Locale('en', ''));
              } else {
                myAppState.changeLanguage(const Locale('ar', ''));
              }
            } else {
              // رسالة للمطور في حالة لم يتم العثور على الحالة
              print("Error: MyAppState not found in context.");
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not change language.'))
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
