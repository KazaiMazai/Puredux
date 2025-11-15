<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Sources/Puredux/Documentation.docc/Resources/Logo-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Sources/Puredux/Documentation.docc/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/Puredux/blob/main/Sources/Puredux/Documentation.docc/Resources/Logo.svg">
</picture>


[![CI](https://github.com/KazaiMazai/Puredux/workflows/Tests/badge.svg)](https://github.com/KazaiMazai/Puredux/actions?query=workflow%3ATests)


Puredux is an architecture framework for SwiftUI and UIKit designed to
streamline state management with a focus on unidirectional data flow and separation of concerns.

- **Unidirectional MVI Architecture**: Supports a unidirectional data flow to ensure predictable state management and consistency.
- **SwiftUI and UIKit Compatibility**: Works seamlessly with both SwiftUI and UIKit, offering bindings for easy integration.
- **Single Store/Multiple Stores Design**: Supports both single and multiple store setups, as well as tree-of-stores architectures for flexible state management in apps of any size and complexity.
- **Separation of Concerns**: Emphasizes separating core business logic, side effects, and UI.
- **Declarative Side Effects**: Separating **what** should be done from **how** it should be done.
- **Performance Optimization**: Offers granular performance tuning with state deduplication, debouncing, and offloading heavy UI-related work to the background.

## Why

Develop an application using Puredux, incorporating pure state, actions, and reducers, with a clean stateless UI, while managing side effects separately.

## Table of Contents

- [Getting Started](#getting-started)
  * [Basics](#basics)
  * [Store Definitions](#store-definitions)
  * [UI Bindings](#ui-bindings)
- [Hierarchical Stores Tree Architecture](#hierarchical-stores-tree-architecture)
- [Side Effects](#side-effects)
  * [Async Actions](#async-actions)
  * [Declarative Side Effects](#declarative-side-effects)
- [Dependency Injection](#dependency-injection)
  * [Store Injection](#store-injection)
  * [Dependency Injection](#dependency-injection-1)
- [Performance](#performance)
  * [Reducers Execution](#reducers-execution)
  * [QoS Tuning](#qos-tuning)
  * [Deduplicated State Updates](#deduplicated-state-updates)
  * [UI Updates Debouncing](#ui-updates-debouncing)
  * [Two-step UI Updates with Background Offloading](#two-step-ui-updates-with-background-offloading)
  * [Granular UI Updates](#granular-ui-updates)
- [Installation](#installation)
  * [Swift Package Manager.](#swift-package-manager)
- [Documentation](#documentation)
- [Licensing](#licensing)

## Getting Started

### Basics

At its core, Puredux follows a predictable state management pattern that consists of the following key components:

- State: A type that represents the entire application state or a portion of it.
- Actions: Events that describe possible changes in the system, which lead to state mutations.
- Reducer: A function that dictates how state changes in response to specific actions.
- Store: The central hub where:
    - Initial state and reducers are defined.
    - Actions are dispatched to trigger state changes.
    - New state values are propagated to any observers or views.
  
<details><summary>Click to expand</summary>
<p>   
 
```text
 
                +-----------------------------------------+
                |                  Store                  |
                |                                         |
                |  +-----------+   +-------------------+  |
                |  |  Reducer  |<--|   Current State   |  |
      New State |  +-----------+   +-------------------+  |  Actions
    <-----------+      |                            A     |<----------+
    |           |      |                            |     |           A
    |           |      V                            |     |           |
    |           |  +-------------------+            |     |           |
    |           |  |     New State     |------------+     |           |
    |           |  +-------------------+                  |           |
    |           |                                         |           |
    |           +-----------------------------------------+           |
    |                                                                 |
    |                                                                 |
    |                                                                 |
    |           +----------------+                +---+----+          |
    V Observer  |                |   Async Work   |        |          |
    +---------->|  Side Effects  |--------------->| Action |--------->|
    |           |                |     Result     |        |          |
    |           +----------------+                +----+---+          |
    |                                                                 |
    |           +----------------+                   +---+----+       |
    V Observer  |                |       User        |        |       |
    +---------->|       UI       |------------------>| Action |------>+
                |                |   Interactions    |        |
                +----------------+                   +----+---+
        
```
</p>
</details>    
    
    
### Store Definitions

```swift
// Let's cover actions with a protocol

protocol Action { }

struct IncrementCounter: Action {
    // ...
}

// Define root AppState

struct AppState {
    // ...
    
    mutating func reduce(_ action: Action) {
        switch action {
        case let action as IncrementCounter:
            // ...
        default:
            break
        }
    }
}

// Inject root store

extension SharedStores {
    @DependencyEntry var root = StateStore<AppState, Action>(AppState()) { state, action in
        state.reduce(action)
    }
}
```

### UI Bindings

Puredux can integrate with SwiftUI to manage both global app state and local states. 

```swift

// View might need a local state that we don't need to share with the whole app 

struct ViewState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}

// In your SwiftUI View, you can combine the app's root store with local view-specific states.
// This allows the view to respond dynamically to both app-level and view-level state changes.

struct ContentView: View  {
    // We can take an injected root store,
    // create a local state store and merge them together.
    @State var store: StoreOf(\.root).with(ViewState()) { state, action in 
        state.reduce(action) 
    }
    
    @State var viewState: (AppState, ViewState)?
    
    var body: some View {
        MyView(viewState)
            .subscribe(store) { viewState = $0 }
            .onAppear {
                dispatch(SomeAction())
            }
    }
}

```
<details><summary>Click to expand UIViewController example</summary>
<p>
 
```swift

// We can do the same thing almost with the same API for UIKit view controller:

struct MyScreenState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}

final class MyViewController: ViewController {
    var store: StoreOf(\.root).with(MyScreenState()) { state, action in 
        state.reduce(action) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        subscribe(store) { [weak self] in
            // Handle updates with the derived props
            self?.updateUI(with: $0)
        }
     }
     
     private func updateUI(with state: (AppState, MyScreenState)) {
         // Update UI elements with the new view state
     }
}

```
</p>
</details>

## Hierarchical Stores Tree Architecture

Puredux allows you to build a hierarchical store tree, facilitating the development of applications where state can be either shared or isolated, while keeping state mutations predictable.

Actions propagate upstream from child stores to the root store, while state updates flow downstream from the root store to child stores, and ultimately to store observers.

The store tree hierarchy ensures that business logic is fully decoupled from the UI layer. This allows for a deep, isolated business logic tree, while maintaining a shallow UI layer focused solely on its responsibilities.

Make your app driven by business logic, not by the view hierarchy.

Puredux provides flexibility in structuring your app with the following options:

- Single Store
- Multiple Independent Stores
- Multiple Store Tree

The multiple store tree is a flexible design that handles complex applications by organizing stores in a hierarchical structure. This approach offers several benefits:

- **Feature scope isolation**: Each feature or module has its own dedicated store, preventing cross-contamination of state.
- **Performance optimization**: Stores can be made pluggable and isolated, reducing the overhead of managing a large, monolithic state and improving performance.
- **Scalable application growth**: You can start with a simple structure and add more stores as your application grows, making this approach sustainable for long-term development.


```swift
// Root Store Config

let root = StateStore<AppState, Action>(AppState()) { state, action in 
    state.reduce(action) 
} 
.effect(\.effectState) { state, dispatch in
    Effect {
        // ...
    }
}

// Feature One Config

let featureOne = root.with(FeatureOne()) { appState, action in 
    state.reduce(action) 
}
.effect(\.effectState) { state, dispatch in
    Effect {
        // ...
    }
}

// Feature Two Config with 2 screen stores

let featureTwo = root.with(FeatureTwo()) { state, action in
    state.reduce(action)
}
.effect(\.effectState) { state, dispatch in
    Effect {
        // ...
    }
}

let screenOne = featureTwo.with(ScreenOne()) { state, action in 
    state.reduce(action) 
}
.effect(\.effectState) { state, dispatch in
    Effect {
        // ...
    }
}

let screenTwo = featureTwo.with(ScreenTwo()) { state, action in 
    state.reduce(action) 
}

```

We can connect UI to any of the stores and will end up with the following hierarchy:

<details><summary>Click to expand</summary>
<p>

 
```text
              +----------------+    +--------------+
              | AppState Store | -- | Side Effects |
              +----------------+    +--------------+
                    |
                    |
       +------------+-------------------------+
       |                                      |
       |                                      |
       |                                      |
       |                                      |
 +------------------+                     +------------------+    +--------------+
 | FeatureOne Store |                     | FeatureTwo Store | -- | Side Effects |
 +------------------+                     +------------------+    +--------------+
    |         |                               |
 +----+  +--------------+                     |
 | UI |  | Side Effects |        +------------+------------+
 +----+  +--------------+        |                         |
                                 |                         |
                                 |                         |
                                 |                         |
                          +-----------------+         +-----------------+
                          | ScreenOne Store |         | ScreenTwo Store |
                          +-----------------+         +-----------------+
                             |         |                 |
                          +----+  +--------------+    +----+
                          | UI |  | Side Effects |    | UI |
                          +----+  +--------------+    +----+
```

</p>
</details>

## Side Effects

In the context of UDF architecture, "side effects" refer to asynchronous operations that interact with external systems or services. These can include:

- Network Requests: Fetching data from web services or APIs.
- Database Fetches: Retrieving or updating information in a database.
- I/O Operations: Reading from or writing to files, streams, or other I/O devices.
- Timer Events: Handling delays, timeouts, or scheduled tasks.
- Location Service Callbacks: Responding to changes in location data or retrieving location-specific information.

In the Puredux framework, managing these side effects is achieved through two main mechanisms:
- Async Actions
- State-Driven Side Effects

### Async Actions

Async Actions are designed for straightforward, fire-and-forget scenarios. They allow you to initiate asynchronous operations and integrate them seamlessly into your application logic. These actions handle tasks such as network requests or database operations, enabling your application to respond to the outcomes of these operations.
Define actions that perform asynchronous work and then use them within your app.


```swift

// Define result and error actions:

struct FetchDataResult: Action {
    // ...
}

struct FetchDataError: Action {
    // ...
}

// Define async action:

struct FetchDataAction: AsyncAction {

    func execute(completeHandler: @escaping (Action) -> Void) {  
        APIClient.shared.fetchData {
            switch $0 {
            case .success(let result):
                completeHandler(FetchDataResult(result))
            case .success(let error):
                completeHandler(FetchDataError(error))
            }
        }
    }
}

// When async action is dispatched to the store, it will be executed:

store.dispatch(FetchDataAction())

```

### Declarative Side Effects

Declarative Side Effects offer more advanced capabilities for handling asynchronous operations by making them state-driven. This mechanism is particularly useful when you need precise control over execution, including retry logic, cancellation, and orchestration them together and with the UI. Despite its advanced features, it is also suitable for simpler use cases due to its minimal boilerplate code.

Think of your app as a state machine where effects are just another reaction to state transitions:

You're not writing low-level execution logic. You're describing intent.

"What" you want is declared in state.
"How" it happens is handled by the Puredux Effects engine.

  
 ```swift

// Let's add a generic Effect's Action and reducer 
public extension Effect {
     
    enum Action<T> {
        case run
        case restart
        case success(T)
        case failure(CodableError)
        case cancel

        var result: T? {
            switch self {
            case .success(let result):
                return result
            default:
                return nil
            }
        }
    }

    mutating func reduce<T>(_ action: Effect.Action<T>) {
        switch action {
        case .run:
            run()
        case .restart:
            restart()
        case .success:
            succeed()
        case .failure(let error):
            fail(error.error)
        case .cancel:
            cancel()
        }
    }
}

// Add effect state to the state, and handle actions in the reducer:

struct AppState {
    private(set) var fetchMessagesEffect: Effect.State = .idle()
    private(set) var messages: [Message]

    enum AppAction {
        case fetchMessages(Effect.Action<[Message]>)
    }

    mutating func reduce(_ action: AppAction) {
        switch action {
        case let .fetchMessages(action):
            fetchMessagesEffect.reduce(action)
            messages = action.result ?? messages
        }
    }
}
 
 
// Connect Side Effect handler
  
let store = StateStore<AppState, Action>(AppState()) { state, action in 
    state.reduce(action) 
}
.effect(\.fetchMessagesEffect, on: .main) { appState, dispatch in
    Effect {
        do {
            let result = try await apiService.fetch()
            dispatch(.fetchMessages(.success(result)))
        } catch {
            dispatch(.fetchMessages(.failure(error)))
        }
    }
}

// Dispatch action to run the job:

store.dispatch(.fetchMessages(.run))

```

Declarative side effects are a powerful architectural pattern that separate what should happen from how it’s executed. This distinction unlocks a range of benefits for modern apps, especially when dealing with asynchronous logic like networking, retries, and cancellations.
 
#### Predictability
Side effects are driven by state transitions. You always know when and why something runs—because it's a direct result of a state change (e.g., .run, .restart, .cancel).

> No more guessing why an API call triggered twice or never stopped—side effects are entirely deterministic.


#### Lifecycle Safety
Effects are scoped to the lifetime of the store they're connected to. If a store is deinitialized (e.g., a view disappears), the associated side effects cancel automatically.

This avoids memory leaks, dangling async operations, or race conditions from orphaned tasks.

```swift
.effect(\.authEffect) { ... }
.effect(\.messagesEffect) { ... }

```


#### Testability
You can test effect behavior by inspecting state transitions, without needing to run actual async code, spy mocking, etc.

```swift
state.reduce(.fetchMessages(.run))
XCTAssertTrue(state.fetchMessagesEffect.isRunning)

```


#### Control Over Retry, Cancel, Orchestration
Handling advanced flows like retries, cancellations, or delayed execution becomes trivial:

```
/// 

mutating func reduce<T>(_ action: Effect.Action<T>) {
    switch action {
    case .run:
        run(maxAttempts: 3, delay: 3.0)
    case .success:
        succeed()
    case .failure(let error):
        retryOrFailWith(error) 
    // ...
    }
}

```

#### UI Alignment

Declarative side effects naturally align with state-driven UI frameworks like SwiftUI, React, or Jetpack Compose.

Views respond to state changes, and effects follow the same rule—making the whole system coherent.
 



## Dependency Injection

Puredux splits dependencies into two categories:

- Store Injection
- Dependency Injection

Although both are essentially dependencies, they are handled separately because they serve different purposes, and Puredux ensures they remain distinct.

- **Store Injection** is used to conveniently obtain store instances in the UI layer of the application.
- **Dependency Injection** is used inside the store's reducers to power the application's core logic.

### Store Injection

Use `@DependencyEntry` in the `SharedStores` extension to inject the store instance:

```swift
extension SharedStores {
   @DependencyEntry var root = StateStore<AppRootState, Action>(....)  
}
 

// The `@StoreOf` property wrapper can be used to obtain the injected store instance:
 
struct MyView: View {
    @State @StoreOf(\.root)
    var store: StateStore<AppRootState, Action>
    
    var body: some View {
       // ...
    }
}
```

### Dependency Injection

Use `@DependencyEntry` in the `Dependencies` extension to inject the dependency instance:

```swift
extension Dependencies {
   @DependencyEntry var now = { Date() }  
}
 

// Then it can be used in the app reducer:
 
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

## Performance

Puredux offers a robust strategy for addressing the performance challenges commonly faced in iOS applications. It provides several key optimizations to enhance app responsiveness and efficiency, including:

- **Reducers background execution**: Offloads reducer logic to background threads to improve overall app performance.
- **State updates deduplication**: Minimizes redundant state updates, reducing unnecessary re-renders and improving processing efficiency.
- **Granular UI updates**: Ensures only the necessary parts of the UI are updated, enhancing responsiveness.
- **UI updates debouncing**: Prevents excessive UI updates by intelligently controlling the frequency of updates.
- **Two-step UI updates with background task offloading**: Heavy computational tasks are handled in the background, with UI updates executed in a structured two-step process to ensure smooth, lag-free interactions.

As your application and its features expand, you may encounter performance issues, such as reducers taking longer to execute or SwiftUI view
bodies refreshing more frequently than anticipated. This article highlights several common challenges when building features in Puredux and provides solutions to address them.

### Reducers Execution

Puredux is designed in a way that allows you to implement state and reducers without any dependencies.

This is done intentionally to be able to offload all stores reducers' work to the background without worrying much about data races, access
synchronization with dependencies.

As the result reducers operate in background leaving the main thread exclusively for the UI.

### QoS Tuning

When creating the root store, you can choose the quality of service for the queue it will operate on.

```swift
 let store = StateStore(
     InitialState(),
     qos: .userInitiated,
     reducer: myReducer
 )
```

### Deduplicated State Updates

Puredux supports state change deduplication to enable granular UI updates based on changes to specific parts of the state.

```swift
struct MyView: View {
    let store: Store<ViewState, Action>
    
    @State var viewState: ViewState?

    var body: some View {
        ContentView(viewState)
            .subscribe(
                store: store,
                removeStateDuplicates: .keyPath(\.lastModified),
                observe: {
                    viewState = $0
                }
            )
    }
}
```

<details><summary>Click to expand UIViewController example</summary>
<p>

 ```swift
 final class MyViewController: ViewController  {
    var store: StoreOf(\.root).with(MyScreenState()) { state, action in 
        state.reduce(action) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        subscribe(
            store,
            removeStateDuplicates: .keyPath(\.lastModified)) { [weak self] in
            // Handle updates with the derived props
            self?.updateUI(with: $0)
        }
     }
     
     private func updateUI(with state: (AppState, MyScreenState)) {
         // Update UI elements with the new view state
     }
}
```

</p>
</details>

### UI Updates Debouncing

There are situations where frequent state updates are unavoidable, but triggering the UI for each update can be too resource-intensive. 
To handle this, Puredux provides a debouncing option. 
With debouncing, the UI update will only be triggered after a specified time interval has elapsed between state changes.

```swift
struct MyView: View {
    let store: Store<ViewState, Action>
    
    @State var viewState: ViewState?

    var body: some View {
        ContentView(viewState)
            .subscribe(
                store: store,
                debounceFor: 0.016, 
                observe: {
                    viewState = $0
                }
            )
    }
}
```

<details><summary>Click to expand UIViewController example</summary>
<p>

 ```swift
 final class MyViewController: ViewController  {
    var store: StoreOf(\.root).with(MyScreenState()) { state, action in 
        state.reduce(action) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        subscribe(store, debounceFor: 0.016) { [weak self] in
            self?.updateUI(with: $0)
        }
     }
     
     private func updateUI(with state: (AppState, MyScreenState)) {
         // Update UI elements with the new view state
     }
}
```
</p>
</details>

### Two-step UI Updates with Background Offloading

A very common use case involves converting raw model data into a more presentable format, 
which may include mapping `AttributedStrings`, using `DateFormatter`, and more. These operations can be resource-intensive.

Puredux allows you to add a presentational layer in the state change processing pipeline between the store and the UI. This enables you to offload these computations to a background queue, keeping the UI responsive.

```swift
struct MyView: View {
    @State var store: StoreOf(\.root).with(ViewState()) { state, action in 
        state.reduce(action) 
    }
    
    @State var viewModel: ViewModel?
     
    var body: some View {
        ContentView(viewModel)
            .subscribe(
                store,
                props: { state, dispatch in
                    // ViewModel will be evaluated on the background presentation queue
                    ViewModel(state, dispatch)
                },
                presentationQueue: .sharedPresentationQueue,
                observe: {
                    viewModel = $0
                }
            )
    }
}
```

<details><summary>Click to expand UIViewController example</summary>
<p>

 ```swift
 final class MyViewController: ViewController  {
    var store: StoreOf(\.root).with(MyScreenState()) { state, action in 
        state.reduce(action) 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        subscribe(
            store, 
            props: { state, dispatch in
                // ViewModel will be evaluated on the background presentation queue
                ViewModel(state, dispatch)
            },
            presentationQueue: .sharedPresentationQueue) { [weak self] in
            
            self?.updateUI(with: $0)
        }
     }
     
     private func updateUI(with viewModel: ViewModel) {
         // Update UI elements with the new view state
     }
}
```
</p>
</details>

### Granular UI Updates

Puredux provides a full control over UI updates. Any SwiftUI `View`, `UIViewController` or a `UIView` or can be individually subscribed to the `Store` with state deduplication, debouncing and 2-step UI updates with background offloading.

## Installation

### Swift Package Manager.

Puredux is available through Swift Package Manager. 

To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/Puredux
```

## Documentation

- [Documentation](https://swiftpackageindex.com/KazaiMazai/Puredux/main/documentation/puredux)
- [Documentation v1.9.x](https://swiftpackageindex.com/KazaiMazai/Puredux/1.9.2/documentation/puredux)
- [Documentation Archive](https://swiftpackageindex.com/kazaimazai/puredux/main/documentation/puredux/archive)
- [Migration Guides](https://swiftpackageindex.com/kazaimazai/puredux/main/documentation/puredux/migrationguides)

## Licensing

Puredux and all its modules are licensed under MIT license.



