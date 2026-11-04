# Test patterns

Verified 2026-11-04 against pub.dev package pages and Flutter's testing overview, unless a line says Unverified. These are patterns to adapt to the project's own types; they were not compiled or run (no Flutter SDK in the workspace where they were written). Re-check package versions before adding anything.

## Kinds of tests (Flutter's testing overview)

- **Unit test:** one function, method or class; dependencies mocked; no disk, no screen.
- **Widget test:** one widget's UI and interactions in a simplified environment.
- **Integration test:** a whole app or a large part, usually on a device or emulator. The SDK's `integration_test` package cannot interact with native UI such as permission dialogs, notifications or platform views; `patrol` extends testing with native interaction. Flutter's page recommends many unit and widget tests plus enough integration tests for the important flows. [Testing overview](https://docs.flutter.dev/testing/overview)
- Commands (the overview page does not list them; standard usage, Unverified there): `flutter test` runs `test/`; integration tests live in `integration_test/` and run with `flutter test integration_test` on a connected device.

## Packages (versions as read on package pages; check for newer)

- `mocktail` 1.0.5 (published 2026-04-10, MIT): mocks need no code generation. Wrap calls in closures: `when(() => repo.load()).thenAnswer(...)`, `verify(() => repo.load()).called(1)`. Register a fallback value once per custom type used with `any()`: `setUpAll(() { registerFallbackValue(FakeItem()); });`. [mocktail](https://pub.dev/packages/mocktail)
- `bloc_test` 10.0.0 (page dated 2025-01-12, MIT; depends on `bloc ^9.0.0` and `mocktail ^1.0.0`): `blocTest` runs `act` then checks `expect` states in order; other parameters include `build`, `seed`, `skip`, `wait`, `verify`, `errors`, `setUp`, `tearDown`. Use a release that matches the project's `bloc` version. [bloc_test](https://pub.dev/packages/bloc_test)
- Flutter's own unit-testing recipe uses Mockito; keep whichever the project already uses.

## Cubit or bloc test (adapt names)

```dart
class MockItemRepository extends Mock implements ItemRepository {}

void main() {
  late MockItemRepository repository;

  setUp(() {
    repository = MockItemRepository();
  });

  blocTest<ItemsCubit, ItemsState>(
    'emits loading then data when the repository succeeds',
    setUp: () => when(() => repository.items()).thenAnswer((_) async => [item]),
    build: () => ItemsCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ItemsState.loading(),
      ItemsState.data([item]),
    ],
    verify: (_) => verify(() => repository.items()).called(1),
  );

  blocTest<ItemsCubit, ItemsState>(
    'emits loading then failure when the repository throws',
    setUp: () => when(() => repository.items()).thenThrow(Exception('offline')),
    build: () => ItemsCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ItemsState.loading(),
      isA<ItemsState>().having((s) => s.isFailure, 'isFailure', true),
    ],
  );
}
```

Use the project's own state and result types (for example its `Result` or `Either`) in `thenAnswer`. Compare states by value: Freezed and Equatable states compare by value; plain classes need `isA` with `having`.

## Repository test

Mock the data source (API client, local store), stub one success and one failure, and assert what the repository returns or throws and that it maps data to domain types. Do not mock the repository's own collaborators more than needed.

## Widget test

```dart
testWidgets('shows the error message and a retry button on failure', (tester) async {
  final cubit = MockItemsCubit();
  when(() => cubit.state).thenReturn(const ItemsState.failure('offline'));

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<ItemsCubit>.value(value: cubit, child: const ItemsPage()),
    ),
  );

  expect(find.text('offline'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

Wrap the widget in what the project's pages need (theme, localization delegates, router stub). Prefer the project's existing test helper over rebuilding that wrapper. For a mocked cubit, stub `state` and `stream` as the project's other tests do.

## Riverpod

Override providers in a `ProviderContainer` (`overrides: [repositoryProvider.overrideWithValue(mock)]`), read the notifier, and assert the sequence of `AsyncValue` states; dispose the container in `tearDown` (Unverified here; check the Riverpod testing page for the version in use).

## Integration tests

Only on request. Create `integration_test/app_test.dart`, start the app with the flavor's entry point, and drive the one flow asked for. For permission dialogs, notifications or platform views use `patrol` (ask before adding it).
