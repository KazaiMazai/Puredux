<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
  <img src="https://github.com/KazaiMazai/Puredux/blob/main/Docs/Resources/Logo.svg">
</picture>


<p align="left">
    <a href="https://github.com/KazaiMazai/Puredux/actions">
        <img src="https://github.com/KazaiMazai/Puredux/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

Puredux is an architecture framework for SwiftUI and UIKit designed to
streamline state management with a focus on unidirectional data flow and separation of concerns.

- **Unidirectional MVI Architecture**: Supports a unidirectional data flow to ensure predictable state management and consistency.
- **SwiftUI and UIKit Compatibility**: Works seamlessly with both SwiftUI and UIKit, offering bindings for easy integration.
- **Single Store/Multiple Stores Design**: Supports both single and multiple store setups for flexible state management of apps of any size and complexity.
- **Separation of Concerns**: Emphasizes separating business logic and side effects from UI components.
- **Performance Optimization**: Offers granular performance tuning with state deduplication, debouncing, and offloading heavy UI-related work to the background.


## Getting Started

### Basics

- State is a type describing the whole application state or a part of it
- Actions describe events that may happen in the system and mutate the state
- Reducer is a function, that describes how Actions mutate the state
- Store is the heart of the whole thing. It takes Initial State and Reducer, performs mutations when Actions dispatched and deilvers new State to Observers

### Store Definitions

```swift
// Let's cover actions with a protocol

protocol Action {

}

// Define root AppState

struct AppState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}

// Injected root store

extension Injected {
    @InjectEntry var root = StateStore<AppState, Action>(AppState()) { state, action in
        state.reduce(action)
    }
}
```

### UI Bindings

```swift

// View might need a local state that we don't need to share with the whole app 

struct ViewState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}

struct ContentView: View  {
    // We can create take an injected root store,
    // Create a local store and seamlessly merge them together:
    // `Store<(AppState,ViewState)>` lifecycle will be controller by view
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

class MyViewController: ViewController  {
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

## Side Effects

In UDF world we call "side effects" async work: network requests, database fetches and other I/O operations, timer events, location service callbacks, etc.

In Puredix it can be done with Async Actions.

### Async Actions

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
## Application Stores Architecture


Puredux allows you to build a hierarchical store tree. 
Actions are propagated upstream from child stores to the root store, while state updates are propagated downstream from the root store to child stores and, ultimately, to store observers.

This architecture facilitates building applications where certain parts of the state can be shared or isolated, and state mutations remain predictable.

```swift

let root = StateStore<AppState, Action>(AppState()) { state, action in
        state.reduce(action)
}

let featureOne = root.with(FeatureOne()) { state, action in 
    state.reduce(action) 
}

let featureTwo = root.with(FeatureTwo()) { state, action in 
    state.reduce(action) 
}

let ScreenOne = featureTwo.with(ScreenOne()) { state, action in 
    state.reduce(action) 
}

let ScreenTwo = featureTwo.with(ScreenOne()) { state, action in 
    state.reduce(action) 
}

```


 ```text
            +----------------+    
            | AppState Store |
            +----------------+    
                     |
                     |
        +------------+-------------------------+
        |                                      |
        |                                      |
        |                                      |
        |                                      |
  +------------------+                +------------------+   
  | FeatureOne Store |                | FeatureTwo Store | 
  +------------------+                +--------+---------+   
                                               |
                                               |
                                  +------------+------------+
                                  |                         |
                                  |                         |
                                  |                         |
                                  |                         |
                           +------+----------+       +------+----------+
                           | ScreenOne Store |       | ScreenTwo Store |
                           +-----------------+       +-----------------+
                              |                       |
                           +----+                    +----+
                           | UI |                    | UI |
                           +----+                    +----+
```


## UI Performance Tuning

### Quality of Service

Puredux is designed in a way that allows you to implement state and reducers without any dependencies.

This is done intentionally to offload all store work to the background without worrying much about data races, access synchronization, and so on, leaving the main thread exclusively for the UI.

When creating the root store, you can choose the quality of service for the queue it will operate on.

```swift
 let store = StateStore(
     InitialState(),
     qos: .userInitiated,
     reducer: myReducer
 )
```

### Deduplicated UI Updates

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
 class MyViewController: ViewController  {
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

### UI Updates debouncing

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
 class MyViewController: ViewController  {
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

### Extra Presentational Layer 

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
 class MyViewController: ViewController  {
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

## Installation

### Swift Package Manager.

Puredux is available through Swift Package Manager. 

To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/Puredux
```
 
## Migration Guiges

- [Migration Guides](Docs/Migration-Guides.md)


# Licensing

Puredux and all its modules are licensed under MIT license.



