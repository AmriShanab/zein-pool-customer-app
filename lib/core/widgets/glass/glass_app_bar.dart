import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// A modern, translucent glass AppBar with BackdropFilter blur and elegant touch targets.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.bottom,
    this.height = 56.0,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final double height;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton && canPop) {
      leadingWidget = Container(
        margin: const EdgeInsets.only(left: AppSpacing.md),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.burgundySoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.burgundyMuted,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(19),
                onTap: onBack ?? () => context.pop(),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 19,
                  color: AppColors.burgundy,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: leadingWidget,
        leadingWidth: leadingWidget != null ? 54 : null,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
        ),
        actions: actions != null
            ? [...actions!, const SizedBox(width: AppSpacing.sm)]
            : null,
        bottom: bottom,
      ),
    );
  }
}
