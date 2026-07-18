import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/icon_catalog.dart';
import '../../../../core/widgets/forge_card.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';

/// The completion checkbox uses a scale+color pop (via [AnimatedScale] and
/// [AnimatedContainer]) plus [HapticFeedback] instead of a confetti-particle
/// package — enough "delight" for the tracking milestone without a new
/// dependency; a full celebration animation is a polish item for later.
class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.todayStatus,
    required this.onToggleToday,
    required this.onTap,
  });

  final Habit habit;
  final HabitLogStatus? todayStatus;
  final VoidCallback onToggleToday;
  final VoidCallback onTap;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _pressed = false;

  Color get _color {
    final hex = widget.habit.color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _handleToggle() {
    HapticFeedback.mediumImpact();
    setState(() => _pressed = true);
    widget.onToggleToday();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.todayStatus == HabitLogStatus.completed;

    return ForgeCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: widget.habit.emoji != null
                ? Text(widget.habit.emoji!, style: const TextStyle(fontSize: 20))
                : Icon(IconCatalog.resolve(widget.habit.icon), color: _color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.habit.name, style: theme.textTheme.titleMedium),
                if (widget.habit.estimatedTimeMinutes != null)
                  Text('${widget.habit.estimatedTimeMinutes} min', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: _handleToggle,
            child: AnimatedScale(
              scale: _pressed ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? _color : Colors.transparent,
                  border: Border.all(color: isCompleted ? _color : theme.dividerTheme.color!, width: 2),
                ),
                child: isCompleted ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
