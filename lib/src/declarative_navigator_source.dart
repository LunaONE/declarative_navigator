import 'package:flutter/material.dart';

abstract class DeclarativeNavigatorSource extends ChangeNotifier {
  List<DeclarativePage> build();

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

class DeclarativePage extends Page<dynamic> {
  DeclarativePage({
    super.key,
    required this.child,
    required VoidCallback? pop,
    this.maintainState = true,
  }) {
    if (pop != null) {
      var popCalled = false;
      this.pop = () {
        assert(!popCalled, '`pop` should only be called once per page');

        if (popCalled) {
          return;
        }

        popCalled = true;
        pop();
      };
    } else {
      this.pop = null;
    }
  }

  final Widget child;

  // TODO(tp): Alternatively support `ValueListenable<VoidCallback?>`, so this can be updated at runtime
  //           Though should this be settable from the outside or by the page itself (builder pattern)?
  //           Would be cool if this could be declaratively changed from the outside after the initial render.
  late final VoidCallback? pop;

  final bool maintainState;

  @override
  Route createRoute(BuildContext context) {
    return DeclarativeRoute(this);
  }

  @override
  String toString() {
    return 'DeclarativePage(child: $child, pop: $pop)';
  }
}

class DeclarativeRoute extends PageRoute<dynamic>
    with MaterialRouteTransitionMixin {
  @visibleForTesting
  DeclarativeRoute(DeclarativePage page)
      : super(
          // The page is stored in place of the route settings, which is a) required by the declarative Navigator 2.0 `pages`,
          // as well as needed to update the page with a new child in case of "in place" updates
          settings: page,
        );

  bool _popInvoked = false;

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
  bool get fullscreenDialog => !canPop;

  @override
  bool get canPop {
    return pop != null;
  }

  @override
  bool didPop(dynamic result) {
    if (!_popInvoked) {
      // If pop was already invoked, the state will already be updated and we must not call `pop` again
      pop?.call();
    }

    return super.didPop(result);
  }

  @override
  bool get maintainState => page.maintainState;

  @override
  bool get impliesAppBarDismissal => canPop;

  @override
  Widget buildContent(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) {
          _popInvoked = true;
        }
      },
      child: page.child,
    );
  }
}
