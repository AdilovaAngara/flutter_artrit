import 'package:artrit/theme.dart';
import 'package:flutter/material.dart';

class ListTileExpandWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? iconLeading;
  final Color? colorIconTrailing;
  final Color? colorIconLeading;
  final double? shapeParam;
  final Widget? child;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final int currentIndex; // Текущий индекс элемента
  final int itemCount; // Общее количество элементов в списке
  final VoidCallback? onPrevious; // Колбэк для перехода к предыдущему элементу
  final VoidCallback? onNext; // Колбэк для перехода к следующему элементу
  final bool showNavigateIcons;

  const ListTileExpandWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.iconLeading,
    this.colorIconTrailing,
    this.colorIconLeading,
    this.shapeParam,
    this.child,
    this.isExpanded = false,
    this.onExpansionChanged,
    required this.currentIndex,
    required this.itemCount,
    this.onPrevious,
    this.onNext,
    this.showNavigateIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    final double borderRadius = shapeParam ?? 12.0;

    return GestureDetector(
      onTap: () => onExpansionChanged?.call(!isExpanded), // Раскрытие/сворачивание при клике на любую часть
      child: Container(
        decoration: BoxDecoration(
          color: isExpanded ? Colors.purple.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                children: [
                  if (iconLeading != null)
                    Icon(
                      iconLeading!,
                      color: colorIconLeading ?? Colors.grey,
                      size: 35,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: captionMenuTextStyle,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: subtitleTextStyle,
                          ),
                      ],
                    ),
                  ),
                  if (child != null)
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: colorIconTrailing ?? Colors.grey,
                    size: 35,
                  ),
                ],
              ),
            ),
            if (isExpanded && child != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 30.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showNavigateIcons ? IconButton(
                      onPressed: currentIndex > 0 ? onPrevious : null,
                      alignment: Alignment.centerLeft,
                      icon: Icon(
                        Icons.navigate_before,
                        size: 35,
                        color: currentIndex > 0 ? btnColor : Colors.grey.shade200,
                      ),
                    ) : SizedBox(width: 20,),
                    Expanded(
                      child: child!,
                    ),
                    showNavigateIcons ? IconButton(
                      onPressed: currentIndex < itemCount - 1 ? onNext : null,
                      alignment: Alignment.centerRight,
                      icon: Icon(
                        Icons.navigate_next,
                        size: 35,
                        color: currentIndex < itemCount - 1 ? btnColor : Colors.grey.shade200,
                      ),
                    ) : SizedBox(width: 20,),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}