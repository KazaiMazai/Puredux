# Dependency Injection

Dealing with dependencies in Puredux

## Overview

Dependencies in an application refer to the types and functions that interact with external systems or components beyond your control.

Puredux is designed to offload all "side effects" to the application's "shell," allowing the core logic to remain as pure and isolated as possible.

However, in practice, maintaining a completely pure core can still be challenging. This includes handling things like Date, UUID, Locale, feature flags, and configuration.

In such cases, Dependency Injection becomes a powerful and convenient tool for managing external interactions while preserving the core's integrity.

## Dependencies Injection in Puredux

Puredux splits dependencies into two categories:

- Store Injection
- Dependency Injection

Although both are essentially dependencies, they are handled separately because they serve different purposes, and we want to ensure they remain distinct.

**Store Injection** is used to conveniently obtain store instances in the UI layer of the application.

**Dependency Injection** is used inside the store's reducers to power the application's core logic.

### Stores Injection

Use `@StoreEntry` in the `SharedStores` extension to inject the store instance:


```swift
extension SharedStores {
   @StoreEntry var root = StateStore<AppRootState, Action>(....)  
}
```

The `@StoreOf` property wrapper can be used to obtain the injected store instance:


```swift
struct MyView: View {
    @State @StoreOf(\.root)
    var store: StateStore<AppRootState, Action>
    
    var body: some View {
       // ...
    }
}
```

Alternatively, you can access it directly:

```swift
let store = StoreOf[\.root]
```

If you need to bypass the store's entry point and set the store dependency directly, you can do so via:

```swift

SharedStores[\.root] = StateStore<AppRootState, Action>(....)

```

### Dependency Injection

Use `@DependencyEntry` in the `Dependencies` extension to inject the dependency instance:

```swift
extension Dependencies {
   @DependencyEntry var now = { Date() }  
}
```

Then it can be used in the app reducer:

```swift
struct AppState {
    private var currentTime: Date?

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateTime:
            let now = Dependency[\.now]
            currentTime = now()
        default:
            break
        }
    }
}

```

If you need to bypass the dependency's entry point and set it directly, you can do so via:


```swift

Dependencies[\.now] = { .distantPast }

```

## Discussion 

By implementing a clear separation of concerns between store injection and dependency injection, we gain significant control over their lifecycle and usage:

- Clear Distinction Between Store Injection and Dependency Injection: This separation allows for the swift identification and correction of any misuse or misconfiguration of store hierarchy.

- `StoreEntry` and `DependencyEntry`: These constructs help to clearly define and locate the entry points for both stores and dependencies. This visibility simplifies debugging and maintenance, as developers can quickly trace where and how dependencies and stores are being injected into the application.

- Read-Only Access with `Dependency` and `StoreOf`: These mechanisms provide controlled, read-only access to the dependency injection containers. By restricting modification capabilities, they help maintain the integrity of the state and dependencies throughout the app, reducing the risk of unintended misuse

- Specialization of `StoreO`f: This property wrapper is specifically designed to support only `StateStore` types, which are responsible for owning the state. 

- Controlled Access with `Dependencies` and `SharedStores`: These tools offer read and write access to the dependency injection containers, but within a confined scope of the application. This limitation ensures that modifications to dependencies and stores are kept localized, reducing the risk of unintended changes.
