# Feature slice recipe: flutter_bloc without Freezed or injectable (Cubit or Bloc)

> Read 2026-11-12: `flutter_bloc` 9.1.1 (bloclibrary.dev; the page showed no newer release), `bloc_concurrency` 0.3.0 (published 2025-01-12), bloclibrary.dev naming, architecture and concepts pages. The Dart below was not compiled; the analyzer is the check. If the project is on another major, follow the project.

Use when the project profile says `flutter_bloc` but there is no code generation for state (no Freezed) and no injectable. For the Freezed and injectable stack use `bloc-freezed-recipe.md`. Match the project's own helper names, status type and result type first; this is the fallback when there is no exemplar feature.

## Cubit or Bloc

The bloc library's advice: if unsure, start with a `Cubit`, and move to a `Bloc` when you need the sequence of events that caused each change, or event transformers (debounce, drop, restart). Do not mix both for the same screen without a reason.

## Layers (from bloclibrary.dev, architecture)

Presentation depends on the bloc or cubit; the bloc depends on repositories passed to its constructor; a repository depends on data providers (network, database). **A bloc should not know another bloc.** To react to another bloc's change, use a `BlocListener` in the widget tree that adds an event to the second bloc, or make both listen to a stream the repository exposes.

## Files for a feature named `notes`

```
lib/features/notes/
  domain/note.dart                       immutable entity (Equatable or a plain class with == and hashCode)
  domain/note_repository.dart            abstract interface
  data/note_repository_impl.dart
  presentation/bloc/notes_bloc.dart      Bloc; or notes_cubit.dart for a Cubit
  presentation/bloc/notes_event.dart     part of the bloc file
  presentation/bloc/notes_state.dart     part of the bloc file
  presentation/notes_page.dart
```

## State: equality is required

Both blocs and cubits ignore a new state equal to the current one, and the equality you write decides when widgets rebuild. Use `Equatable` (or write `==`/`hashCode`) and keep lists unmodifiable: replace the list, never mutate it in place.

```dart
part of 'notes_bloc.dart';

enum NotesStatus { initial, loading, success, failure }

final class NotesState extends Equatable {
  const NotesState({
    this.items = const [],
    this.status = NotesStatus.initial,
    this.deleteStatus = NotesStatus.initial,
    this.message,
  });

  final List<Note> items;
  final NotesStatus status;        // loading the list
  final NotesStatus deleteStatus;  // deleting one item; its own status
  final String? message;

  NotesState copyWith({
    List<Note>? items,
    NotesStatus? status,
    NotesStatus? deleteStatus,
    String? message,
  }) => NotesState(
        items: items ?? this.items,
        status: status ?? this.status,
        deleteStatus: deleteStatus ?? this.deleteStatus,
        message: message,
      );

  @override
  List<Object?> get props => [items, status, deleteStatus, message];
}
```

Naming from the docs (optional but recommended for teams): events in the past tense (`NotesStarted`, `NoteDeleted`, `NotesRetried`); states either subclasses ending in `Initial`, `InProgress`, `Success`, `Failure`, or one class with a status enum as above. Follow the project's style if it differs. One status per independent operation (list load and delete must not share one).

## Bloc

```dart
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repository) : super(const NotesState()) {
    on<NotesStarted>(_onStarted, transformer: restartable());
    on<NoteDeleted>(_onDeleted, transformer: droppable());
  }

  final NoteRepository _repository;

  Future<void> _onStarted(NotesStarted event, Emitter<NotesState> emit) async {
    emit(state.copyWith(status: NotesStatus.loading));
    try {
      final items = await _repository.getAll();
      emit(state.copyWith(items: items, status: NotesStatus.success));
    } on AppException catch (e) {
      emit(state.copyWith(status: NotesStatus.failure, message: e.message));
    }
  }

  Future<void> _onDeleted(NoteDeleted event, Emitter<NotesState> emit) async {
    emit(state.copyWith(deleteStatus: NotesStatus.loading));
    try {
      await _repository.delete(event.id);
      emit(state.copyWith(
        items: state.items.where((n) => n.id != event.id).toList(),
        deleteStatus: NotesStatus.success,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(deleteStatus: NotesStatus.failure, message: e.message));
    }
  }
}
```

```dart
part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

final class NotesStarted extends NotesEvent {
  const NotesStarted();
}

final class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
```

- Event transformers come from `bloc_concurrency` (`flutter pub add bloc_concurrency`; ask first): `concurrent`, `sequential`, `droppable` (ignore events added while one is being processed; good for a submit or delete button), `restartable` (only the latest event; good for search). Without a transformer, handlers for different events run concurrently, so two events can interleave their emits.
- Write `emit` only while the handler is running. After an `await` in a **Cubit**, check `isClosed` before emitting (the project's helper, if it has one, is `emitIfOpen`). *Unverified on the pages read: the exact behaviour of `emit` after a Bloc handler completes, and `emit.forEach` for streams; check the API docs before using them.*
- A Bloc never calls `emit` outside a handler. A Cubit's `emit` is only for use inside the Cubit.
- Unhandled exceptions in a handler go to `onError` (the instance's first, then `BlocObserver`). Catch what the screen must show; leave the rest to `BlocObserver` for logging and crash reporting (see `flutter-release/references/crash-and-symbols.md`).

## Providing it

```dart
// near the top of the app, once, for objects that live as long as the app:
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<NoteRepository>(create: (_) => NoteRepositoryImpl(/* api client */)),
  ],
  child: const App(),
)

// on the page that owns the bloc:
BlocProvider(
  create: (context) => NotesBloc(context.read<NoteRepository>())..add(const NotesStarted()),
  child: const NotesView(),
)
```

- `BlocProvider(create: ...)` closes the bloc when it leaves the tree. To give an existing instance to another subtree (a dialog, a pushed route), use `BlocProvider.value`; it does not close it.
- Create a bloc inside `create:`, never in `build`, or every rebuild makes a new one.
- With `get_it` instead of `RepositoryProvider`, call `getIt` only where the bloc is created, as the Freezed recipe does.

## Page

- `BlocBuilder` with `buildWhen` (or `BlocSelector`) draws state. `BlocListener` with `listenWhen` runs one-off effects (snackbar, navigation); compare the status field so it fires once per change. `BlocConsumer` is both.
- In callbacks use `context.read<NotesBloc>().add(...)`; in `build` use `context.watch`/`BlocBuilder`, never `read` to draw.
- Widgets do not call repositories.

## Forms

Keep each field's value and error in the state; events or cubit methods such as `TitleChanged` validate and update. Widgets hold no `TextEditingController` state beyond what the field needs. Disable submit until valid and not loading.

## Tests

Only when the developer asks (`flutter-testing`). `bloc_test` is the usual package; it was not read in this pass.
