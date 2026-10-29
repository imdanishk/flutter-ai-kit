# Feature slice recipe: Cubit, Freezed, injectable, auto_route

Use only when the project profile says this is the stack. Match the project's own helper names (status type, result type, safe emit) if it has them. The names below are the defaults installed by the `flutter-new-project` skill.

## Files for a feature named `notes`

```
lib/features/notes/
  domain/note.dart                  plain immutable entity
  domain/note_repository.dart       abstract interface; methods return Future<Result<T>>
  data/note_repository_impl.dart    @LazySingleton(as: NoteRepository); catches errors, returns Err
  presentation/cubit/notes_cubit.dart    @injectable, extends Cubit<NotesState>
  presentation/cubit/notes_state.dart    part of the cubit file; @freezed abstract class
  presentation/notes_page.dart      @RoutePage(); creates the cubit with getIt in a BlocProvider
```

## State (one RequestStatus per independent operation)

```dart
part of 'notes_cubit.dart';

@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState({
    @Default(<Note>[]) List<Note> items,
    @Default(Idle()) RequestStatus loadStatus,
    @Default(Idle()) RequestStatus deleteStatus,
  }) = _NotesState;
}
```

## Cubit

```dart
@injectable
class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._repository) : super(const NotesState());
  final NoteRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loadStatus: const Loading()));
    final result = await _repository.getAll();
    switch (result) {
      case Ok(value: final items):
        emitIfOpen(state.copyWith(items: items, loadStatus: const Succeeded()));
      case Err(:final failure):
        emitIfOpen(state.copyWith(loadStatus: Failed(failure.message)));
    }
  }
}
```

The cubit file needs `part 'notes_cubit.freezed.dart';` and `part 'notes_state.dart';`.

## Page

- `BlocProvider(create: (_) => getIt<NotesCubit>()..load(), child: ...)` is the only place `getIt` is used in presentation.
- A `BlocListener` with `listenWhen` on the status field handles one-off effects (snackbar, navigation). A `BlocBuilder` draws the visible states.
- Add the route to the router's `routes` list. Run code generation.

## Forms

Keep each field's value and error in the state as `FormInput<String>`. Cubit methods such as `titleChanged(String)` validate and update. Widgets hold no `TextEditingController`. The submit button is disabled until every field is valid and the submit status is not `Loading`.
