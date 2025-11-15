# Getting Started

Making your first steps with Puredux

## Installation

### Swift Package Manager


Puredux is available through Swift Package Manager. To install it in Xcode 11.0 or later:

Select File > Swift Packages > Add Package Dependency...
Enter the Puredux repository URL:

```
https://github.com/KazaiMazai/Puredux
```
 
## Basics

At its core, Puredux follows a predictable state management pattern that consists of the following key components:

- State: A type that represents the entire application state or a portion of it.
- Actions: Events that describe possible changes in the system, which lead to state mutations.
- Reducer: A function that dictates how state changes in response to specific actions.
- Store: The central hub where:
    - Initial state and reducers are defined.
    - Actions are dispatched to trigger state changes.
    - New state values are propagated to any observers or views.


 
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

## Actions Definitions

Puredux is very flexible in how actions are defined.

See more the examples here: 
<doc:ActionsDesignTips>

Let's define an action as plain protocol:
 
```swift
protocol Action {
    // Define specific actions in your app by conforming to this protocol
}
```
Then, all app actions can be defined as structs conforming to the protocol:

```swift
struct IncrementCounter: Action {
    // ...
}
```

## Store Definitions

Let's break down a typical store setup using Puredux.


**1. Define the AppState**:

The application’s state can be represented by a struct, which will store the data relevant to your app. 
The reduce method defines how the state will change in response to an action.

 
```swift
struct AppState {
    // Define your app's state properties here

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as IncrementCounter:
            // ...
        default:
            break
        }
    }
}
```
**2. Define the Store and Inject it**:

We create a store that integrates actions and the state for the root AppState. Then we use built-in DI:

```swift

extension SharedStores {
    @DependencyEntry var root = StateStore<AppState, Action>(AppState()) { state, action in
        state.reduce(action)
    }
}

```

## SwiftUI Bindings

Puredux can seamlessly integrate with SwiftUI to manage both global app state and local states.

```swift

// View might need a local state that we don't need to share with the whole app 

struct ViewState {
    // ...
    
    mutating func reduce(_ action: Action) {
        // ...
    }
}
```

In your SwiftUI View, you can combine the app's root store with local view-specific states.
This allows the view to respond dynamically to both app-level and view-level state changes.

```swift
struct ContentView: View  {
    // Combine the root store with local state
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

## UIKit Bindings
 
Puredux also supports UIKit, offering a similar approach for handling state and actions within UIViewController.

```swift

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

