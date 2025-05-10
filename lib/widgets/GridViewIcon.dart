import 'package:flutter/material.dart';

class GridViewIcon extends StatelessWidget {
  final IconData? iconData;
  final double? containerSize;
  final double? iconSize;
  final bool? isSelected;

  GridViewIcon ({
    super.key,
    this.iconData,
    this.containerSize,
    this.iconSize,
    this.isSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize ?? 45,
      height: containerSize ?? 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected != null && isSelected! ? Theme.of(context).colorScheme.primary :  Theme.of(context).colorScheme.tertiary
      ),
      child: iconData != null ? Icon(iconData, color: isSelected != null && isSelected! ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color, size: iconSize ?? Theme.of(context).iconTheme.size) : Icon(Icons.picture_in_picture, size: iconSize ?? Theme.of(context).iconTheme.size),
    );
  }
}