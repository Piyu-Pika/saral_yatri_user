import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;
  final bool enabled;
  final String? helperText;
  final double borderRadius;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.label,
    this.value,
    this.hintText,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.helperText,
    this.borderRadius = 12.0,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: _isFocused ? 14 : 13,
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
              color: _hasError
                  ? AppTheme.errorColor
                  : _isFocused
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: widget.enabled ? widget.onChanged : null,
            validator: (value) {
              final result = widget.validator?.call(value);
              setState(() {
                _hasError = result != null;
              });
              return result;
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Container(
                      margin: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: const BorderSide(
                  color: AppTheme.errorColor,
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                borderSide: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: widget.enabled
                  ? (_isFocused ? Colors.white : Colors.grey[50])
                  : Colors.grey[100],
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.prefixIcon != null ? 8 : 16,
                vertical: 14,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppTheme.textPrimary,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textSecondary,
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.helperText!,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}