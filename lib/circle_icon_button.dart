import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  final IconData iconData;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? padding;
  final Color? iconColor;

  const CircleIconButton({
    super.key,
    required this.iconData,
    this.color,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      elevation: elevation ?? 1.5,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.5),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: EdgeInsets.all(padding ?? 16.0),
          child: Icon(
            iconData,
            color: (onTap == null && onLongPress == null)
              ? iconColor?.withValues(alpha: 0.5) ?? Colors.grey
              : iconColor,
          ),
        ),
      ),
    );
  }
}
