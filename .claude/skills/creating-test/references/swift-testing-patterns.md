# Swift Testing Patterns

Reference for writing tests using the modern Swift Testing framework.

---

## Basic Test Structure

```swift
import Testing
@testable import SwiftfulStarterProject

struct {ClassName}_Tests {

    @Test
    func doSomethingReturnsExpectedResult() async throws {
        // Given
        let sut = MyClass()

        // When
        let result = await sut.doSomething()

        // Then
        #expect(result == expected)
    }
}
```

---

## Assertions

| Swift Testing | Purpose |
|---------------|---------|
| `#expect(a == b)` | Equality |
| `#expect(value)` | Truthiness |
| `#expect(!value)` | Falsy |
| `#expect(array.isEmpty)` | Empty check |
| `#expect(array.count == 3)` | Count check |
| `#expect(throws: SomeError.self) { try work() }` | Error thrown |
| `#expect(Bool(false), "Should not reach")` | Force fail |

---

## Testing @MainActor Code

Most managers and presenters are `@MainActor` — mark the test accordingly:

```swift
@Test
@MainActor
func loadDataPopulatesItems() async {
    // Given
    let manager = SomeManager(service: MockSomeService(), logManager: nil)

    // When
    await manager.loadData()

    // Then
    #expect(!manager.items.isEmpty)
}
```

---

## Testing with Mock Services

Inject mock services to isolate the unit under test:

```swift
@Test
@MainActor
func loadDataWithErrorServiceSetsError() async {
    // Given
    let mockService = MockSomeService(shouldThrow: true)
    let manager = SomeManager(service: mockService, logManager: nil)

    // When
    await manager.loadData()

    // Then
    #expect(manager.items.isEmpty)
    #expect(manager.error != nil)
}
```

---

## Awaiting Async Callbacks

### Using confirmations (structured async)

```swift
@Test
@MainActor
func searchTriggersUpdate() async {
    let manager = SearchManager(service: MockSearchService())

    await confirmation { confirm in
        _ = withObservationTracking {
            manager.results
        } onChange: {
            confirm()
        }

        await manager.search("swift")
    }

    #expect(!manager.results.isEmpty)
}
```

### Using continuations (unstructured tasks)

```swift
@Test
@MainActor
func taskCompletes() async {
    let manager = SomeManager(service: MockSomeService())

    await withCheckedContinuation { continuation in
        _ = withObservationTracking {
            manager.results
        } onChange: {
            continuation.resume()
        }

        manager.startBackgroundTask()
    }

    #expect(manager.results.count > 0)
}
```

---

## Testing Cancellation

```swift
@Test
func taskCancellation() async {
    let task = Task {
        try await longRunningOperation()
    }

    task.cancel()

    do {
        try await task.value
        #expect(Bool(false), "Should have thrown")
    } catch is CancellationError {
        // Expected
    }
}
```

---

## Testing Memory Management

```swift
@Test
func noRetainCycles() async {
    weak var weakRef: SomeManager?

    do {
        let manager = SomeManager(service: MockSomeService())
        weakRef = manager
        await manager.startTask()
    }

    #expect(weakRef == nil, "Retain cycle detected")
}
```

---

## Serial Execution (Flaky Test Fix)

When tests need deterministic ordering with `withMainSerialExecutor` from [swift-concurrency-extras](https://github.com/pointfreeco/swift-concurrency-extras):

```swift
import ConcurrencyExtras

@Suite(.serialized)
@MainActor
final class SomeManagerTests {

    @Test
    func isLoadingState() async throws {
        try await withMainSerialExecutor {
            let manager = SomeManager(service: MockSomeService())

            let task = Task { await manager.loadData() }
            await Task.yield()

            #expect(manager.isLoading == true)

            await task.value
            #expect(manager.isLoading == false)
        }
    }
}
```

---

## XCTest Migration Reference

| XCTest | Swift Testing |
|--------|---------------|
| `class Tests: XCTestCase` | `struct Tests` with `@Test` |
| `func testName()` | `func name()` with `@Test` |
| `XCTAssertEqual(a, b)` | `#expect(a == b)` |
| `XCTAssertTrue(x)` | `#expect(x)` |
| `XCTFail()` | `#expect(Bool(false))` |
| `expectation(description:)` | `confirmation { confirm in }` |
| `await fulfillment(of:)` | `await confirmation { }` |
