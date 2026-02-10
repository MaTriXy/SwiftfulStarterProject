# VIPER + RIBs Architecture

This project uses VIPER per screen with a single RIB (CoreRouter, CoreInteractor, CoreBuilder) for the entire app.

## Data Flow

IMPORTANT: Never skip layers. This is the strict data flow:

```
View → Presenter → Interactor → Manager
View ← Presenter ← Interactor ← Manager
```

- View displays data from Presenter and calls Presenter methods
- Presenter calls Interactor for data and Router for navigation
- Interactor accesses Managers via DependencyContainer
- Router handles navigation only

## View Layer

- `@State var presenter: HomePresenter` — holds the Presenter (not `@StateObject`, not `@ObservedObject`)
- `@State private var ...` — allowed for local UI animation state only
- NEVER put business logic in button closures — call a Presenter method instead
- NEVER access Interactors or Managers directly

## Presenter Layer

- `@Observable @MainActor class HomePresenter`
- Owns ALL business logic and screen state
- Calls `interactor` for data, `router` for navigation
- NEVER accesses Managers directly — always go through Interactor
- Analytics are tracked here in the Presenter — NEVER in the View
- Every user-facing method MUST track analytics via `interactor.trackEvent(event:)`

## RIBs Architecture

The app is organized into RIBs (Router, Interactor, Builder) modules. Currently there is one RIB — Core (CoreRouter, CoreInteractor, CoreBuilder) — but the app can be split into multiple RIBs (e.g., OnboardingRouter/OnboardingInteractor, TabBarRouter/TabBarInteractor). Each RIB owns a set of screens and their shared routing/data methods.

## Router and Interactor Are Protocols

Each screen's Presenter holds `router` and `interactor` as protocol types (e.g., `HomeRouter`, `HomeInteractor`). The actual implementations are extensions on the RIB's concrete class (e.g., `CoreRouter`, `CoreInteractor`). NEVER add a method to a screen's protocol that won't be implemented on the RIB's Router/Interactor. Only declare methods that will exist as extensions on the concrete RIB class.

## Router Layer

- Protocol extending `GlobalRouter`, implemented by `CoreRouter`
- ALL navigation uses SwiftfulRouting: `router.showScreen()`, `router.showAlert()`, `router.showModule()`
- Before creating a new route method, search for existing `func show[ScreenName]` in the codebase
- Router protocol must declare all methods the screen needs, even if the CoreRouter extension exists elsewhere
- NEVER duplicate CoreRouter extension implementations — reuse existing ones

## Interactor Layer

- Protocol extending `GlobalInteractor`, implemented by `CoreInteractor`
- Data access only — resolves Managers from `container`
- No UI logic, no business logic, no navigation
- May chain calls across multiple managers (e.g., get userId from AuthManager then pass to another manager)

## Components (Reusable Views)

Components are NOT screens. They are child views used WITHIN screen Views. A screen View composes Components by passing data from the Presenter down and wiring closures back to Presenter methods.

IMPORTANT: Components are DUMB UI. They receive data and fire callbacks. Nothing else.

- NO `@State` for data (only for local UI animations)
- NO `@Observable` objects or Presenters
- ALL data injected via init — make properties optional for flexibility
- ALL actions injected as closures: `var onTap: (() -> Void)?`
- ALL loading/error states injected as parameters
- Create multiple `#Preview` blocks (full data, partial, loading, empty)

## Registration

New screens register in 3 places within their RIB:
1. **Router extension** (e.g., `CoreRouter`) — `func showScreenName()` navigation method
2. **Interactor extension** (e.g., `CoreInteractor`) — data access methods the screen needs
3. **Builder** (e.g., `CoreBuilder`) — `func screenNameView(router:)` factory method

If the app has multiple RIBs, register in the RIB that owns the screen. Check existing screens in the same flow to determine which RIB to use.
