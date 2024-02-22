import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/widgets.dart';

/// Navigator that renders zero or more pages plus an optional child navigator
/// taking over the rendering of further pages
abstract class SingleChildNavigator extends DeclarativeNavigatorSource {
  @protected
  NavigatorDescription describe();

  @protected
  ({
    ChildNavigatorDescription desc,
    DeclarativeNavigatorSource instance
  })? childNavigator;

  @override
  List<DeclarativePage> build() {
    final description = describe();

    final childDesc = description.child;
    if (childDesc != childNavigator?.desc) {
      if (childNavigator != null) {
        childNavigator!.instance.removeListener(notifyListeners);
        childNavigator!.instance.dispose();
        childNavigator = null;
      }

      if (childDesc != null) {
        childNavigator = (desc: childDesc, instance: childDesc.factory());
        childNavigator!.instance.addListener(notifyListeners);
      }
    }

    return [
      ...description.pages,
      ...?childNavigator?.instance.build(),
    ];
  }

  @protected
  NavigatorDescription pages(final Iterable<DeclarativePage> pages) {
    return NavigatorDescription(pages.toList());
  }

  @protected
  NavigatorDescription pagesWithChild<T extends DeclarativeNavigatorSource>(
    final Iterable<DeclarativePage> pages, [
    final T Function()? childFactory,
    final List<Object?> parameters = const [],
  ]) {
    assert(childFactory != null || parameters.isEmpty);

    return NavigatorDescription(
      pages.toList(),
      childFactory != null
          ? ChildNavigatorDescription(childFactory, parameters)
          : null,
    );
  }

  @protected
  NavigatorDescription child<T extends DeclarativeNavigatorSource>(
    final T Function() childFactory, [
    final List<Object?> parameters = const [],
  ]) {
    return NavigatorDescription(
      const [],
      ChildNavigatorDescription(childFactory, parameters),
    );
  }

  @override
  void dispose() {
    childNavigator?.instance.removeListener(notifyListeners);
    childNavigator?.instance.dispose();

    super.dispose();
  }
}

class NavigatorDescription {
  final List<DeclarativePage> pages;

  final ChildNavigatorDescription? child;

  NavigatorDescription(this.pages, [this.child]);
}

class ChildNavigatorDescription<T extends DeclarativeNavigatorSource> {
  final T Function() factory;

  final List<Object?> parameters;

  ChildNavigatorDescription(
    this.factory, [
    /// Parameters must implement `==`
    /// If parameters differs from the previous, a new navigator instance will be created
    this.parameters = const [],
  ]);

  @override
  int get hashCode => parameters.hashCode;

  @override
  bool operator ==(dynamic other) {
    return (other is ChildNavigatorDescription &&
        other.factory.runtimeType == factory.runtimeType &&
        other.parameters.length == parameters.length &&
        other.parameters.indexed
            .every((entry) => parameters[entry.$1] == entry.$2));
  }
}
