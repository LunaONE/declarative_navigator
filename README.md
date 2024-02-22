# Declarative Navigator

While Flutter `Widget`s provide a neat mapping from some state to UI, most app's use either
* an imperative routing concept (`push`/`pop`) where the current navigation state is not known outside of the "current situation" of whatever is on screen, and the range of possible navigation paths can't be determined beforehand
* or a URL-based routing system, where one is limited to pass serializable data as URL query parameters between pages, thus severely limiting the possible architecture.

For many mobile apps there is really no need to have URLs for most (or even many) pages, and thus this library aims to build a system that allows for connections between pages without resorting to globals which are usually needed in addition to URL-based routing.

Furthermore, the building blocks result in fully declarative navigation patterns, where the pages to be shown are derived from the app's state. The package does not use any code-generation, and the pages to be displayed for the current state can be changed at runtime and seen with a simple hot-reload (instead of having to restart the whole app and having to `push` & `pop` oneself to the desired destination to get into the new state).

## Classes

There are 2 base classes available for building your navigation components. Instances of theses classes define what page(s) are shown for their current state and optionally return a `child` which handles the next level of navigation (think e.g. a contact list, and a special navigator handling each the creation of a new contact (which might be wizard) and the editing of an existing one).

### `StatefulNavigator`

Much like a `StatefulWidget` this one updates its state via `setState` calls, after which it re-renders the pages. Implementors have thus a lot of freedom to define how they want to model the data and just need to call `setState` whenever they make a change that should be reflected on screen.

### `MappedNavigator`

This is useful if you already have a go-to approach for writing self-contained state-management classes, like a `ValueListenable<T>`, or `Bloc`/`Cubit`, etc.  
Use your preferred technique to build the underlying manager, and then just define a mapping from the state to the pages/child navigators to be shown.
This separation can offer a bit more structure, and also automatically enables you to test the underlying state handling in isolation from the pages to be shown.

## Deep linking

While URLs are not the primary concern with this approach, it's still important and possible to easily handle deep links to navigate in the app (e.g. as a result from a push notification) as well as be able to create links from within the app referring to certain detail pages.

Instead of a router creating a list of sub-pages from the start URL (which then each have to do their own data loading from the query parameters received), deep links in the declarative navigator's work by putting (a tree of) navigators into the desired state. Thus one has to write a bit of code for each link target, but on the flip-side is also able to handle much more flexible cases because one can react to the current application state through the navigators.
