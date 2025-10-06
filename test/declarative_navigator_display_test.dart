// ignore_for_file: unused_element

import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

final methodCalls = [];

void main() {
  setUpAll(() {
    loadAppFonts();
  });

  setUp(() {
    methodCalls.clear();
  });

  testWidgets('$DeclarativeNavigatorDisplay: Single page', (tester) async {
    // Create new instances of the same widget configuration, so we actually call all it again on "pump" and don't short circuit it with the same instances
    Widget app() {
      return MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestPage(name: 'A'),
        ),
      );
    }

    await tester.pumpWidget(app());

    expect(find.text('Page "A" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestPage[name: A].build()',
      '_TestPage[name: A].createRoute()',
    ]);
    methodCalls.clear();

    await tester.pumpWidget(app());
    expect(find.text('Page "A" render #2'), findsOneWidget);
    expect(methodCalls, ['_TestPage[name: A].build()']); // route is re-used
    methodCalls.clear();
  });

  testWidgets(
      '$DeclarativeNavigatorDisplay: $StatelessNavigator with different parameters (showing one then two pages)',
      (tester) async {
    Widget app({required bool twoPages}) {
      return MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestStatelessNavigatorWithPages(twoPages: twoPages),
        ),
      );
    }

    await tester.pumpWidget(app(twoPages: false));

    expect(find.text('Page "One" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatelessNavigatorWithPages(twoPages: false)',
      '_TestStatelessNavigatorWithPages[twoPages: false].build()',
      '_TestPage[name: One].build()',
      '_TestPage[name: One].createRoute()',
    ]);
    methodCalls.clear();

    await tester.pumpWidget(app(twoPages: true));
    // await tester.pumpAndSettle();
    // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    expect(find.text('Page "Two" render #1').hitTestable(), findsOneWidget);
    expect(methodCalls, [
      '_TestStatelessNavigatorWithPages(twoPages: true)',
      '_TestStatelessNavigatorWithPages[twoPages: true].build()',
      '_TestPage[name: One].build()',
      '_TestPage[name: Two].build()',
      '_TestPage[name: Two].createRoute()',
    ]);
    methodCalls.clear();
  });

  testWidgets(
      '$DeclarativeNavigatorDisplay: $StatefulNavigator updating its state to show a second page',
      (tester) async {
    Widget app() {
      return MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestStatefulNavigatorWithPages(),
        ),
      );
    }

    await tester.pumpWidget(app());

    expect(find.text('Page "First" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false]()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
      '_TestPage[name: First].build()',
      '_TestPage[name: First].createRoute()',
    ]);
    methodCalls.clear();

    // Rebuild from the top
    await tester.pumpWidget(app());
    expect(find.text('Page "First" render #2'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
      '_TestPage[name: First].build()',
    ]);
    methodCalls.clear();

    // Trigger action to show second page
    await tester.tap(find.text('Action "First"'));
    await tester.pumpAndSettle();
    // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    expect(find.text('Page "Second" render #1').hitTestable(), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithPagesState[showSecondPage: true].build()',
      '_TestPage[name: First (behind)].build()',
      '_TestPage[name: Second].build()',
      '_TestPage[name: Second].createRoute()',
    ]);
    methodCalls.clear();
  });

  testWidgets(
      '$DeclarativeNavigatorDisplay: $StatefulNavigator updating its state to show a child navigator',
      (tester) async {
    Widget app() {
      return MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestStatefulNavigatorWithChildNavigator(),
        ),
      );
    }

    await tester.pumpWidget(app());

    expect(find.text('Page "Entry page" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: false]()',
      '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: false].build()',
      '_TestPage[name: Entry page].build()',
      '_TestPage[name: Entry page].createRoute()',
    ]);
    methodCalls.clear();

    // Trigger action to show child navigator with first page
    await tester.tap(find.text('Action "Entry page"'));
    await tester.pumpAndSettle();
    // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    expect(find.text('Page "First" render #1').hitTestable(), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: true].build()',
      '_TestPage[name: Entry page (behind)].build()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false]()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
      '_TestPage[name: First].build()',
      '_TestPage[name: First].createRoute()',
    ]);
    methodCalls.clear();

    await tester.tap(find.text('Action "First"'));
    await tester.pumpAndSettle();
    // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    // expect(find.text('Page "Second" render #1').hitTestable(), findsOneWidget);
    expect(methodCalls, [
      // Could we optimize this out, as we already rebuild higher up? Or better to not call the higher up and just modify the pages (instead of a full rebuild)
      '_TestStatefulNavigatorWithPagesState[showSecondPage: true].build()',
      '_TestPage[name: First (behind)].build()',
      '_TestPage[name: Second].build()',
      '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: true].build()',
      '_TestPage[name: Entry page (behind)].build()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: true].build()',
      '_TestPage[name: First (behind)].build()',
      '_TestPage[name: Second].build()',
      '_TestPage[name: Second].createRoute()',
    ]);
    methodCalls.clear();
  });

  testWidgets(
      '$DeclarativeNavigatorDisplay: $StatefulNavigator being updated (by parameter) to show a different child navigator',
      (tester) async {
    Widget app({bool mountAlternateChildNavigator = false}) {
      return MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestStatefulNavigatorWithSwitchingChildNavigator(
            mountAlternateChildNavigator: mountAlternateChildNavigator,
          ),
        ),
      );
    }

    await tester.pumpWidget(app());
    expect(find.text('Page "First" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithSwitchingChildNavigatorState()',
      '_TestStatefulNavigatorWithSwitchingChildNavigatorState[navigator.mountAlternateChildNavigator: false].build()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false]()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
      '_TestPage[name: First].build()',
      '_TestPage[name: First].createRoute()'
    ]);
    methodCalls.clear();

    await tester.pumpWidget(app(mountAlternateChildNavigator: true));
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    // expect(find.text('Page "First" render #1').hitTestable(), findsOneWidget);
    // TODO: This renders "#2", but the child pages should be cleared
    // expect(find.text('Page "First" render #1'), findsOneWidget);
    expect(methodCalls, [
      '_TestStatefulNavigatorWithSwitchingChildNavigatorState[navigator.mountAlternateChildNavigator: true].build()',
      '_AlternateTestStatefulNavigatorWithPages()',
      '_TestStatefulNavigatorWithPagesState[showSecondPage: false].dispose()',
      '_AlternateTestStatefulNavigatorWithPagesState[showSecondPage: false]()',
      '_AlternateTestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
      '_TestPage[name: First].build()' // TODO: route should be recreated
    ]);
    methodCalls.clear();

    /// Unmount, should dispose
    await tester.pumpWidget(const SizedBox.shrink());
    expect(methodCalls, [
      // TODO(tp): This should call dispose
    ]);
    methodCalls.clear();

    // // Trigger action to show child navigator with first page
    // await tester.tap(find.text('Action "Entry page"'));
    // await tester.pumpAndSettle();
    // // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    // expect(find.text('Page "First" render #1').hitTestable(), findsOneWidget);
    // expect(methodCalls, [
    //   '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: true].build()',
    //   '_TestPage[name: Entry page (behind)].build()',
    //   '_TestStatefulNavigatorWithPagesState[showSecondPage: false]()',
    //   '_TestStatefulNavigatorWithPagesState[showSecondPage: false].build()',
    //   '_TestPage[name: First].build()',
    //   '_TestPage[name: First].createRoute()',
    // ]);
    // methodCalls.clear();

    // await tester.tap(find.text('Action "First"'));
    // await tester.pumpAndSettle();
    // // await expectLater(find.byType(MaterialApp), matchesGoldenFile('main.png'));
    // // expect(find.text('Page "Second" render #1').hitTestable(), findsOneWidget);
    // expect(methodCalls, [
    //   // Could we optimize this out, as we already rebuild higher up? Or better to not call the higher up and just modify the pages (instead of a full rebuild)
    //   '_TestStatefulNavigatorWithPagesState[showSecondPage: true].build()',
    //   '_TestPage[name: First (behind)].build()',
    //   '_TestPage[name: Second].build()',
    //   '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: true].build()',
    //   '_TestPage[name: Entry page (behind)].build()',
    //   '_TestStatefulNavigatorWithPagesState[showSecondPage: true].build()',
    //   '_TestPage[name: First (behind)].build()',
    //   '_TestPage[name: Second].build()',
    //   '_TestPage[name: Second].createRoute()',
    // ]);
    // methodCalls.clear();
  });
}

