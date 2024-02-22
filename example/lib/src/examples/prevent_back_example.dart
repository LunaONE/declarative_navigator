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

  Child? _child;

  @override
  NavigatorDescription describe() {
    final child = _child;

    return pages([
      DeclarativePage(
        child: _FirstPage(
          setChild: (child) => setState(() => _child = child),
          close: close,
        ),
        pop: null,
      ),
      if (child != null)
        switch (child) {
          Child.systemPoppable => DeclarativePage(
              child: _SecondPage(
                close: _closeChild,
              ),
              // This variant provides a route-level pop function, and thus automatically gets the leading back icon &
              // support for iOS edge swipe and Android back button
              pop: _closeChild,
            ),
          Child.statePoppable => DeclarativePage(
              child: _SecondPage(
                close: _closeChild,
              ),
              // This page can only be popped by invoking the passed `close` funciton
              pop: null,
            ),
        }
    ]);
  }

  void _closeChild() {
    setState(() => _child = null);
  }
}

class _FirstPage extends StatelessWidget {
  const _FirstPage({
    required this.setChild,
    required this.close,
  });

  final ValueSetter<Child> setChild;
  final VoidCallback? close;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preventing system back gestures'),
        actions: [
          if (close != null)
            IconButton(onPressed: close, icon: const Icon(Icons.close))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              onPressed: () => setChild(Child.systemPoppable),
              child: const Text('Show system poppable page'),
            ),
            MaterialButton(
              onPressed: () => setChild(Child.statePoppable),
              child: const Text('Show state poppable page'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage({
    required this.close,
  });

  final VoidCallback close;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              onPressed: close,
              child: const Text(
                'Close this page via provided callback',
              ),
            ),
            const SizedBox(height: 10),
            Text('canPop = $canPop'),
          ],
        ),
      ),
    );
  }
}
