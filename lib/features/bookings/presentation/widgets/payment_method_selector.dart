import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../resort_info/domain/entities/resort_config.dart';
import 'receipt_upload_card.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.allowOnlinePayment = true,
    this.bankInfo,
    this.receiptFile,
    this.onReceiptChanged,
    this.receiptUploadEnabled = true,
  });

  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final bool allowOnlinePayment;
  final BankInfo? bankInfo;
  final ReceiptFileInfo? receiptFile;
  final ValueChanged<ReceiptFileInfo?>? onReceiptChanged;
  final bool receiptUploadEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onMethodChanged('online'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.deepSportsBlue,
            width: 1.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.midnightNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                color: AppColors.electricCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'PayHere Online Payment',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.midnightNavy,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.deepSportsBlue,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Visa, MasterCard, FriMi, eZ Cash & Genie. Your reservation is confirmed after backend payment verification.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
