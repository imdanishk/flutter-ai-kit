# Feature slice recipe: Riverpod 3

Use only when the project profile says Riverpod is the state management. Follow the project's own naming, folder layout and error handling first; this is the fallback when there is no suitable exemplar feature. Packages checked on 2026-10-31: `flutter_riverpod` 3.4.3, `riverpod_annotation` 4.0.7, `riverpod_generator` 4.0.9 (all from dash-overflow.net).

## Decide first: hand-written or generated providers

Both are supported. Match the project. If it has `riverpod_generator` and `build_runner`, use `@riverpod` and run code generation (`dart run build_runner build -d`, with the `fvm` prefix when pinned). If it does not, write providers by hand as below: no code generation, no `part` files. For a new project, hand-written providers are the smaller step. The class-based `@riverpod` syntax is not shown on the Riverpod getting-started page, so confirm it in the project's existing providers or the Riverpod docs before writing it.

## Files for a feature named `notes`

```
lib/features/notes/
  domain/note.dart
  domain/note_repository.dart            abstract; methods return Future<T> and throw an app exception on failure
  data/note_repository_impl.dart
  application/notes_providers.dart       repository provider and the notifier
  presentation/notes_page.dart           ConsumerWidget
```

## Providers

```dart
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(/* dependencies via ref.watch(...) */),
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(noteRepositoryProvider).getAll();

  Future<void> remove(String id) async {
    final repository = ref.read(noteRepositoryProvider);
    final previous = await future;
    await repository.delete(id);
    if (!ref.mounted) return;
    state = AsyncData(previous.where((n) => n.id != id).toList());
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
```

Rules that matter in Riverpod 3 (verified in the Riverpod 3.0 notes):
- Check `ref.mounted` after every `await` before writing to `state`. A disposed notifier throws.
- Put initial loading in `build`; do not wrap it in `try`/`catch`. The loading and error states come from `AsyncValue`.
- `AutoDisposeNotifier` and `FamilyNotifier` no longer exist: use `Notifier`/`AsyncNotifier`, and pass family arguments through the constructor.
- `StateProvider`, `StateNotifierProvider` and `ChangeNotifierProvider` moved to `package:riverpod/legacy.dart`; avoid them in new code.
- A provider that fails while initialising retries automatically with exponential backoff (starts at 200 ms). Turn it off per provider or on the `ProviderScope` if a failing call must not repeat (payments, one-time actions).
- Updates are filtered with `==`: state classes need equality, or listeners will not fire as expected.

## Page

```dart
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return switch (notes) {
      AsyncData(:final value) => NotesList(notes: value),
      AsyncError() => RetryView(onRetry: () => ref.invalidate(notesProvider)),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}
```

- Wrap the app once in `ProviderScope` in `main.dart`.
- Call actions with `ref.read(notesProvider.notifier).remove(id)` inside callbacks, never inside `build`.
- One-off effects (snackbar, navigation): use `ref.listen(provider, ...)` in `build` of the page, not in the notifier.
- Do not read a provider's value into a widget's own state; watch it.

## Independent operations

Two operations that can run side by side (load the list, delete an item) should not share one `AsyncValue`. Give the second its own provider, or use Riverpod's `Mutation`. Mutations are marked experimental in the 3.0 notes and the API may change without a major version, so prefer a separate notifier or provider unless the project already uses mutations.

## Forms

Keep each field's value and error in a small immutable state class held by a `Notifier` (for example `LoginFormNotifier` with `emailChanged`, `passwordChanged`, `submit`). Widgets hold no `TextEditingController` state beyond what the text field needs. Disable the submit button until every field is valid and the submit operation is not loading.

## Lint

The Riverpod docs recommend the `riverpod_lint` package, enabled under `plugins:` in `analysis_options.yaml`. Add it only if the project already lints or the developer agrees.

## Status

Verified 2026-10-31 from pub.dev/packages/flutter_riverpod, pub.dev/packages/riverpod_generator, pub.dev/packages/riverpod_annotation, riverpod.dev/docs/whats_new, riverpod.dev/docs/introduction/getting_started and riverpod.dev/docs/migration/from_state_notifier. Verify: the `@riverpod` class syntax, `ref.listen` placement for effects and the `riverpod_lint` setup (those pages did not load).
