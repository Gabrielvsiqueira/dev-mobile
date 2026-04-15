import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';

enum AppTab { home, calendar, profile }

class AppBottomNav extends StatelessWidget {
  final AppTab activeTab;

  const AppBottomNav({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAE4F7), width: 1.5)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 24,
        right: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Início',
            isActive: activeTab == AppTab.home,
            onTap: () => context.go(AppRoutes.home),
          ),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Calendário',
            isActive: activeTab == AppTab.calendar,
            onTap: () => context.go(AppRoutes.calendar),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            isActive: activeTab == AppTab.profile,
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const _primaryPurple = Color(0xFF7C5CBF);

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? _primaryPurple : const Color(0xFFBFA8EE),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isActive ? _primaryPurple : const Color(0xFFBFA8EE),
            ),
          ),
        ],
      ),
    );
  }
}
