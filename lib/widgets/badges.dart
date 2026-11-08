import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class LevelBadge extends StatelessWidget {
  final String level;
  final bool isSmall;

  const LevelBadge({
    super.key,
    required this.level,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBasic = level.toLowerCase() == 'basic';

    final bg = isBasic
        ? (isDark ? const Color(0xFF1B3320) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF2C1E38) : const Color(0xFFF3E8FA));

    final text = isBasic
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32))
        : (isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2));

    final border = isBasic
        ? (isDark ? const Color(0xFF2D5537) : const Color(0xFFC8E6C9))
        : (isDark ? const Color(0xFF4A315E) : const Color(0xFFE1BEE7));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 7 : 9,
        vertical: isSmall ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBasic ? Icons.check_circle_outline : Icons.star_rounded,
            size: isSmall ? 10 : 12,
            color: text,
          ),
          const SizedBox(width: 3),
          Text(
            level,
            style: TextStyle(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class PartOfSpeechBadge extends StatelessWidget {
  final String partOfSpeech;
  final bool isSmall;

  const PartOfSpeechBadge({
    super.key,
    required this.partOfSpeech,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pos = partOfSpeech.toLowerCase();

    Color bg;
    Color text;
    Color border;

    if (pos.contains('verb')) {
      bg = isDark ? const Color(0xFF162B40) : const Color(0xFFEBF2FA);
      text = isDark ? const Color(0xFF74AAF1) : const Color(0xFF1D5A9B);
      border = isDark ? const Color(0xFF234466) : const Color(0xFFC9DEF6);
    } else if (pos.contains('adj')) {
      bg = isDark ? const Color(0xFF2E1F3B) : const Color(0xFFF3E8FA);
      text = isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2);
      border = isDark ? const Color(0xFF4C3362) : const Color(0xFFE1BEE7);
    } else {
      // idiom, noun, other -> lush mint
      bg = isDark ? const Color(0xFF173527) : const Color(0xFFE8F6EE);
      text = isDark ? const Color(0xFF5EEAD4) : AppColors.lushPrimary;
      border = isDark ? const Color(0xFF26543E) : AppColors.lushPrimaryBorder;
    }

    // Format like IDIOM, VERB, ADJ
    String display = partOfSpeech.toUpperCase();
    if (display == 'ADJECTIVE') display = 'ADJ';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 7 : 9,
        vertical: isSmall ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: isSmall ? 10 : 11,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class UsageBadge extends StatelessWidget {
  final String usage;
  final bool isSmall;

  const UsageBadge({
    super.key,
    required this.usage,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22352B) : const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2F4A3C) : const Color(0xFFE4EDE7),
          width: 0.8,
        ),
      ),
      child: Text(
        usage,
        style: TextStyle(
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFA6BAAF) : const Color(0xFF4A5C52),
        ),
      ),
    );
  }
}

class TopicBadge extends StatelessWidget {
  final String topic;
  final bool isSmall;

  const TopicBadge({
    super.key,
    required this.topic,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF22352B) : const Color(0xFFF1F5F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        topic,
        style: TextStyle(
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFFA6BAAF) : const Color(0xFF5D6F66),
        ),
      ),
    );
  }
}
