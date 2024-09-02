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


// Define action. It can be an `enum` or a protocol for even more flexiblity.

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

### SwiftUI Integration


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
    @State var store: StoreOf(\.root)
        .with(ViewState()) { state, action in state.reduce(action) }
    
    @State var viewState: (AppState, ViewState)?
    
    var body: some View {
        StoreView(store) { state, dispatch in
            MyView(viewState)
                .subscribe(store) { viewState = $0 }
                .onAppear {
                    dispatch(SomeAction())
                }
        }
    }
}

```

### UIKit Integration


```swift

// We can do the same thing almost with the same API for UIKit view controller:

struct MyScreenState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}

class MyViewController: ViewController  {
    @State var store: StoreOf(\.root)
        .with(MyScreenState()) { state, action in state.reduce(action) }
    
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



