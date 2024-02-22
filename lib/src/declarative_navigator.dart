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

        return Navigator(
          pages: pages,
          onPopPage: (route, result) {
            return route.didPop(result);
          },
        );
      },
    );
  }
}
