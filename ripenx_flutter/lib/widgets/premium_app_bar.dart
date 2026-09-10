import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const PremiumAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBack = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack && Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.deepCharcoal),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(title, style: AppTypography.h2),
      actions: actions,
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
    );
  }
}
