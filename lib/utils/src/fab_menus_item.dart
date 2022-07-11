import 'package:flutter/material.dart';

/// Provides data for the menu child
class FabMenuItem {
  /// Item menu child onTap function.
  final VoidCallback? onTap;

  /// Title of the item menu child.
  final String? title;

  /// Text Style of the menu child item.
  final TextStyle? style;

  /// Provides data for the menu child.
  FabMenuItem({
    this.title,
    this.style,
    this.onTap,
  });
}