import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';

enum Child {
  systemPoppable,
  statePoppable,
}

class MainAppNavigator extends StatefulNavigator {
  MainAppNavigator({
    required this.close,
  });

  final VoidCallback close;

  @override
  DeclarativeNavigatorState<StatefulNavigator> createState() =>
      _MainAppNavigatorState();
}

class _MainAppNavigatorState
    extends DeclarativeNavigatorState<MainAppNavigator> {
  @override
  List<DeclarativeNavigatable> build() {
    print('building _MainAppNavigatorState pages');

    return [_ChildNavigator()];
  }
}

class _ChildNavigator extends StatefulNavigator {
  final DateTime now;

  _ChildNavigator() : now = DateTime.now() {
    print('creationg child naviagto');
  }

  @override
  DeclarativeNavigatorState<StatefulNavigator> createState() =>
      _ChildNavigatorState();

  @override
  String toString() {
    // TODO: implement toString
    return '_ChildNavigator[HOT RELOAD]($now)';
  }
}

class _ChildNavigatorState extends DeclarativeNavigatorState<_ChildNavigator> {
  @override
  void didUpdateNavigator(covariant _ChildNavigator oldNavigator) {
    super.didUpdateNavigator(oldNavigator);

    print(
        '_ChildNavigatorState.didUpdateNavigator ${oldNavigator.now} -> ${navigator.now}');
  }

  @override
  List<DeclarativeNavigatable> build() {
    print('_ChildNavigatorState.build with ${navigator.now}');

    return [
      DeclarativePage(
        child: _Page(
          navigatorNow: navigator.now,
          close: null,
        ),
        pop: null,
      ),
    ];
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.navigatorNow,
    required this.close,
  });

  final DateTime navigatorNow;
  final VoidCallback? close;

  @override
  Widget build(BuildContext context) {
    print('_Page.build $navigatorNow');

    return Scaffold(
        appBar: AppBar(
          title: const Text('Hot reload'),
          actions: [
            if (close != null)
              IconButton(onPressed: close, icon: const Icon(Icons.close))
          ],
        ),
        body: Column(
          children: [
            Text('Navigator now $navigatorNow'),
            Text('Page now ${DateTime.now()}'),
          ],
        ));
  }
}
