# GraphQL with Ferry: setup, repository and pitfalls

Checked 2026-11-08 against the Ferry repository (`gql-dart/ferry`, last commit 2026-10-27, docs folder read), the `gql-dart/gql` repository (links and an auth-link example read), and pub.dev pages. Lines marked *Unverified* were not run or not found in those sources. Use this only when the project already uses Ferry or the developer chose it; if the project uses another GraphQL client, follow the project.

## Status to know before choosing

- Stable releases on pub.dev: `ferry` 0.16.1+2 and `ferry_flutter` 0.9.1+1, both published 2025-01-06. The repository's main branch carries newer prereleases (`ferry` 0.16.2-dev.4, `ferry_generator` 0.14.0-dev.4) and docs for a second generator (`codegen2.md`, `migration-generator2.md`, not read). So the project is alive, but stable releases lag behind main. Pin versions and read the changelog before upgrading.
- Alternatives on pub.dev: `graphql_flutter` (with `graphql_codegen` for typed operations). Ferry's own docs say its Hive storage depends on `hive`, which they call unmaintained, and offer `ferry_hive_ce_store` as a binary-compatible replacement.
- Ferry generates classes with `built_value`, not Freezed. Generated types stay in the data layer; map them to the project's domain entities before they reach a Cubit.

## Packages (from Ferry's setup page)

```yaml
dependencies:
  ferry:
  gql_http_link:
  gql_code_builder_serializers:   # serializers the generator assumes
dev_dependencies:
  ferry_generator:
  build_runner:
```

Optional: `ferry_flutter` (widgets), `gql_error_link` and `gql_transform_link` (auth), `gql_dio_link` if the project already has a configured Dio, `ferry_hive_ce_store` for an offline cache. Use the versions pub.dev shows now.

## Schema, operations, generation

1. Keep the schema as an SDL file **inside `lib/`** (for example `lib/schema.graphql`): the generator cannot read files outside `lib`. Ferry's docs download it with the npm tool `get-graphql-schema`; whether that tool is maintained was not checked. With a NestJS backend, ask the backend owner for the generated SDL file or the endpoint's introspection permission instead of guessing (*Unverified: how this team's backend exposes its schema*). Commit the schema; refresh it when the backend changes.
2. Write each operation in a `.graphql` file, preferably in a `graphql/` folder next to the feature; the generated files are written beside it. Share fragments with a comment import at the top: `# import './pokemon_card_fragment.graphql'`.
3. `build.yaml` in the project root enables both builders and points to the schema (the rest of the file is on Ferry's codegen page):

```yaml
targets:
  $default:
    builders:
      ferry_generator|graphql_builder:
        enabled: true
        options:
          schema: your_package_name|lib/schema.graphql
      ferry_generator|serializer_builder:
        enabled: true
        options:
          schema: your_package_name|lib/schema.graphql
```

4. Generate with `dart run build_runner build --delete-conflicting-outputs` (through `fvm` if the project uses it). Never edit generated files. Generated names get a `G` prefix: `query AllPokemon` becomes `GAllPokemonReq`, `GAllPokemonVars`, `GAllPokemonData`.
5. Select `id` and let `__typename` come through on every object you want cached: the cache keys objects by `__typename` plus `id` or `_id`, so an object without one is not normalized and mutations will not update it elsewhere.

## Client (one per app, created in the DI container)

```dart
final link = HttpLink(endpoint, defaultHeaders: {...}); // see Auth below
final cache = Cache(possibleTypes: possibleTypesMap);   // possibleTypesMap is generated
final client = Client(link: link, cache: cache);
```

The default cache uses an in-memory store. Register the client as a singleton; call `await client.dispose()` only when the app tears it down. On sign-out call `cache.clear()` (or build a new client) so the next user cannot see the previous user's cached data.

## Requests and responses

- `client.request(req)` returns a `Stream<OperationResponse>` that stays open and emits again when the cache changes. For a one-shot repository call, take the first response that is not loading, then stop listening: `await client.request(req).firstWhere((r) => !r.loading)` (*pattern, not run here*). For a screen that should update live, subscribe in the Cubit and cancel in `close()`.
- An `OperationResponse` has `data`, `graphqlErrors`, `linkException`, `dataSource`, `loading` (no link exception and no data yet) and `hasErrors`. **An error does not throw.** Ferry's default client turns stream errors and exceptions thrown while forwarding into a response with a `linkException`; GraphQL server errors arrive in `graphqlErrors`, and a response can hold both data and errors.
- Default fetch policies: query `CacheFirst`, mutation `NetworkOnly`, subscription `CacheAndNetwork`. Others: `CacheOnly`, `NoCache`. `CacheFirst` returns old data without asking the server, so pull-to-refresh needs `NetworkOnly` on the refetch request (re-adding the same request to `client.requestController` keeps its policy). Set `defaultFetchPolicies` on the client if the app wants another default.
- Very large nested responses can drop frames while the cache normalizes them; Ferry offers an `IsolateClient` for that (docs page `isolates.md`, not read in detail).

## Repository: map the response to the project's `Result`

```dart
Future<Result<List<Note>>> getNotes() async {
  final response = await _client
      .request(GNotesReq((b) => b..fetchPolicy = FetchPolicy.NetworkOnly))
      .firstWhere((r) => !r.loading);

  if (response.linkException != null) return Err(_fromLink(response.linkException!));
  final errors = response.graphqlErrors;
  if (errors != null && errors.isNotEmpty) return Err(_fromGraphql(errors));
  final data = response.data;
  if (data == null) return const Err(AppFailure('Empty response'));
  return Ok(data.notes.map(_toNote).toList());
}
```

Rules for `_fromLink` and `_fromGraphql` (your own code):
- Order of checks matters: look at errors before trusting `data`, and decide whether partial data with errors is acceptable for that screen.
- Separate outcomes the user sees differently: no connection or timeout (link exception), not signed in or session expired, not allowed, validation error, server error. Use a stable error **code** the backend sends (usually in each error's `extensions`; *Unverified: the code names this backend uses*), never the message text.
- Cancellation is not an error: do not show a message for a request the app cancelled.

## Auth (token header, refresh on 401)

- Put the token in a request-transforming link in front of `HttpLink`, or in `HttpLink(defaultHeaders: ...)` only if the token never changes while the client lives.
- The `gql` repository's `gql_example_http_auth_link` shows the pattern: `Link.concat(ErrorLink(onException: ...), TransformLink(requestTransformer: ...))` in front of the HTTP link; when an `HttpLinkServerException` carries status 401 it refreshes the token once (callers that arrive while a refresh runs wait for it) and forwards the request again.
- A GraphQL server can answer an unauthenticated call with HTTP 200 and an error code in `extensions` instead of 401; then the same handling belongs in `ErrorLink`'s GraphQL-error callback. Check which one the backend does before writing the handler.
- Keep this in the link, not in each repository, so every operation signs out on the same condition (see the pitfalls list in `flutter-review`).

## What to hand to the backend owner

The endpoint URL per environment, the schema file, the error codes for auth and validation, whether introspection is on, query depth or complexity limits, and the file-upload approach if the app uploads files (*Unverified: Ferry's upload support was not checked; many teams use a separate REST upload endpoint*).
