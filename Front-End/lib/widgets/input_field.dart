import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class InputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextInputType keyboardType;
  final String? errorText;
  final bool hasError;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function()? onEditingComplete;

  const InputField({
    super.key,
    required this.label,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.hasError = false,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          onChanged: onChanged,
          onTap: onTap,
          onEditingComplete: onEditingComplete,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.border,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ),
      ],
    );
  }
}