import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/facility_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../bookings/presentation/providers/customer_bookings_provider.dart';
import '../../../resort_info/presentation/providers/resort_config_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditProfileSheet(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String? currentNotes,
  ) {
    final nameController = TextEditingController(text: currentName);
    final notesController = TextEditingController(text: currentNotes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom:
              MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutral,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Details',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.midnightNavy,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Your name',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.deepSportsBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: notesController,
              label: 'Notes (Optional)',
              hint: 'e.g. Preferred session times or notes',
              maxLines: 2,
              prefixIcon: const Icon(
                Icons.note_alt_outlined,
                color: AppColors.deepSportsBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              text: 'Save Changes',
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty) return;
                final success = await ref
                    .read(authStateProvider.notifier)
                    .updateProfile(
                      name: newName,
                      notes: notesController.text.trim(),
                    );
                if (success && sheetContext.mounted) {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context, WidgetRef ref) {
    final config = ref.read(resortConfigProvider).valueOrNull;

    final phone = config?.businessMobile.isNotEmpty == true
        ? config!.businessMobile
        : '+94 78 923 8808';
    final email = config?.businessEmail.isNotEmpty == true
        ? config!.businessEmail
        : 'info@zeinspool.com';
    final address = config?.businessAddress.isNotEmpty == true
        ? config!.businessAddress
        : 'Sammanthurai, Sri Lanka';
    final resortName = config?.resortName.isNotEmpty == true
        ? config!.resortName
        : "Zein's Pool & Turf";

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderNeutral,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Help & Support',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.midnightNavy,
              ),
            ),
            Text(
              'Direct assistance for $resortName reservations',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(Icons.phone_outlined, 'Phone & WhatsApp', phone),
            const Divider(height: 20, color: AppColors.borderSubtle),
            _buildContactItem(Icons.email_outlined, 'Email', email),
            const Divider(height: 20, color: AppColors.borderSubtle),
            _buildContactItem(Icons.location_on_outlined, 'Location', address),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepSportsBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedSteel,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.midnightNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    final bookingsCount = bookingsAsync.valueOrNull?.length ?? 0;

    if (!authState.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.midnightNavy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      FacilityAssets.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person_outline_rounded,
                        size: 32,
                        color: AppColors.electricCyan,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Sign In to Your Account',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.midnightNavy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Manage your turf and pool bookings, personal details, and reservation passes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    text: 'Sign In / Register',
                    icon: const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () => context.push('/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final customer = authState.customer!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            16,
            AppSpacing.lg,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial Page Title
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.oceanBlue,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.midnightNavy,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              // A & B. Editorial Personal Header with Single Authentic Total Bookings Metric (No Elite VIP!)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.midnightNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Minimal Avatar with Initials
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.deepSportsBlue,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.electricCyan.withValues(
                                alpha: 0.45,
                              ),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              customer.name.isNotEmpty
                                  ? customer.name[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.electricCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDisplayPhone(customer.mobile),
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditProfileSheet(
                            context,
                            ref,
                            customer.name,
                            customer.notes,
                          ),
                          tooltip: 'Edit Profile',
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.electricCyan,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Bookings',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                          Text(
                            '$bookingsCount',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.electricCyan,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // C. Concise Settings & Actions List (Clean Hairline Dividers, Not Individual Boxes)
              const Text(
                'PREFERENCES & SUPPORT',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.mutedSteel,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderNeutral),
                ),
                child: Column(
                  children: [
                    _buildActionRow(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal details',
                      subtitle: 'Update your name and booking notes',
                      onTap: () => _showEditProfileSheet(
                        context,
                        ref,
                        customer.name,
                        customer.notes,
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildActionRow(
                      icon: Icons.calendar_today_outlined,
                      title: 'Booking history',
                      subtitle: 'View upcoming and past reservations',
                      onTap: () => context.go('/bookings'),
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildActionRow(
                      icon: Icons.support_agent_rounded,
                      title: 'Help and support',
                      subtitle: 'Direct contact for pool & turf assistance',
                      onTap: () => _showSupportSheet(context, ref),
                    ),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildActionRow(
                      icon: Icons.info_outline_rounded,
                      title: 'Facility guidelines & terms',
                      subtitle: 'Operating hours and reservation rules',
                      onTap: () => context.push('/resort-info'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // D. Visually Separated Sign-Out Action
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await AppDialog.confirm(
                    context,
                    title: 'Sign Out',
                    message:
                        'Are you sure you want to sign out of your account?',
                    confirmText: 'Sign Out',
                    isDestructive: true,
                  );
                  if (confirm == true) {
                    await ref.read(authStateProvider.notifier).logout();
                  }
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 17,
                  color: AppColors.error,
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // E. Understated Brand Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: 0.75,
                    child: Image.asset(
                      FacilityAssets.logo,
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final config = ref
                          .watch(resortConfigProvider)
                          .valueOrNull;
                      final name = config?.resortName.isNotEmpty == true
                          ? config!.resortName
                          : "Zein's Pool & Turf";
                      return Text(
                        '$name · v1.0.0',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedSteel,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.deepSportsBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.midnightNavy,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.mutedSteel,
            ),
          ],
        ),
      ),
    );
  }
}
