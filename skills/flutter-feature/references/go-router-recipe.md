# Routing recipe: go_router

> Read 2026-11-12: pub.dev `go_router` (publisher flutter.dev, 18.1.1 shown, published 2026-10-20; the package is described as feature-complete, with the Flutter team focusing on bug fixes and stability; it depends on `material_ui` ^1.0.0) and the package's Navigation, Redirection, StatefulShellRoute, GoRouter class and Type-safe routes pages. The 17 to 18 migration guide is at flutter.dev/go/go-router-v18-breaking-changes and could not be read in this pass: read it before moving a project from 17 to 18. The Dart below was not compiled.

Use when the project profile says go_router. If the project uses `auto_route` (the Freezed recipe) or another router, follow the project.

## Set up

```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => NoteDetailPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

// MaterialApp.router(routerConfig: appRouter, ...)
```

Keep path strings in one class of constants or functions (as the project does) so a route's path is written once. Build the `GoRouter` once, outside `build`.

## `go` replaces the stack; `push` adds to it

From the package's Navigation page: `context.go()` "will replace the current stack of screens with the screens configured to be displayed for the destination route"; `context.push()` adds a screen to the history stack; `context.pop()` removes the current one and can return a value. Consequences that cause real bugs:
- A screen reached with `go` is **built again** when you navigate away and back, so its local state (scroll position, selected tab, text typed, an in-flight request) is lost unless it lives outside the widget (a bloc, a notifier, a controller owned higher up, or `PageStorageKey` for scroll position). If a detail screen should return to the list as it was, open it with `push`, or put the tabs in a `StatefulShellRoute` (below).
- Screens opened with `push` are not deep-linkable, and are replaced if a parent `GoRoute` page is removed (the page says so). The page also notes imperative navigation is known to cause issues with browser history on web.
- Query values go in the URL (`Uri(path: ..., queryParameters: {...}).toString()`); `extra` carries objects but is serialized when stored in the browser, so on web a custom codec may be needed or the data can be dropped. Prefer ids in the path and load the object on the screen.

## Tabs that keep their state

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(index),
      items: const [ /* one per branch */ ],
    ),
  ),
  branches: [
    StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (c, s) => const HomePage())]),
    StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (c, s) => const ProfilePage())]),
  ],
)
```

Each branch keeps its own navigation stack, and `goBranch` restores it (class page). The page's own example passes `index:` as a named argument to `goBranch`; check the signature in your version. A plain `ShellRoute` shares one navigator and does not keep each tab's stack.

## Redirects and sign-in

- A top-level `redirect` on `GoRouter` runs before any navigation event; a `GoRoute(redirect:)` runs when that route is about to be shown. Return `null` for no redirect, or a location. The default `redirectLimit` is 5; beyond it the error screen shows. A redirect that sends signed-out users to `/signin` must return `null` when the target already is `/signin` (compare `state.matchedLocation`), or it loops.
- `GoRouter` takes `refreshListenable` (it is in the constructor; the pages read gave no description). The usual use is to pass a `Listenable` that notifies when the sign-in state changes, so the redirect runs again. *Unverified here: confirm against the class page for your version.*
- Decide the signed-out destination, the deep link that arrives while signed out (keep the intended location and return to it after sign-in), and the session-expired case with the backend owner. `flutter-plan` lists these paths.
- Do not put secrets in a route URL.

## Type-safe routes (optional)

`go_router_builder` with `build_runner` generates typed route classes: extend `GoRouteData`, annotate with `@TypedGoRoute`, and navigate with `const SongRoute(id: 2).go(context)`. It adds dev dependencies and generated files, so use it only if the project already does or the developer agrees.

## Deep links

The router matches paths; the platform side (Android App Links and intent filters, iOS Associated Domains) is separate native work. See `flutter-feature-notes/references/guides/data-sharing-and-linking.md` and `flutter-service-setup`.

## Pitfalls

- A `GlobalKey` or `navigatorKey` used by two routers, or a router created in `build`, resets navigation on every rebuild.
- `context.go` in places that need `push` (detail screens), and `push` where `go` is intended (after sign-in, to avoid back-navigating to the sign-in screen).
- Reading `GoRouterState` after an `await` without `context.mounted`.
- Moving from 17 to 18: `go_router` depends on `material_ui`; follow `flutter-fix/references/upgrade-checklist.md` for the Material migration and read the 18 breaking-changes guide.
