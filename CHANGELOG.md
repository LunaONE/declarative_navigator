## 0.0.2

* Adds supports for automatic back buttons or not depending on whether a `pop` function is provided on the `DeclarativePage`
  * If given, that function must update the state, such that the page will not be part of the next render
  * Adds example showing pages with and without such a `pop` and how the default `AppBar` and transition style adapts accordingly
* Use `Material`-style route as base to automatically get system-adaptive styles
  * Uses a modal transition for all sub-pages that don't allow the user to go back using system gestures

## 0.0.1

* Initial implementation of `StatefulNavigator` and `MappedNavigator`
* Example showing a simple list/detail pattern
