import 'package:flutter/material.dart';

class Provider extends InheritedWidget {
  const Provider({
    required super.child,
    required this.children,
    super.key,
  });

  final Iterable<Object> children;

  static T of<T>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<Provider>();
    assert(result != null, 'No Provider found in context');
    return result!.children.firstWhere((e) => e.runtimeType == T) as T;
  }

  @override
  bool updateShouldNotify(Provider oldWidget) => oldWidget.children != children;
}
