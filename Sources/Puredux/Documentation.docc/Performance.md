# Performance

## Overview

Puredux offers a robust strategy for addressing the performance challenges commonly faced in iOS applications. It provides several key optimizations to enhance app responsiveness and efficiency, including:

- Reducers background execution: Offloads reducer logic to background threads to improve overall app performance.
- State updates deduplication: Minimizes redundant state updates, reducing unnecessary re-renders and improving processing efficiency.
- Granular UI updates: Ensures only the necessary parts of the UI are updated, enhancing responsiveness.
- UI updates debouncing: Prevents excessive UI updates by intelligently controlling the frequency of updates.
- Two-step UI updates with background task offloading: Heavy computational tasks are handled in the background, with UI updates executed in a structured two-step process to ensure smooth, lag-free interactions.


## Quality of Service

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

## Deduplicated State Updates

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

## UI Updates Debouncing

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

## Extra Presentational Layer 

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
