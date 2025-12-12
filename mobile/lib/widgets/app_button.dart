import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable button widget matching web frontend design
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = variant == ButtonVariant.primary
        ? AppTheme.primary
        : variant == ButtonVariant.secondary
            ? AppTheme.secondary
            : Colors.transparent;

    final foregroundColor = variant == ButtonVariant.outline
        ? AppTheme.primary
        : Colors.white;

    final border = variant == ButtonVariant.outline
        ? BorderSide(color: AppTheme.primary, width: 1)
        : null;

    final height = size == ButtonSize.small
        ? 36.0
        : size == ButtonSize.large
            ? 48.0
            : 40.0;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: border,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size == ButtonSize.small ? 16 : 24,
            vertical: size == ButtonSize.large ? 14 : 12,
          ),
          elevation: variant == ButtonVariant.outline ? 0 : 1,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: size == ButtonSize.small ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

enum ButtonVariant { primary, secondary, outline }
enum ButtonSize { small, medium, large }
