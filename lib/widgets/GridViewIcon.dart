import 'package:flutter/material.dart';

class GridViewIcon extends StatelessWidget {
  final IconData? iconData;
  final bool? isSelected;

  GridViewIcon ({
    super.key,
    this.iconData,
    this.isSelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected != null && isSelected! ? Theme.of(context).colorScheme.primary :  Theme.of(context).colorScheme.tertiary
      ),
      child: iconData != null ? Icon(iconData, color: isSelected != null && isSelected! ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color) : Icon(Icons.picture_in_picture),
    );
  }
}