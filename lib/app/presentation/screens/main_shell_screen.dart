import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass/glass_scaffold.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/bookings')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/bookings');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return GlassScaffoldBackground(
      isDark: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        extendBody: false,
        bottomNavigationBar: Container(
          color: AppColors.background,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.midnightNavy.withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      currentIndex: selectedIndex,
                      label: 'Explore',
                      selectedIcon: Icons.sports_soccer_rounded,
                      unselectedIcon: Icons.sports_soccer_outlined,
                      onTap: () => _onItemTapped(0, context),
                    ),
                    _buildNavItem(
                      index: 1,
                      currentIndex: selectedIndex,
                      label: 'My Bookings',
                      selectedIcon: Icons.calendar_today_rounded,
                      unselectedIcon: Icons.calendar_today_outlined,
                      onTap: () => _onItemTapped(1, context),
                    ),
                    _buildNavItem(
                      index: 2,
                      currentIndex: selectedIndex,
                      label: 'Profile',
                      selectedIcon: Icons.person_rounded,
                      unselectedIcon: Icons.person_outline_rounded,
                      onTap: () => _onItemTapped(2, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required String label,
    required IconData selectedIcon,
    required IconData unselectedIcon,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.electricCyan.withValues(alpha: 0.12),
          highlightColor: AppColors.electricCyan.withValues(alpha: 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Subtle Electric Cyan active top bar indicator (no oversized pill around icon)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 2.5,
                width: isSelected ? 20 : 0,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.electricCyan,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Icon(
                isSelected ? selectedIcon : unselectedIcon,
                size: 21,
                color: isSelected
                    ? AppColors.electricCyan
                    : Colors.white.withValues(alpha: 0.58),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.58),
                  letterSpacing: 0.1,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
