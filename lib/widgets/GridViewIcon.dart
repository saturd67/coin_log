import 'package:flutter/material.dart';

class GridViewIcon extends StatelessWidget {
  final Icon? icon;

  GridViewIcon ({
    super.key,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.tertiary
      ),
      child: icon ?? Icon(Icons.picture_in_picture),
    );
  }
}