class _TestPageWidget extends StatefulWidget {
  const _TestPageWidget({
    super.key,
    required this.name,
    this.onTap,
  });

  final String name;

  final VoidCallback? onTap;

  @override
  State<_TestPageWidget> createState() => _TestPageWidgetState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '_TestPageWidget[name: $name]';
  }
}

class _TestPageWidgetState extends State<_TestPageWidget> {
  int render = 0;
  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;

    return Scaffold(
      body: Column(
        children: [
          Text('Page "${widget.name}" render #${++render}'),
          if (onTap != null)
            MaterialButton(
              onPressed: onTap,
              child: Text('Action "${widget.name}"'),
            ),
        ],
      ),
    );
  }
}

class _TestPage extends DeclarativePage {
  // ignore: use_super_parameters
  _TestPage({
    required String name,
    VoidCallback? pageAction,
    VoidCallback? pop,
  }) : super(
          child: _TestPageWidget(
            name: name,
            onTap: pageAction,
          ),
          name: name,
          pop: pop,
        );

  @override
  Route createRoute(BuildContext context) {
    methodCalls.add('_TestPage[name: $name].createRoute()');

    return super.createRoute(context);
  }

  @override
  DeclarativePage build() {
    methodCalls.add('_TestPage[name: $name].build()');

    return super.build();
  }
}

class _TestStatelessNavigatorWithPages extends StatelessNavigator {
  _TestStatelessNavigatorWithPages({
    super.key,
    required this.twoPages,
  }) {
    methodCalls.add('_TestStatelessNavigatorWithPages(twoPages: $twoPages)');
  }

