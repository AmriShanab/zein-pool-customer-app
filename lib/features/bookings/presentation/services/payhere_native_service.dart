import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

typedef PayHereTestHandler = Future<void> Function({
  required Map<String, dynamic> paymentObject,
  required Future<void> Function(String paymentId, String orderId) onSuccess,
  required void Function(String error) onError,
  required void Function() onDismissed,
});

/// Service managing PayHere in-app mobile checkout via official native SDK,
/// with automatic web checkout fallback when running as a Web / PWA client.
class PayHereNativeService {
  /// Optional override for widget and integration tests.
  @visibleForTesting
  static PayHereTestHandler? testPaymentHandler;

  /// Launches the native PayHere Android/iOS SDK payment flow (or web checkout on Web/PWA).
  static Future<void> startPayment({
    required BuildContext context,
    required Map<String, dynamic> checkoutData,
    required Future<void> Function(String paymentId, String orderId) onSuccess,
    required void Function(String error) onError,
    required void Function() onDismissed,
  }) async {
    final isSandbox =
        checkoutData['sandbox'] == true ||
        checkoutData['sandbox'] == '1' ||
        checkoutData['sandbox'] == 1;

    final orderId = checkoutData['order_id']?.toString() ?? '';
    final amountRaw = checkoutData['amount'];
    final double amount = (amountRaw is num)
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw?.toString() ?? '0') ?? 0.0;

    final Map<String, dynamic> paymentObject = {
      'sandbox': isSandbox,
      'merchant_id': checkoutData['merchant_id']?.toString() ?? '',
      'merchant_secret': checkoutData['merchant_secret']?.toString() ?? '',
      'notify_url': checkoutData['notify_url']?.toString() ?? '',
      'order_id': orderId,
      'items': checkoutData['items']?.toString() ?? "Zein's Pool Reservation",
      'amount': amount,
      'currency': checkoutData['currency']?.toString() ?? 'LKR',
      'first_name': checkoutData['first_name']?.toString() ?? 'Guest',
      'last_name': checkoutData['last_name']?.toString() ?? 'User',
      'email': checkoutData['email']?.toString() ?? 'guest@zeinspool.com',
      'phone': checkoutData['phone']?.toString() ?? '+94770000000',
      'address':
          checkoutData['address']?.toString() ?? "Zein's Pool, Kattankudy",
      'city': checkoutData['city']?.toString() ?? 'Batticaloa',
      'country': checkoutData['country']?.toString() ?? 'Sri Lanka',
      if (checkoutData['custom_1'] != null)
        'custom_1': checkoutData['custom_1'].toString(),
      if (checkoutData['custom_2'] != null)
        'custom_2': checkoutData['custom_2'].toString(),
    };

    debugPrint('PayHere Native SDK Payment Object: $paymentObject');

    if (testPaymentHandler != null) {
      await testPaymentHandler!(
        paymentObject: paymentObject,
        onSuccess: onSuccess,
        onError: onError,
        onDismissed: onDismissed,
      );
      return;
    }

    if (kIsWeb) {
      final webCheckoutUrl = checkoutData['web_checkout_url']?.toString();
      if (webCheckoutUrl != null && webCheckoutUrl.isNotEmpty) {
        final uri = Uri.tryParse(webCheckoutUrl);
        if (uri != null) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (launched && context.mounted) {
            final completed = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Complete Online Payment'),
                content: const Text(
                  'A secure PayHere checkout tab has been opened. Once you finish paying, tap "Verify Payment" below.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Verify Payment'),
                  ),
                ],
              ),
            );
            if (completed == true) {
              await onSuccess(orderId, orderId);
            } else {
              onDismissed();
            }
            return;
          }
        }
      }
      onError('Unable to open PayHere web checkout.');
      return;
    }

    try {
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          debugPrint('PayHere Native SDK Success: $paymentId');
          onSuccess(paymentId, orderId);
        },
        (error) {
          debugPrint('PayHere Native SDK Error: $error');
          onError(error);
        },
        () {
          debugPrint('PayHere Native SDK Dismissed/Canceled');
          onDismissed();
        },
      );
    } catch (e) {
      debugPrint('PayHere Native SDK Exception: $e');
      onError(e.toString());
    }
  }
}
