import 'package:flutter/material.dart';
import '../model/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final MedicationSchedule schedule;
  final VoidCallback onTap;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _darkPurple = Color(0xFF2D1B5E);

  const MedicationCard({
    super.key,
    required this.medication,
    required this.schedule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(schedule.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: config.borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: config.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.medication_rounded,
                color: config.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _darkPurple,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    medication.dosage,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8A7AAA),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: config.timeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.scheduledTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: config.timeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: config.badgeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: config.badgeText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(MedicationStatus status) {
    switch (status) {
      case MedicationStatus.taken:
        return _StatusConfig(
          label: 'Tomado',
          borderColor: const Color(0xFFEAE4F7),
          iconBg: const Color(0xFFEAE4F7),
          iconColor: _primaryPurple,
          timeBg: const Color(0xFFEAE4F7),
          timeColor: _primaryPurple,
          badgeBg: const Color(0xFFE8F5E9),
          badgeText: const Color(0xFF2E7D32),
        );
      case MedicationStatus.pending:
        return _StatusConfig(
          label: 'Pendente',
          borderColor: const Color(0xFFFFE0B2),
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE65100),
          timeBg: const Color(0xFFFFF3E0),
          timeColor: const Color(0xFFE65100),
          badgeBg: const Color(0xFFFFF3E0),
          badgeText: const Color(0xFFE65100),
        );
      case MedicationStatus.upcoming:
        return _StatusConfig(
          label: 'Mais tarde',
          borderColor: const Color(0xFFEAE4F7),
          iconBg: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF2E7D32),
          timeBg: const Color(0xFFEAE4F7),
          timeColor: _primaryPurple,
          badgeBg: const Color(0xFFF3F0FA),
          badgeText: _primaryPurple,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color borderColor;
  final Color iconBg;
  final Color iconColor;
  final Color timeBg;
  final Color timeColor;
  final Color badgeBg;
  final Color badgeText;

  const _StatusConfig({
    required this.label,
    required this.borderColor,
    required this.iconBg,
    required this.iconColor,
    required this.timeBg,
    required this.timeColor,
    required this.badgeBg,
    required this.badgeText,
  });
}
