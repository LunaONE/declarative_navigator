import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class DeclarativeNavigatorSource extends ChangeNotifier {
  List<DeclarativePage> build();

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

class DeclarativePage extends Page<dynamic> {
  const DeclarativePage({
    super.key,
    required this.child,
    required this.pop,
  });

  final Widget child;

  // TODO(tp): Alternatively support `ValueListenable<VoidCallback?>`, so this can be updated at runtime
  //           Though should this be settable from the outside or by the page itself (builder pattern)?
  //           Would be cool if this could be declaratively changed from the outside after the initial render.
  final VoidCallback? pop;

  @override
  Route createRoute(BuildContext context) {
    return DeclarativeRoute(this);
  }

  @override
  String toString() {
    return 'DeclarativePage(child: $child, pop: $pop)';
  }
}

class DeclarativeRoute extends PageRoute<dynamic> {
  @visibleForTesting
  DeclarativeRoute(DeclarativePage page)
      : super(
          // The page is stored in place of the route settings, which is a) required by the declarative Navigator 2.0 `pages`,
          // as well as needed to update the page with a new child in case of "in place" updates
          settings: page,
        );

  DeclarativePage get page => settings as DeclarativePage;

  Widget get child => page.child;

  /// `pop` method to hide the route
  ///
  /// If present this must modify the state in such a way that the route will not be visible on the next render
  /// If `null` this will block the page from being popped "by itself", e.g. from an edge swipe or Android back button
  VoidCallback? get pop => page.pop;

  // If `true` (thus `pop` is `null`) this tells the system to not allow edge swipe/Android back button
  // TODO(tp): Check the animation: Is this always from the bottom then, and could we block the popping without changing the style?
  @override
  bool get fullscreenDialog {
    return !canPop;
  }

  @override
  bool get canPop {
    return pop != null;
  }

  @override
  Future<RoutePopDisposition> willPop() async {
    return canPop ? RoutePopDisposition.pop : RoutePopDisposition.doNotPop;
  }

  @override
  // NOTE(tp): This is called when the route has been popped by the "system", e.g. iOS edge swipe or Android back button
  bool didPop(dynamic result) {
    pop!.call();

    return super.didPop(result);
  }

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;
}
