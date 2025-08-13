import 'package:flutter/material.dart';

class MaterialTextField extends StatelessWidget {
  final String labelText;
  final Function(String) onChanged;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final double? cornerRadius;
  final TextInputType? keyboardType;
  final bool? autofocus;

  const MaterialTextField({
    super.key,
    required this.labelText,
    required this.onChanged,
    this.color,
    this.shadowColor,
    this.elevation,
    this.cornerRadius,
    this.keyboardType,
    this.autofocus,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(cornerRadius ?? 12.0),
      elevation: elevation ?? 2.5,
      shadowColor: shadowColor ?? Theme.of(context).colorScheme.shadow.withValues(alpha: 0.5),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(cornerRadius ?? 12.0),
          ),
        ),
        onChanged: onChanged,
        autofocus: autofocus ?? false,
      ),
    );
  }
}