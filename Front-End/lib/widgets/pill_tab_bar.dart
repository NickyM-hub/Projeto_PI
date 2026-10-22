import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PillTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final Color activeColor;
  final void Function(int) onChanged;

  const PillTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    children: List.generate(labels.length, (i) {
      final active = i == selectedIndex;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              labels[i],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColors.textMuted,
         ),
        ),
       ),
      ),
     );
    }),
   ),
  );
 }
}