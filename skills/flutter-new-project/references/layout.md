# Default layout

```
lib/
  main.dart
  app/
    injection.dart        injectable entry point (configureDependencies)
    router.dart           @AutoRouterConfig class AppRouter
  core/                   shared, no feature imports (copied from assets/core)
    result.dart           sealed Result<T> = Ok | Err, AppFailure
    request_status.dart   sealed RequestStatus = Idle | Loading | Succeeded | Failed
    form_input.dart       FormInput<T>: value and error for one field
    cubit_ext.dart        emitIfOpen
    paging.dart           PageResult<T>, slicePage
    validators.dart       validateEmail, validatePassword, validateRequired
    strings.dart          AppStrings: user-visible text
  features/
    <feature>/
      domain/             entities, repository interfaces
      data/               repository implementations, data sources, mappers
      presentation/
        cubit/            <feature>_cubit.dart and <feature>_state.dart (part of)
        <feature>_page.dart
```

## Dependency direction

presentation depends on domain; data depends on domain; domain depends on nothing app-specific. `core` depends on nothing in `features`. Features never import each other's data or presentation code; share through `core` or through domain interfaces.

## Notes

- Replace `AppStrings` with the project's localization (ARB files and `flutter gen-l10n`) when the app is multilingual, and keep the rule: no user-visible text in widgets.
- Add a `lib/core/network/` or `lib/core/storage/` folder only when the project adds those concerns.
