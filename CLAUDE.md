# SwiftfulStarterProject

iOS app using SwiftUI with VIPER + RIBs architecture. Swift 6, async/await, @Observable.

## Architecture

```
View → Presenter → Interactor → Manager (never skip layers)
```

- **View**: SwiftUI view, owns a `@State var presenter`
- **Presenter**: `@Observable @MainActor`, all business logic, calls interactor/router
- **Interactor**: Protocol extending `GlobalInteractor`, implemented on `CoreInteractor`
- **Router**: Protocol extending `GlobalRouter`, implemented on `CoreRouter`
- **Manager**: Owns data/services, injected via `Dependencies.swift`
- **Component**: Dumb UI — no business logic, no Presenters, all data injected

Every new screen registers in CoreRouter, CoreInteractor, and CoreBuilder.

## Build Configurations

- **Mock**: No Firebase, mock data. Use for 90% of development.
- **Development**: Real Firebase, dev credentials.
- **Production**: Real Firebase, prod credentials.

## File Creation

This project uses Xcode 16+ File System Synchronization. Files created in `SwiftfulStarterProject/` automatically appear in Xcode — no manual project file edits needed.

## Key Conventions

- `.asButton()` instead of `Button()` wrapper
- `ImageLoaderView` instead of `AsyncImage`
- `router.showAlert()` instead of `.alert()` modifier
- `LogManager` instead of `print()`
- No `Task.detached`, no `DispatchQueue`, no `@unchecked Sendable`
- `@MainActor` only on UI-related code (Presenters, Managers, Interactors)
- All Presenter/Manager methods must track analytics events

## Rules (always loaded)

Detailed conventions are in `.claude/rules/`:

- `viper-architecture.md` — VIPER layers, data flow, RIBs registration
- `project-structure.md` — folder layout, managers, naming conventions
- `swift-6.md` — concurrency, code style, model requirements
- `swiftui-patterns.md` — UI patterns, property wrappers, deprecated APIs
- `manager-lifecycle.md` — registration, login/logout, analytics
- `commit-rules.md` — prefix system, message format

## Skills (loaded on demand)

Scaffolding templates in `.claude/skills/`:

- `creating-screen` — VIPER screen (View, Presenter, Router, Interactor)
- `creating-manager` — Manager with service protocol + Mock/Prod
- `creating-component` — Dumb UI component
- `creating-model` — Codable/Sendable model with mocks
- `creating-test` — Swift Testing unit test
- `creating-module` — Top-level navigation module
- `creating-paywall` — Paywall with AB test variants
- `creating-ab-test` — AB test service + mock
- `creating-view-modifier` — ViewModifier + View extension
- `creating-extension` — Type extension file
- `adding-package` — SPM package integration
- `adding-deep-link` — Deep link route
- `refactoring-screen` — Rename a VIPER screen

## Agents

- `feature-planner` — Plans architecture before implementation (read-only, Opus)
- `scaffolder` — Creates screens/managers/components with RIBs wiring (Sonnet)
- `code-reviewer` — Reviews code against project rules (read-only, Sonnet)

## Workflow

1. **Plan first** for non-trivial features (use feature-planner or plan mode)
2. **Use skills** when creating new files — they have the exact templates
3. **Use scaffolder** for multi-file creation (4+ files with RIBs wiring)
4. **Commit often** with the prefix system from commit-rules.md
5. **Review before shipping** with code-reviewer
