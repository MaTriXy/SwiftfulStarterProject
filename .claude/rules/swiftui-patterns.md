# SwiftUI Patterns & Modern APIs

Rules for building SwiftUI views and components in this project.

## UI Conventions

### Buttons
- ALWAYS use `.asButton()` instead of wrapping in `Button()` — never use `Button()` directly
- `.asButton(.press)` — scale feedback, default for most interactive elements
- `.asButton(.tap)` — no visual feedback, replaces `onTapGesture`
- `.asButton(.highlight)` — accent overlay, rarely used
- `.asButton(.opacity)` — dimming effect, rarely used
- `.callToActionButton()` and `.badgeButton()` are convenience modifiers — use them or build custom button UI directly, whichever is easier
- `.tappableBackground()` before `.asButton()` if the view has transparent areas
- Image-only buttons must always include an accessible text label

### Images
- ALWAYS use `ImageLoaderView(urlString:)` for URL images — never `AsyncImage`
- `ImageLoaderView` handles resizing internally — just apply `.frame()` and optionally `.clipShape()`

### Layout
- Prefer `frame(maxWidth:)` or `frame(maxHeight:)` with alignment over `Spacer()`
- Use spacing parameters in stacks: `VStack(spacing: 12)` instead of extra padding
- Standard spacing values: 4, 8, 12, 16, 24
- `.ignoresSafeArea()` on full-bleed background images only
- Use `overlay`/`background` for decorating a primary view (child adopts parent's size) — use `ZStack` for composing peer views that jointly define layout

### Text
- Dynamic Type fonts: `.largeTitle`, `.title3`, `.headline`, `.body`, `.subheadline`, `.caption`
- `.font(.system(size:))` rarely — common for system icon sizing (exact, not resizable for accessibility) but not for body text
- `.lineLimit(1).minimumScaleFactor(0.3)` to prevent truncation on single-line text
- `.foregroundStyle(.secondary)` for de-emphasized text — not `.opacity()`
- Use `localizedStandardContains()` instead of `contains()` for user-input search filtering — handles diacritics and case

### Lists
- `.removeListRowFormatting()` available to strip default list row styling — use when the design calls for custom row backgrounds
- `ForEach` must use stable identifiers — never `.indices` for dynamic content

### Common Containers
- `LazyVStack` / `LazyHStack` — use inside `ScrollView` for large or dynamic content (loads views on demand)
- `VStack` / `HStack` — use for small, fixed-size layouts where all items should load immediately
- `List` — use for settings-style screens with sections, swipe actions, and built-in styling
- `GeometryReader` — use sparingly, mainly when you need the parent's exact size. Prefer `containerRelativeFrame()`, `visualEffect()`, or `onGeometryChange(for:)` (iOS 17+) when possible
- `.contentTransition(.numericText())` — animate text value changes (counters, timers). Also supports `.interpolate` for general text morphing and `.symbolEffect` for SF Symbol animations

## View Composition

- For sections only used within one screen, use computed properties or `@ViewBuilder` functions — keeps the code local and simple
- Extract into a separate `struct` only when the section is a reusable component used across multiple screens
- Generic components use `@ViewBuilder let content: Content` for flexible injection
- Keep `body` pure — no side effects, no object creation, no heavy computation
- Use `.opacity()` or `.overlay()` for state changes on the same view — use `if/else` or `.ifSatisfiesCondition()` only for fundamentally different views

## Animation

- Prefer transforms for animations (`scaleEffect`, `offset`, `rotationEffect`) — these are GPU-accelerated. Avoid animating `frame` or `padding` (triggers layout recalculation)
- Transitions require animation context OUTSIDE the conditional — place `withAnimation` or `.animation()` on the parent, not inside the `if` block
- `.phaseAnimator` (iOS 17+) for multi-step animation sequences — replaces `DispatchQueue.asyncAfter` chains
- Guard before assigning state in `onChange`/`onReceive` — check `if newValue != oldValue` to avoid redundant view updates
- In scroll handlers and hot paths, only update state when crossing a threshold — not on every pixel

## Property Wrappers

| Wrapper | Use When |
|---------|----------|
| `@State var` | Holding the Presenter, or owning an `@Observable` class |
| `@State private var` | Local UI animation state only |
| `@Binding var` | Child needs to modify parent's state (rare in VIPER — prefer injecting a value + closure instead) |
| `@Bindable var` | Injected `@Observable` needing `$` bindings (rarely needed in VIPER) |
| `let` / `var` | `let` is ok but prefer `var` and optional for injected data — allows customizing the implicit init with defaults |


## Previews

- Create multiple `#Preview` blocks: full data, partial data, loading, empty
- Name each preview: `#Preview("Full Data") { ... }`
- Use `DevPreview.shared.container()` for dependency injection
- Wrap in `RouterView` when the view needs routing context

## Lifecycle Modifiers

- `.onAppear { }` for synchronous work on every appearance
- `.task { }` for async work (auto-cancelled on disappear)
- `.task(id: value)` for value-dependent async tasks
- `.onFirstAppear { }` for one-time synchronous setup (from SwiftfulUI)
- `.onFirstTask { }` for one-time async setup (from SwiftfulUI)
- `.screenAppearAnalytics(name:)` on every screen view

## ScrollView (Modern APIs — iOS 17+)

- `.scrollIndicators(.hidden)` — hide scroll bars (not `showsIndicators: false`)
- `.scrollPosition(id: $selection)` — track/control visible item via binding (preferred over `ScrollViewReader`)
- `.scrollTargetLayout()` + `.scrollTargetBehavior(.viewAligned)` — snap-to-item scrolling
- `.scrollTargetLayout()` + `.scrollTargetBehavior(.paging)` — full-page paging (use with `.containerRelativeFrame(.horizontal)` on each item)
- `.scrollTransition(.interactive)` — animate items as they enter/leave the viewport (scale, opacity, etc.)
- `.containerRelativeFrame(.horizontal)` — size items relative to the scroll container
- `.scrollClipDisabled()` — allow content to visually overflow the scroll bounds
- `.contentMargins()` — add margins to scroll content without affecting the scroll indicator

## Deprecated API Replacements

IMPORTANT: Never use deprecated APIs. Always use the modern replacement.

| Deprecated | Use Instead |
|------------|-------------|
| `foregroundColor()` | `foregroundStyle()` |
| `NavigationView` / `NavigationStack` | SwiftfulRouting (`RouterView`, `router.showScreen()`) |
| `ObservableObject` + `@StateObject` | `@Observable` + `@State` |
| `@EnvironmentObject` | `@Environment(MyType.self)` with `@Observable` |
| `onChange(of:) { value in }` | `onChange(of:) { old, new in }` or `onChange(of:) { }` |
| `ScrollView(showsIndicators: false)` | `.scrollIndicators(.hidden)` |
| `String(format:)` for display | `Text(value, format: .number)` |
| `fontWeight(.bold)` | `bold()` |
| `.animation(.spring)` (no value) | `.animation(.spring, value: flag)` |
| `AnyView(...)` | `@ViewBuilder` functions |
| `.font(.system(size: 24))` for body text | `.font(.title)` (Dynamic Type) |
| `DispatchQueue.asyncAfter` chains | `.phaseAnimator` (iOS 17+) |
