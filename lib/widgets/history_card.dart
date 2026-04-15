import 'package:flutter/material.dart';
import '../model/medication.dart';

class HistoryCard extends StatelessWidget {
  final Medication medication;
  final MedicationSchedule schedule;
  final bool isPast;

  static const _primaryPurple = Color(0xFF7C5CBF);
  static const _lightPurple = Color(0xFFEAE4F7);
  static const _darkPurple = Color(0xFF2D1B5E);

  const HistoryCard({
    super.key,
    required this.medication,
    required this.schedule,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = schedule.status == MedicationStatus.taken;
    final isPending = schedule.status == MedicationStatus.pending;

    final Color borderColor;
    final Color iconBg;
    final Color iconColor;
    final Color badgeBg;
    final Color badgeText;
    final String badgeLabel;
    final IconData statusIcon;

    if (isPast) {
      if (isTaken) {
        borderColor = const Color(0xFFE8F5E9);
        iconBg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF2E7D32);
        badgeBg = const Color(0xFFE8F5E9);
        badgeText = const Color(0xFF2E7D32);
        badgeLabel = 'Tomado';
        statusIcon = Icons.check_rounded;
      } else {
        borderColor = const Color(0xFFFFEBEE);
        iconBg = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFC62828);
        badgeBg = const Color(0xFFFFEBEE);
        badgeText = const Color(0xFFC62828);
        badgeLabel = 'Perdido';
        statusIcon = Icons.close_rounded;
      }
    } else if (isTaken) {
      borderColor = const Color(0xFFE8F5E9);
      iconBg = const Color(0xFFE8F5E9);
      iconColor = const Color(0xFF2E7D32);
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = const Color(0xFF2E7D32);
      badgeLabel = 'Tomado';
      statusIcon = Icons.check_rounded;
    } else if (isPending) {
      borderColor = const Color(0xFFFFE0B2);
      iconBg = const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFE65100);
      badgeBg = const Color(0xFFFFF3E0);
      badgeText = const Color(0xFFE65100);
      badgeLabel = 'Pendente';
      statusIcon = Icons.access_time_rounded;
    } else {
      borderColor = _lightPurple;
      iconBg = _lightPurple;
      iconColor = _primaryPurple;
      badgeBg = const Color(0xFFF3F0FA);
      badgeText = _primaryPurple;
      badgeLabel = 'Agendado';
      statusIcon = Icons.schedule_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _darkPurple,
                  ),
                ),
                Text(
                  medication.dosage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A7AAA),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _lightPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  schedule.scheduledTime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
