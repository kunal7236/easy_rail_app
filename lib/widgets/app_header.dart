import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  Future<void> _launch() async {
    final Uri url = Uri.parse('https://kunalkashyap.tech');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // You could show a SnackBar here on error
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70.0,

      // Makes the AppBar match the scaffold background
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        'Easy Rail',
        style: AppTheme.logo, // Uses the 'Lemonada' font
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.contact_support, // A good substitute for the  logo
            color: AppTheme.textPrimary,
            size: 30.0, // Close to your 40px SVG size
          ),
          tooltip: 'Original Repository', // From your <a> tag title
          onPressed: _launch,
        ),
        // Provides the 20px right padding from your CSS
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
