import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Renders the PayHere payment gateway natively inside an in-app secure modal sheet.
/// Eliminates external browser redirection and coordinates strict transaction callbacks.
class PayHereInAppCheckoutModal extends StatefulWidget {
  const PayHereInAppCheckoutModal({
    super.key,
    required this.checkoutUrl,
    required this.orderId,
    required this.bookingId,
    required this.onPayHereSuccess,
    required this.onPayHereError,
    required this.onPayHereCanceled,
  });

  final String checkoutUrl;
  final String orderId;
  final String bookingId;
  final Future<void> Function(String paymentId, String orderId)
  onPayHereSuccess;
  final void Function(String error) onPayHereError;
  final void Function() onPayHereCanceled;

  /// Helper to launch the in-app PayHere checkout bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String checkoutUrl,
    required String orderId,
    required String bookingId,
    required Future<void> Function(String paymentId, String orderId)
    onPayHereSuccess,
    required void Function(String error) onPayHereError,
    required void Function() onPayHereCanceled,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PayHereInAppCheckoutModal(
        checkoutUrl: checkoutUrl,
        orderId: orderId,
        bookingId: bookingId,
        onPayHereSuccess: onPayHereSuccess,
        onPayHereError: onPayHereError,
        onPayHereCanceled: onPayHereCanceled,
      ),
    );
  }

  @override
  State<PayHereInAppCheckoutModal> createState() =>
      _PayHereInAppCheckoutModalState();
}

class _PayHereInAppCheckoutModalState extends State<PayHereInAppCheckoutModal> {
  late final WebViewController _controller;
  double _loadProgress = 0.0;
  bool _isLoading = true;
  String? _webError;
  bool _hasTriggeredCallback = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadProgress = progress / 100.0;
                if (progress >= 100) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _webError = null;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true) {
              return;
            }

            final errorUrl = error.url ?? '';
            if (errorUrl.contains('/payhere/return') ||
                errorUrl.contains('/payhere/cancel')) {
              return;
            }

            if (error.description.contains('ERR_BLOCKED_BY_ORB')) {
              return;
            }

            if (mounted && _isLoading) {
              setState(() {
                _webError = error.description;
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final uri = Uri.parse(url);

            if (url.contains('/customer/payhere/return') ||
                url.contains('/payhere/return')) {
              if (!_hasTriggeredCallback) {
                _hasTriggeredCallback = true;
                final paymentId =
                    uri.queryParameters['payment_id'] ??
                    uri.queryParameters['order_id'] ??
                    widget.orderId;
                final orderId =
                    uri.queryParameters['order_id'] ?? widget.orderId;

                Navigator.of(context).pop();
                widget.onPayHereSuccess(paymentId, orderId);
              }
              return NavigationDecision.prevent;
            }

            if (url.contains('/customer/payhere/cancel') ||
                url.contains('/payhere/cancel')) {
              if (!_hasTriggeredCallback) {
                _hasTriggeredCallback = true;
                Navigator.of(context).pop();
                widget.onPayHereCanceled();
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<bool> _handleCloseAttempt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Payment?',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Your booking reservation will remain saved, but payment will not be marked as completed. You can finish payment anytime from your booking details.',
          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Continue Payment',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel & Close',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      if (!_hasTriggeredCallback) {
        _hasTriggeredCallback = true;
        Navigator.of(context).pop();
        widget.onPayHereCanceled();
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleCloseAttempt();
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: screenHeight * 0.92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.98),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepNavy.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Frosted Drag handle
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: 4),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),

                // Top Glass Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PayHere In-App Checkout',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '256-Bit SSL Encrypted Payment Gateway',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        color: AppColors.textSecondary,
                        onPressed: _handleCloseAttempt,
                      ),
                    ],
                  ),
                ),

                // Progress bar
                if (_isLoading && _loadProgress < 1.0)
                  LinearProgressIndicator(
                    value: _loadProgress,
                    backgroundColor: AppColors.surfaceMuted,
                    color: AppColors.cyanAqua,
                    minHeight: 3,
                  )
                else
                  Divider(height: 1, color: AppColors.glassBorderSubtle),

                // WebView or Error State
                Expanded(
                  child: _webError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 48,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'Unable to load PayHere gateway',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _webError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.onPayHereCanceled();
                                      },
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(fontFamily: 'Nunito'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _webError = null;
                                          _isLoading = true;
                                        });
                                        _controller.reload();
                                      },
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(fontFamily: 'Nunito'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            WebViewWidget(controller: _controller),
                            if (_isLoading)
                              Container(
                                color: Colors.white,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                      SizedBox(height: AppSpacing.md),
                                      Text(
                                        'Connecting to PayHere...',
                                        style: TextStyle(
                                          fontFamily: 'Nunito',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
