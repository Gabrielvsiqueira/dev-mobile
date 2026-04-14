import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/medication.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/medication_wizard_page.dart';
import '../pages/calendar_page.dart';
import '../pages/profile_page.dart';
import '../pages/alarm_page.dart';
import '../pages/emergency_page.dart';

class AppRoutes {
  AppRoutes._();

  static const login = '/';
  static const home = '/home';
  static const wizardAdd = '/medication/add';
  static const wizardEdit = '/medication/edit';
  static const calendar = '/calendar';
  static const profile = '/profile';
  static const alarm = '/alarm';
  static const emergency = '/emergency';
}

class AppSession {
  AppSession._();
  static String userName = '';
}

class AlarmArgs {
  final Medication medication;
  final MedicationSchedule schedule;
  const AlarmArgs({required this.medication, required this.schedule});
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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: HomePage(userName: AppSession.userName),
        transitionsBuilder: _fadeTransition,
        transitionDuration: const Duration(milliseconds: 350),
      ),
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
    GoRoute(
      path: AppRoutes.calendar,
      name: 'calendar',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CalendarPage(),
        transitionsBuilder: _fadeTransition,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ProfilePage(userName: AppSession.userName),
        transitionsBuilder: _fadeTransition,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ),
    GoRoute(
      path: AppRoutes.alarm,
      name: 'alarm',
      pageBuilder: (context, state) {
        final args = state.extra as AlarmArgs;
        return CustomTransitionPage(
          key: state.pageKey,
          child: AlarmPage(
            medication: args.medication,
            schedule: args.schedule,
          ),
          transitionsBuilder: _fadeTransition,
          transitionDuration: const Duration(milliseconds: 250),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.emergency,
      name: 'emergency',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const EmergencyPage(),
        transitionsBuilder: _slideTransition,
        transitionDuration: const Duration(milliseconds: 350),
      ),
    ),
  ],
);

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) => FadeTransition(opacity: animation, child: child);

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
