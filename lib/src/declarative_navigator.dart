import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';

class DeclarativeNavigatorDisplay extends StatefulWidget {
  const DeclarativeNavigatorDisplay({
    super.key,
    required this.root,
  });

  final DeclarativeNavigatable root;

  @override
  State<DeclarativeNavigatorDisplay> createState() =>
      _DeclarativeNavigatorDisplayState();
}

class _DeclarativeNavigatorDisplayState
    extends State<DeclarativeNavigatorDisplay> {
  late final DeclarativeNavigatorSourceImpl _root;

  @override
  void initState() {
    super.initState();

    _root = DeclarativeNavigatorSourceImpl(widget.root);
  }

  @override
  void didUpdateWidget(covariant DeclarativeNavigatorDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    _root.didUpdateNavigatable(widget.root);
  }

  @override
  Widget build(BuildContext context) {
    // print('decl: bnuilding ${_root.pages}');
    // print('decl: bnuilding ${(_root.pages.last.child as Scaffold).body}');

    return AnimatedBuilder(
      animation: _root,
      builder: (context, _) {
        print(
          '\n\nDeclarativeNavigatorDisplay: Building animated builder ${_root.pages}',
        );

        return _Navigator(
          pages: _root.pages,
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
