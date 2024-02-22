import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainAppNavigator extends StatefulNavigator {
  MainAppNavigator({
    required this.close,
  });

  final VoidCallback close;

  bool loggedIn = false;

  @override
  NavigatorDescription describe() {
    if (loggedIn) {
      return child(
        () => _LoggedInNavigator(
          logout: () => setState(() => loggedIn = false),
        ),
      );
    } else {
      return pages([
        DeclarativePage(
          child: _LoginPage(
            onLoggedIn: () => setState(() => loggedIn = true),
            close: close,
          ),
          pop: null,
        ),
      ]);
    }
  }
}

class _LoggedInNavigator extends StatefulNavigator {
  final VoidCallback logout;

  bool showsFoodSelection = false;

  _LoggedInNavigator({
    required this.logout,
  });

  @override
  NavigatorDescription describe() {
    return pagesWithChild(
      [
        DeclarativePage(
          child: _HomePage(
            onLogOut: logout,
            onShowChild: () => setState(() => showsFoodSelection = true),
          ),
          pop: null,
        ),
      ],
      showsFoodSelection
          ? () => _FoodsNavigator(
                close: () => setState(() => showsFoodSelection = false),
              )
          : null,
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage({
    required this.onLoggedIn,
    this.close,
  });

  final VoidCallback onLoggedIn;
  final VoidCallback? close;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged-out'),
        actions: [
          if (close != null)
            IconButton(onPressed: close, icon: const Icon(Icons.close))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.red,
        child: MaterialButton(
          onPressed: onLoggedIn,
          child: const Text('Login'),
        ),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.onLogOut,
    required this.onShowChild,
  });

  final VoidCallback onLogOut;
  final VoidCallback onShowChild;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged-in'),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.green,
        child: Column(
          children: [
            MaterialButton(
              onPressed: onLogOut,
              child: const Text('Logout'),
            ),
            MaterialButton(
              onPressed: onShowChild,
              child: const Text('Show child'),
            ),
          ],
        ),
      ),
    );
  }
}

enum Food {
  apple,
  pizza,
  pasta,
}

class _FoodsNavigator extends MappedNavigator<Food?> {
  final VoidCallback close;

  _FoodsNavigator({
    required this.close,
  });

  // TODO(tp): Set via constructor, who handles dispose?
  final _source = ValueNotifier<Food?>(null);

  @override
  get source => _source;

  @override
  NavigatorDescription map(Food? selectedFood) {
    return pages([
      DeclarativePage(
        child: _FoodSelection(
          onFoodSelect: (f) => _source.value = f,
        ),
        pop: close,
      ),
      if (selectedFood != null)
        DeclarativePage(
          child: _DetailPage(
            food: selectedFood,
          ),
          pop: () => _source.value = null,
        ),
    ]);
  }
}

class _FoodSelection extends StatelessWidget {
  const _FoodSelection({
    required this.onFoodSelect,
  });

  final ValueSetter<Food> onFoodSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selection')),
      body: Container(
        alignment: Alignment.center,
        child: ListView(
          children: [
            for (final food in Food.values)
              ListTile(
                title: Text(food.emoji),
                onTap: () => onFoodSelect(food),
                trailing: const CupertinoListTileChevron(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({
    required this.food,
  });

  final Food food;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: Text(food.emoji),
      ),
    );
  }
}

extension on Food {
  String get emoji {
    return switch (this) {
      Food.apple => '🍏',
      Food.pizza => '🍕',
      Food.pasta => '🍝',
    };
  }
}
