import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/bookings/presentation/screens/booking_availability_screen.dart';
import '../features/bookings/presentation/screens/booking_checkout_screen.dart';
import '../features/bookings/presentation/screens/booking_details_screen.dart';
import '../features/bookings/presentation/screens/booking_payment_screen.dart';
import '../features/bookings/presentation/screens/booking_success_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/services/presentation/screens/home_screen.dart';
import '../features/services/presentation/screens/service_details_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'presentation/screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return LoginScreen(redirectTo: redirect);
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/bookings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MyBookingsScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    GoRoute(path: '/resort', redirect: (context, state) => '/home'),
    GoRoute(
      path: '/services/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ServiceDetailsScreen(serviceId: id);
      },
    ),
    GoRoute(
      path: '/services/:id/book',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BookingAvailabilityScreen(serviceId: id);
      },
    ),
    GoRoute(
      path: '/services/:id/checkout',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BookingCheckoutScreen(serviceId: id);
      },
    ),
    GoRoute(
      path: '/bookings/success/:bookingId',
      builder: (context, state) {
        final id = state.pathParameters['bookingId'] ?? '';
        return BookingSuccessScreen(bookingId: id);
      },
    ),
    GoRoute(
      path: '/bookings/:bookingId',
      builder: (context, state) {
        final id = state.pathParameters['bookingId'] ?? '';
        return BookingDetailsScreen(bookingId: id);
      },
    ),
    GoRoute(
      path: '/bookings/:bookingId/pay',
      builder: (context, state) {
        final id = state.pathParameters['bookingId'] ?? '';
        final method = state.uri.queryParameters['method'];
        final isCancelled = state.uri.queryParameters['cancelled'] == 'true';
        return BookingPaymentScreen(
          bookingId: id,
          initialMethod: method,
          isCancelled: isCancelled,
        );
      },
    ),
  ],
);
