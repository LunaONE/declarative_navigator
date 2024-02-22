import 'package:declarative_navigator/declarative_navigator.dart';
import 'package:example/src/examples/login_example.dart' as login_example;
import 'package:example/src/examples/prevent_back_example.dart'
    as prevent_back_example;
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Declarative Navigator Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DeclarativeNavigatorSource? rootNavigator;

  @override
  Widget build(BuildContext context) {
    final rootNavigator = this.rootNavigator;

    if (rootNavigator == null) {
      return _exampleSelection;
    }

    return DeclarativeNavigatorDisplay(root: rootNavigator);
  }

  Widget get _exampleSelection {
    final examples = <String, DeclarativeNavigatorSource Function()>{
      'Login/Logout + Child Navigator': () => login_example.MainAppNavigator(
            close: _closeExample,
          ),
      'Prevent system back': () => prevent_back_example.MainAppNavigator(
            close: _closeExample,
          ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Examples'),
      ),
      body: ListView(
        children: [
          for (final MapEntry(key: name, value: factoryFunc)
              in examples.entries)
            ListTile(
              title: Text(name),
              onTap: () {
                setState(() {
                  rootNavigator = factoryFunc();
                });
              },
            ),
        ],
      ),
    );
  }

  void _closeExample() {
    setState(() {
      rootNavigator?.dispose();

      rootNavigator = null;
    });
  }
}
