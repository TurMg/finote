// lib/core/widgets/category_icon_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/icon_resolver.dart';

/// Reusable widget terpusat untuk merender Icon Kategori:
/// 1. Emoji (prefix `emoji:`)
/// 2. Image File (prefix `image:`)
/// 3. Vector Material Icon (default iconName string)
class CategoryIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;
  final double imageBorderRadius;
  final double? width;
  final double? height;
  final bool useFullBox;

  const CategoryIconWidget({
    super.key,
    required this.iconName,
    this.color,
    this.size = 24.0,
    this.imageBorderRadius = 12.0,
    this.width,
    this.height,
    this.useFullBox = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Emoji Icon
    if (iconName.startsWith('emoji:')) {
      final emoji = iconName.substring(6);
      final widget = Text(
        emoji,
        style: TextStyle(
          fontSize: size,
          height: 1.1,
        ),
      );
      return useFullBox ? Center(child: widget) : widget;
    }

    // 2. Custom Image Upload
    if (iconName.startsWith('image:')) {
      final path = iconName.substring(6);
      final file = File(path);
      final targetWidth = useFullBox ? (width ?? double.infinity) : (width ?? size);
      final targetHeight = useFullBox ? (height ?? double.infinity) : (height ?? size);

      if (file.existsSync()) {
        return SizedBox(
          width: targetWidth,
          height: targetHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(imageBorderRadius),
            child: Image.file(
              file,
              width: targetWidth,
              height: targetHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    color: color ?? Colors.grey,
                    size: size,
                  ),
                );
              },
            ),
          ),
        );
      } else {
        final fallback = Icon(
          Icons.broken_image_rounded,
          color: color ?? Colors.grey,
          size: size,
        );
        return useFullBox ? Center(child: fallback) : fallback;
      }
    }

    // 3. Vector Material Icon Bawaan
    final vectorIcon = Icon(
      IconResolver.resolve(iconName),
      color: color,
      size: size,
    );
    return useFullBox ? Center(child: vectorIcon) : vectorIcon;
  }
}
