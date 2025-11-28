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
      toolbarHeight: 50.0,

      // Makes the AppBar match the scaffold background
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16.0,
      title: const Text(
        'Easy Rail',
        style: AppTheme.logo, // Uses the 'Lemonada' font
      ),

      actions: [
        IconButton(
          icon: const Icon(
            Icons.contact_support, // A good substitute for the  logo
            color: AppTheme.textPrimary,
            size: 24.0,
          ),
          tooltip: 'Original Repository', // From your <a> tag title
          onPressed: _launch,
        ),
        // Provides the 20px right padding from your CSS
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
