import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_environment.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class ZeinsPoolCustomerApp extends ConsumerWidget {
  const ZeinsPoolCustomerApp({super.key});

  static const double _maxDesktopContentWidth = 640.0;
  static const double _desktopBreakpoint = 680.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppEnvironment.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            if (screenWidth <= _desktopBreakpoint) {
              return content;
            }

            final mediaQuery = MediaQuery.of(context);
            final constrainedSize = Size(
              _maxDesktopContentWidth,
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : mediaQuery.size.height,
            );

            // Responsive desktop & wide-tablet presentation frame
            return ColoredBox(
              color: const Color(0xFFE6EEF6),
              child: Center(
                child: Container(
                  width: _maxDesktopContentWidth,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: const Border.symmetric(
                      vertical: BorderSide(color: AppColors.borderNeutral),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.midnightNavy.withValues(alpha: 0.10),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: MediaQuery(
                    data: mediaQuery.copyWith(size: constrainedSize),
                    child: content,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
