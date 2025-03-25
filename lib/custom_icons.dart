import 'package:flutter/material.dart';

class MaterialSymbolsTheme extends InheritedWidget {
  final double weight;
  final double fill;
  final double grade;
  final double opticalSize;

  const MaterialSymbolsTheme({
    super.key,
    required super.child,
    this.weight = 600,
    this.fill = 0,
    this.grade = 0,
    this.opticalSize = 48,
  });

  static MaterialSymbolsTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MaterialSymbolsTheme>()!;
  }

  @override
  bool updateShouldNotify(MaterialSymbolsTheme oldWidget) {
    return weight != oldWidget.weight ||
        fill != oldWidget.fill ||
        grade != oldWidget.grade ||
        opticalSize != oldWidget.opticalSize;
  }
}

class ThemedIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const ThemedIcon(this.icon, {super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    final theme = MaterialSymbolsTheme.of(context);

    return Icon(
      icon,
      color: color,
      size: size,
      weight: theme.weight,
      fill: theme.fill,
      grade: theme.grade,
      opticalSize: theme.opticalSize,
    );
  }
}
