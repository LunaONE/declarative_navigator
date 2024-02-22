import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/widgets.dart';

class DeclarativeNavigatorDisplay extends StatelessWidget {
  const DeclarativeNavigatorDisplay({
    super.key,
    required this.root,
  });

  final DeclarativeNavigatorSource root;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: root,
      builder: (context, _) {
        final pages = root.build();

        return _Navigator(
          pages: pages,
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }
}

class _Navigator extends Navigator {
  const _Navigator({
    required super.pages,
    required super.onPopPage,
  });

  @override
  _NavigatorState createState() => _NavigatorState();
}

class _NavigatorState extends NavigatorState {
  @override
  void pop<T extends Object?>([T? result]) {
    late final Route currentRoute;
    // workaround to get the current route
    popUntil((route) {
      currentRoute = route;
      return true;
    });

    if (currentRoute is DeclarativeRoute &&
        !(currentRoute as DeclarativeRoute).canPop) {
      throw Exception(
        'Do not use `Navigator.pop` on a modal declarative route, as that does not update the state (as the route is not supposed to be dismissed currently)',
      );
    }

    super.pop(result);
  }
}
