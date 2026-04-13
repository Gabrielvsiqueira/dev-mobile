import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/medication_wizard_page.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/';
  static const home = '/home';
  static const wizardAdd = '/medication/add';
  static const wizardEdit = '/medication/edit';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginPage(),
        transitionsBuilder: _fadeTransition,
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ),

    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      pageBuilder: (context, state) {
        final userName = state.extra as String? ?? 'Nenê';
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomePage(userName: userName),
          transitionsBuilder: _fadeTransition,
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.wizardAdd,
      name: 'wizard-add',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const MedicationWizardPage(),
        transitionsBuilder: _slideTransition,
        transitionDuration: const Duration(milliseconds: 380),
      ),
    ),

    GoRoute(
      path: AppRoutes.wizardEdit,
      name: 'wizard-edit',
      pageBuilder: (context, state) {
        final medication = state.extra as Medication;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MedicationWizardPage(medication: medication),
          transitionsBuilder: _slideTransition,
          transitionDuration: const Duration(milliseconds: 380),
        );
      },
    ),
  ],
);

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));
  return SlideTransition(position: animation.drive(tween), child: child);
}
