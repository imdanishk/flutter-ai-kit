# API, auth, paging and cache pitfalls

Use when a change touches network calls, error mapping, sign-out on expired sessions, paged lists, search or in-memory caches, or when someone adds shared base classes for them.

Status: found by reading the source of a small shared base package for Flutter apps on 2026-11-05. The code was read, not run (no Flutter SDK here, and pub.dev could not be reached to install its dependencies). Items marked Unverified rest on general knowledge of Dio and rxdart that was not re-read on their pages. Check each item against the code in front of you; do not report one without pointing at the lines.

## Network calls and error mapping

- **Success means any 2xx, not only 200.** A check like `statusCode == 200` turns 201 Created and 204 No Content into failures. The server did the work, the app shows an error, and the user retries: duplicate records. (Dio accepts the whole 2xx range by default, so such a response reaches the check: Unverified.) Handle an empty body.
- **A catch-all around a `throw` replaces the specific error.** If a typed error is thrown inside a `try` that ends in `catch (e)`, the specific message is swallowed and the user sees "unexpected error". The same catch-all hides parsing bugs in the response mapper, with no log and no stack trace. Catch the typed error first, log unexpected ones with the stack, rethrow.
- **Error-body parsing that assumes a map.** Reading `data['Message']` throws a `TypeError` when the body is HTML or plain text (a proxy or gateway error page). A `TypeError` is an `Error`, not an `Exception`, so an `on Exception` handler lets it escape. Check `data is Map` and read the key your backend really sends.
- **Wrong class for the failure.** Mapping Dio's `connectionError` to "timeout" means "no internet" never shows; mapping `cancel` to a server error shows a message for something the app did on purpose. Cancellation should be silent.
- **401, 403 and expired session are different.** Collapsing them into one "unauthorized" error makes a 403 (signed in, not allowed) sign the user out. Keep three outcomes: refresh then retry, show "not allowed", sign out.
- **Deciding on sign-out by matching message text** (for example "contains 'expired'") signs people out when an unrelated message mentions the word, such as an expired invite link. Use status codes or error codes.
- **Auth handling in one place.** If one call style (GraphQL) reports auth failures to the app-wide handler and the other (REST) does not, half the app never signs out on a 401. Put it in the client's interceptor or link, not in each source class.
- **Unused parameters and unreachable branches in base helpers** (for example an `onInvalid` callback that only runs when something is thrown, while errors arrive as values). Callers think they handled a case they did not.

## GraphQL (Ferry and similar clients)

- **Errors arrive as values, not exceptions.** A Ferry `OperationResponse` carries `linkException` and `graphqlErrors`; code that only wraps the call in `try`/`catch` never sees them and shows empty or stale data. Check both fields before `data`.
- **Partial data with errors.** A response can contain data and errors together. Decide per screen whether that is a success; do not ignore the errors silently.
- **`CacheFirst` is the default for queries.** Pull-to-refresh and "load again" then return the old cached result without a request. The refetch must use `NetworkOnly` (or a policy chosen on purpose).
- **Objects without `id` are not normalized.** If a selection leaves out `id` (and the object has a `__typename`), a mutation does not update it elsewhere, and screens show old values until a refetch.
- **Cache survives sign-out.** If the client or its cache is not cleared or rebuilt on sign-out, the next user can see the previous user's data.
- **Open streams.** `request()` streams stay open; a Cubit that subscribes and never cancels keeps the request alive and rebuilds after it is closed.
- **Auth in one link.** A 401 handler written in each repository misses operations; use one link. Backends that answer unauthenticated calls with HTTP 200 and an error code need the GraphQL-error handler instead of the HTTP one.
- **Generated types leaking into the UI.** Ferry's `G...Data` classes in a Cubit state or widget tie the screen to one query shape; map to domain entities in the data layer.
- **Hand-edited or uncommitted generated files, or an out-of-date schema file.** The build then passes locally and fails in CI, or a removed backend field fails only at runtime.

## Sessions and sign-out

- **One refresh at a time.** Parallel requests that find an expired token must wait for one refresh (a lock or a queued interceptor), and the refresh call must use a client without the auth interceptor, or it waits for itself. The pattern is in `flutter-feature-notes` ("Token refresh and sessions").
- **Sign-out signal sent many times.** Five requests failing at once emit five events and five navigation resets. Emit once (ignore events while already signing out) and reset the flag after the next sign-in.
- **Events with no listener are lost.** A plain broadcast subject (rxdart `PublishSubject`) drops events that arrive before anyone listens, for example a 401 during start-up before the listener exists (Unverified: rxdart's docs were not re-read). Either read the session state when the listener starts, or hold the pending event until the first listener takes it; clear it on every sign-in, because a replayed old event would sign out the next session. Do not close a singleton bus.
- **Caches outlive the account.** A static in-memory cache is not cleared when the user signs out, so the next account can see the previous account's lists. Clear every cache, store and cubit that holds user data on sign-out.

## Cubits and base classes

- **Swallowed errors leave the UI loading.** A helper that wraps an API call in `try { ... } catch (e) { log(e); }` never emits a failure state when the success mapper throws; the spinner runs forever. Emit a failure state for any error, with the stack in the log.
- **Emit after `await`.** Check `isClosed` again after each `await`, not only at the start of the method; a screen can close while the request runs.
- **Typed errors lost on the way to the UI.** Throwing `Exception(message)` from a paging helper turns a typed error into text, so the list cannot tell "no internet" from "forbidden", and showing it prints "Exception: ..." as a prefix. Keep the error type in the state.

## Paging, search and caches

- **Cache hydration that disables loading.** If a paged cubit fills `items` from a cache in its constructor but leaves the next-page key empty, a guard like "not the first load, no next key, return" makes the first `fetchNext()` do nothing: the list stays on stale data and cannot page. Treat cached items as provisional: refresh after hydrating, or track "loaded from the network" in its own flag instead of `items.isEmpty`.
- **Cache keys that collide.** A key built from the cubit's runtime type shares one cache between two screens or two filters using the same cubit type. Include the owner (user id), the filter and the search in the key, or let the caller pass one.
- **Cancelling only ignores the result.** Marking a request cancelled and dropping its answer does not stop the request; it still uses data and server time. Pass a real cancel token to the client if that matters.
- **Search and filter events that overwrite each other.** A handler that copies `event.filters` into state wipes the chosen filters whenever the user types in the search box, because that event carries `null` filters. Merge with the current state, and use typed filters, not `List<dynamic>`.
- **Documentation that disagrees with the code.** A README that says the paged cubit debounces search while the debounce lives in a separate bloc, and a guide that shows a constructor parameter that does not exist: run the drift check from `flutter-release` on docs and code.

## If the code under review is a shared package

- Dependencies that nothing imports, exact version pins (`pkg: 3.4.1`, no caret) that clash in consumer apps, and a pre-release generator in `dev_dependencies`.
- App-specific values (sign-in client IDs, backend keys) inside a general base package.
- No tests, a changelog that stops before the package version, and a `homepage` that names another repo.
- Machine files committed: `local.properties` with SDK paths and a user name, `.gradle/`, `Pods/`, `xcuserdata/`. See `flutter-git`.
