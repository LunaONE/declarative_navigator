// ignore_for_file: invalid_use_of_protected_member

import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() async {
    registerFallbackValue(
      _TestableStatefulNavigator(testStateFactory: () => throw 'not impl'),
    );

    await loadAppFonts();
  });

  testWidgets(
      'DeclarativeNavigatorDisplay: Stateful child, state is preseved across rebuilds',
      (tester) async {
    // `late final` to ensure the state is only created once
    late final _MockState stateMock;
    final root = _TestableStatefulNavigator(testStateFactory: () {
      stateMock = _MockState();
      when(() => stateMock.initState()).thenReturn(null);
      when(() => stateMock.didUpdateNavigator(any())).thenReturn(null);
      when(() => stateMock.build()).thenReturn([
        DeclarativePage(child: testPage('First page'), pop: null),
        DeclarativePage(child: testPage('Child page'), pop: null),
      ]);

      return stateMock;
    });

    await tester.pumpWidget(
      MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: root,
        ),
      ),
    );
    expect(find.text('Child page'), findsOneWidget);
    verify(() => stateMock.initState()).called(1);
    verify(() => stateMock.build()).called(1);
    // verifyNoMoreInteractions(stateMock);

    when(() => stateMock.build()).thenReturn([
      DeclarativePage(child: testPage('First page'), pop: null),
      DeclarativePage(
          key: ValueKey('asdf'),
          child: testPage('Updated child page'),
          pop: null),
    ]);

    print('rebuild');

    // Force rebuild, but this time with a new root (as would be if it were created inline) that ensures that the `state` is reused
    await tester.pumpWidget(
      MaterialApp(
        home: DeclarativeNavigatorDisplay(
          root: _TestableStatefulNavigator(
            testStateFactory: () => throw 'previous state should be reused',
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('x.png'),
    );
    expect(find.text('Updated child page'), findsOneWidget);
    verify(() => stateMock.didUpdateNavigator(any())).called(1);
    verify(() => stateMock.build()).called(1);
    // verifyNoMoreInteractions(stateMock);
  });
}

Widget testPage(String title) {
  return Scaffold(
    key: ValueKey(title),
    body: Text(title),
  );
}

class _TestableStatefulNavigator extends StatefulNavigator {
  _TestableStatefulNavigator({
    required ValueGetter<DeclarativeNavigatorState<_TestableStatefulNavigator>>
        testStateFactory,
  }) : _testStateFactory = testStateFactory;

  final ValueGetter<DeclarativeNavigatorState<_TestableStatefulNavigator>>
      _testStateFactory;

  @override
  DeclarativeNavigatorState<_TestableStatefulNavigator> createState() =>
      _testStateFactory();
}

class _MockState extends Mock
    implements DeclarativeNavigatorState<_TestableStatefulNavigator> {}
