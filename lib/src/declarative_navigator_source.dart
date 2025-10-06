import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';

abstract class DeclarativeNavigatorSource extends ChangeNotifier {
  List<DeclarativePage> get pages;

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }
}

class DeclarativeNavigatorSourceImpl extends ChangeNotifier
    implements DeclarativeNavigatorSource {
  DeclarativeNavigatorSourceImpl(DeclarativeNavigatable root) {
    _manager = _NavigatableElementManager(root, notifyListeners);
  }

  late final _NavigatableElementManager _manager;

  void didUpdateNavigatable(DeclarativeNavigatable root) {
    print('DeclarativeNavigatorSourceImpl.didUpdateNavigatable $root');

    _manager.didUpdateNavigatable(root);
  }

  @override
  List<DeclarativePage> get pages {
    print('manager pages: ${_manager.pages}');

    return _manager.pages;
  }

  @override
  @mustCallSuper
  void dispose() {
    _manager.dispose();

    super.dispose();
  }
}

typedef ManagerState = ({
  DeclarativeNavigatable root,
  NavigatorElement? rootElement, // `null` if not needed
  List<DeclarativePage> pages,

  /// `null` is used for empty / non-stateful slots
  List<(DeclarativeNavigatable, _NavigatableElementManager)?> childElements,
});

class _NavigatableElementManager {
  final VoidCallback onChange;

  _NavigatableElementManager(
    DeclarativeNavigatable root,
    this.onChange,
  ) {
    _updateState(root);
  }

  /// This is updated in its entirety through [_updateState]
  ManagerState? currentState;

  List<DeclarativePage> get pages => currentState!.pages;

  void update(ElementDeclarativeNavigatable root) {
    _updateState(root);
  }

  void _updateState(DeclarativeNavigatable root) {
    final oldState = currentState;

    currentState = buildNextState(
      root,
      oldState,
      () {
        _updateState(root);

        onChange();
      },
    );

    print('currentState');
    print(currentState!.root);
    print(currentState!.rootElement);
  }

  void dispose() {
    currentState!.dispose();
  }

  void didUpdateNavigatable(DeclarativeNavigatable root) {
    print('IMPL didUpdateNavigatable $root');

    _updateState(root);

    // onChange();

    // TODO: Notify change?
  }

  /// Creates the new state for the given [root]
  ///
  /// Consumes the [previousState] and disposes all elements which are not longer being used (just as it creates new ones where needed).
  @visibleForTesting
  static ManagerState buildNextState(
    DeclarativeNavigatable root,
    ManagerState? previousState,
    VoidCallback onChange,
  ) {
    // final List<DeclarativePage> pages;
    switch (root) {
      case PageDeclarativeNavigatable():
        return (
          root: root,
          rootElement: null,
          pages: [root.build()],
          childElements: [],
        );

      case ElementDeclarativeNavigatable():

        /// Clean up all previous elements if the root type changes
        if (previousState != null &&
            root.runtimeType != previousState.root.runtimeType) {
          previousState.rootElement?.dispose();

          for (final child in previousState.childElements) {
            child?.$2.dispose();
          }
        }

        final NavigatorElement rootElement;
        if (root.runtimeType == previousState?.root.runtimeType) {
          rootElement = previousState!.rootElement!;
          rootElement.update(root);
        } else {
          rootElement = root.createElement();

          if (rootElement is StatefulNavigatorElement) {
            // TODO: protected member…
            // ignore: invalid_use_of_protected_member
            final state = (root as StatefulNavigator).createState()
              ..navigator = root
              ..element = rootElement;

            rootElement.state = state;
          }

          rootElement.addListener(onChange);
        }

        final childNavigatables = rootElement.build();

        final pages = <DeclarativePage>[];
        final childElements = List<
            (
              ElementDeclarativeNavigatable,
              _NavigatableElementManager
            )?>.filled(childNavigatables.length, null);
        for (final (index, child) in childNavigatables.indexed) {
          final previousElement = previousState != null &&
                  previousState.childElements.length > index
              ? previousState.childElements[index]
              : null;

          switch (child) {
            case PageDeclarativeNavigatable():
              previousElement?.$2.dispose();
              pages.add(child.build());

            case ElementDeclarativeNavigatable():
              if (child.runtimeType == previousElement?.$1.runtimeType) {
                previousElement!.$2.didUpdateNavigatable(child);

                childElements[index] = (child, previousElement.$2);
                pages.addAll(previousElement.$2.pages);
              } else {
                previousElement?.$2.dispose();

                // This stateless manager is not preserver, rather the whole thing gets rebuild
                // TODO: ^^ this seems problematic if inside the stateless navigator some children want to retain state / be stateful, right?
                final newManager = _NavigatableElementManager(
                  child,
                  onChange, // TODO: Connect
                );

                childElements[index] = (child, newManager);

                pages.addAll(newManager.pages);
              }
          }
        }

        /// Clean up trailing unused elements
        if (previousState != null &&
            childNavigatables.length < previousState.childElements.length) {
          for (final childElement
              in previousState.childElements.skip(childNavigatables.length)) {
            childElement?.$2.dispose();
          }
        }

        return (
          root: root,
          rootElement: rootElement,
          pages: pages,
          childElements: childElements,
        );
    }
  }
}

class DeclarativePage extends Page<dynamic>
    implements PageDeclarativeNavigatable {
  DeclarativePage({
    super.key,
    required this.child,
    required VoidCallback? pop,
    this.maintainState = true,
    super.name,
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

  @override
  DeclarativePage build() {
    return this;
  }
}

class DeclarativeRoute extends PageRoute<Object?>
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

extension on ManagerState {
  /// Disposes all elements of this state
  void dispose() {
    rootElement?.dispose();

    for (final (_, element) in childElements.nonNulls) {
      element.dispose();
    }
  }
}