  final bool twoPages;

  @override
  List<DeclarativeNavigatable> build() {
    methodCalls.add('$this.build()');

    return [
      _TestPage(name: 'One'),
      if (twoPages) _TestPage(name: 'Two'),
    ];
  }

  @override
  String toString() {
    return '_TestStatelessNavigatorWithPages[twoPages: $twoPages]';
  }
}

class _TestStatefulNavigatorWithPages extends StatefulNavigator {
  @override
  DeclarativeNavigatorState<_TestStatefulNavigatorWithPages> createState() =>
      _TestStatefulNavigatorWithPagesState();
}

class _TestStatefulNavigatorWithPagesState
    extends DeclarativeNavigatorState<_TestStatefulNavigatorWithPages> {
  _TestStatefulNavigatorWithPagesState() {
    methodCalls.add('$this()');
  }

  bool showSecondPage = false;

  @override
  List<DeclarativeNavigatable> build() {
    methodCalls.add('$this.build()');
    return [
      _TestPage(
        name: showSecondPage ? 'First (behind)' : 'First',
        pageAction: () {
          setState(() {
            showSecondPage = true;
          });
        },
      ),
      if (showSecondPage) _TestPage(name: 'Second'),
    ];
  }

  @override
  void dispose() {
    methodCalls.add('$this.dispose()');

    super.dispose();
  }

  @override
  String toString() {
    return '_TestStatefulNavigatorWithPagesState[showSecondPage: $showSecondPage]';
  }
}

class _TestStatefulNavigatorWithChildNavigator extends StatefulNavigator {
  @override
  DeclarativeNavigatorState<_TestStatefulNavigatorWithChildNavigator>
      createState() => _TestStatefulNavigatorWithChildNavigatorState();
}

class _TestStatefulNavigatorWithChildNavigatorState
    extends DeclarativeNavigatorState<
        _TestStatefulNavigatorWithChildNavigator> {
  _TestStatefulNavigatorWithChildNavigatorState() {
    methodCalls.add('$this()');
  }

  bool mountChildNavigator = false;

  @override
  List<DeclarativeNavigatable> build() {
    methodCalls.add('$this.build()');
    return [
      _TestPage(
        name: mountChildNavigator ? 'Entry page (behind)' : 'Entry page',
        pageAction: () {
          setState(() {
            mountChildNavigator = true;
          });
        },
      ),
      if (mountChildNavigator) _TestStatefulNavigatorWithPages(),
    ];
  }

  @override
  String toString() {
    return '_TestStatefulNavigatorWithChildNavigatorState[mountChildNavigator: $mountChildNavigator]';
  }
}

/// Uses a new runtime type, and thus will cause not be updated from [_TestStatefulNavigatorWithPages], but rather created anew
class _AlternateTestStatefulNavigatorWithPages
    extends _TestStatefulNavigatorWithPages {
  _AlternateTestStatefulNavigatorWithPages() {
    // NOTE(tp): Can't use `$this` for the name, as the `navigator` property is not yet set
    methodCalls.add('$_AlternateTestStatefulNavigatorWithPages()');
  }

  @override
  DeclarativeNavigatorState<_TestStatefulNavigatorWithPages> createState() =>
      _AlternateTestStatefulNavigatorWithPagesState();
}

class _AlternateTestStatefulNavigatorWithPagesState
    extends _TestStatefulNavigatorWithPagesState {
  @override
  String toString() {
    return '_AlternateTestStatefulNavigatorWithPagesState[showSecondPage: $showSecondPage]';
  }
}

class _TestStatefulNavigatorWithSwitchingChildNavigator
    extends StatefulNavigator {
  _TestStatefulNavigatorWithSwitchingChildNavigator({
    super.key,
    required this.mountAlternateChildNavigator,
  });

  final bool mountAlternateChildNavigator;

  @override
  DeclarativeNavigatorState<_TestStatefulNavigatorWithSwitchingChildNavigator>
      createState() => _TestStatefulNavigatorWithSwitchingChildNavigatorState();
}

class _TestStatefulNavigatorWithSwitchingChildNavigatorState
    extends DeclarativeNavigatorState<
        _TestStatefulNavigatorWithSwitchingChildNavigator> {
  _TestStatefulNavigatorWithSwitchingChildNavigatorState() {
    // NOTE(tp): Can't use `$this` for the name, as the `navigator` property is not yet set
    methodCalls
        .add('$_TestStatefulNavigatorWithSwitchingChildNavigatorState()');
  }

  @override
  List<DeclarativeNavigatable> build() {
    methodCalls.add('$this.build()');
    return [
      navigator.mountAlternateChildNavigator
          ? _AlternateTestStatefulNavigatorWithPages()
          : _TestStatefulNavigatorWithPages(),
    ];
  }

  @override
  String toString() {
    return '_TestStatefulNavigatorWithSwitchingChildNavigatorState[navigator.mountAlternateChildNavigator: ${navigator.mountAlternateChildNavigator}]';
  }
}
