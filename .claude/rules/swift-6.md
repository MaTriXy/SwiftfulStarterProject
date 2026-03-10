# Swift 6 & Code Style

Rules for Swift 6 concurrency, general Swift conventions, and project-specific patterns.

## General Swift Conventions

### Code Organization

- One type per file — file name matches type name
- `// MARK: -` for section organization within files
- `private` by default — only expose what's needed

### Safety

- `guard let` / `if let` over force unwrapping — NEVER force unwrap without a documented reason
- `[weak self]` in escaping closures on reference types (classes, actors)
- No `[weak self]` needed in `Task { }` inside struct methods or `@MainActor` classes that control the task lifecycle
- NEVER initialize optional variables with `= nil` — it is redundant. Write `var name: String?` not `var name: String? = nil`

### Logging

- NEVER use `print()` — use `LogManager` for all output
- No TODOs or placeholder comments in generated code

### Logic

- Prefer ternary operators for simple evaluations: `let value = condition ? a : b`
- Prefer readable `guard` statements for early exits
- Use `if let` for optional unwrapping when you need the value in a scoped block
- Use `if/else` as the last resort for complex branching

### Functions

- Break larger logic into smaller functions, even if called once — the function name should be self-documenting
- Prefer descriptive function names over comments explaining what the code does

### Naming Conventions

- Avoid non-inclusive terms that trigger SwiftLint's `inclusive_language` rule — never use `master`, `slave`, `whitelist`, `blacklist` in declarations. Use alternatives like `primary`, `main`, `allowList`, `denyList`.
- **Views** — sections as computed properties: `headerSection`, `scrollViewSection`, `profileImageSection`
- **Views** — actions delegate to Presenter: `onButtonPressed`, `onItemSelected`
- **Presenters** — lifecycle: `onViewFirstAppear`, `onViewAppear`, `onFirstTask`
- **Presenters** — user actions: `onButtonPressed`, `onSaveButtonPressed`, `onBackButtonPressed`
- **Managers/Interactors** — non-user-facing operations: `fetchAllUsers`, `currentUserId`, `getAllAvatars`, `saveDocument`

### Types

- Value types (structs, enums) preferred over reference types where appropriate
- Use `@Observable` classes only when identity/shared state is needed (Presenters, Managers)
- Custom error enums with `LocalizedError` conformance — include `errorDescription`

## Models

IMPORTANT: Every model must include these:

- `struct` with `Codable`, `Sendable` conformance
- `StringIdentifiable` conformance (from IdentifiableByString package)
- `enum CodingKeys: String, CodingKey` with `snake_case` raw values
- `eventParameters: [String: Any]` computed property for analytics
- `static var mock: Self` and `static var mocks: [Self]` for previews and testing
- All properties `var` and optional where possible for flexible initialization

## MainActor

- `@MainActor` is correct on Presenters, Managers, Interactors, DependencyContainer, and all UI-touching code
- NEVER add `@MainActor` to utility functions, pure computation, or networking code
- NEVER use `DispatchQueue.main.async` — use `@MainActor` + async/await
- NEVER use `MainActor.run {}` when `@MainActor` function isolation already applies
- For callbacks from non-MainActor code, use `@MainActor @Sendable` closure parameters

## Task Management

- `.task { }` on views auto-cancels on disappear — should call into the Presenter: `.task { await presenter.onFirstTask() }`
- `.task(id: value)` restarts when `value` changes — use for value-dependent fetches
- Store `Task` references when manual cancellation is needed, cancel in `deinit` or `logOut()`
- Check `Task.isCancelled` in long loops: `guard !Task.isCancelled else { return }`
- Use `Task.sleep(for: .seconds(1))` — NEVER `Task.sleep(nanoseconds:)`

## Sendable

- Immutable value types (structs with `let` properties, enums) are implicitly `Sendable` — no explicit conformance needed
- `@MainActor` types are automatically `Sendable` — do not add redundant conformance
- NEVER use `@unchecked Sendable` as a quick fix — fix the actual type safety
- Use `@Sendable` on closures that cross isolation boundaries (e.g., `Task { }`, `onTermination`)
- When forced to use `@preconcurrency` or `@unchecked Sendable`, add a comment explaining why

## Structured Over Unstructured

- Prefer `async let` for parallel independent work: `async let a = fetchA(); async let b = fetchB(); let (ra, rb) = await (try a, try b)`
- Prefer `TaskGroup` when the number of concurrent tasks is dynamic
- Use `Task { }` only for fire-and-forget from synchronous context (e.g., saving to cache)
- NEVER use `Task.detached` — prefer `nonisolated` functions to escape actor isolation
- NEVER block async code with `DispatchSemaphore` or `DispatchGroup` — causes deadlocks

## Actors

- Actors are reentrant — state can change at any `await` point. Re-validate state after every suspension
- Don't create stateless actors — use `nonisolated` async functions instead
- `nonisolated` functions on actors cannot access mutable state — use for pure computation only

## Testing

- Use Swift Testing framework (`@Test`, `#expect`, `@Suite`) — not XCTest for new tests
- `@MainActor @Test` for tests that touch MainActor-isolated code
- Use `#expect(throws:)` instead of `do/catch` for error assertions
