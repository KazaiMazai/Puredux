# Performance

Discover ways to enhance the performance of features developed with Puredux.

## Overview

Puredux offers a robust strategy for addressing the performance challenges commonly faced in iOS applications. It provides several key optimizations to enhance app responsiveness and efficiency, including:

- **Reducers background execution**: Offloads reducer logic to background threads to improve overall app performance.
- **State updates deduplication**: Minimizes redundant state updates, reducing unnecessary re-renders and improving processing efficiency.
- **Granular UI updates**: Ensures only the necessary parts of the UI are updated, enhancing responsiveness.
- **UI updates debouncing**: Prevents excessive UI updates by intelligently controlling the frequency of updates.
- **Two-step UI updates with background task offloading**: Heavy computational tasks are handled in the background, with UI updates executed in a structured two-step process to ensure smooth, lag-free interactions.

As your application and its features expand, you may encounter performance issues, such as reducers taking longer to execute or SwiftUI view
bodies refreshing more frequently than anticipated. This article highlights several common challenges when building features in Puredux and provides solutions to address them.

## Reducers Execution

Puredux is designed in a way that allows you to implement state and reducers without any dependencies.

This is done intentionally to be able to offload all stores reducers' work to the background without worrying much about data races, access
synchronization with dependencies.

As the result reducers operate in background leaving the main thread exclusively for the UI.


## QoS Tuning


When creating the root store, you can choose the quality of service for the queue it will operate on.

```swift
 let store = StateStore(
     InitialState(),
     qos: .userInitiated,
     reducer: myReducer
 )
```

## State Changes Deduplication

Puredux provides functionality for state change deduplication, allowing for efficient and granular updates to the user interface by focusing
on specific parts of the state. This is particularly useful in optimizing performance and ensuring that only necessary UI components are 
re-rendered when relevant state changes occur.

> Important: State deduplication should be used with special care. While it can be an efficient performance-enhancing technique in some cases, it may introduce bugs related to UI inconsistencies in others. It's important to ensure that deduplication does not result in unintended behavior or out-of-sync UI elements.


### SwftUI View Updates Deduplication

In a SwiftUI context, you can use state change deduplication to manage and update your view's state efficiently.

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
### UIViewController Updates Deduplication

For UIKit-based `UIViewControllers`, you can achieve similar results with state change deduplication, ensuring that your view controller 
updates only when necessary.


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

## UI Updates Debouncing

In scenarios where state updates occur frequently, it might be inefficient to trigger UI updates for each individual change. To address
this, Puredux offers a debouncing option. 

Debouncing ensures that UI updates are only triggered after a specified time interval has passed since the last state change, reducing the 
frequency of updates and potentially improving performance.

> Important: Picking a debounce interval that is too long can reduce computational overhead but may make the UI noticeably less responsive. Conversely, a very short interval may not sufficiently reduce computation load. The debounce interval should be selected carefully based on the specific use case to strike a balance between responsiveness and performance.

### SwiftUI View Updated Debouncing

In SwiftUI, you can use the debouncing feature to limit how often your view updates in response to frequent state changes.

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
### UIViewController Updates Debouncing

For UIViewController views, the debouncing feature can be applied to efficiently handle frequent state updates.

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

This approach ensures that the UI is updated less frequently, optimizing performance especially in cases where the state changes are frequent but not necessarily all of them require immediate reflection in the UI.

## Two-step UI Updates with Background Offloading

A common requirement is to transform raw model data into a more presentable format. This may involve operations such as mapping AttributedStrings, formatting dates with DateFormatter, and other resource-intensive computations. 

To handle this efficiently, Puredux allows you to introduce a presentational layer in the state change processing pipeline. This allows for 
background processing of these transformations, keeping the UI responsive.

> Important: While offloading computations to a background queue helps in keeping the UI responsive, it's important to evaluate whether the  overhead of hopping to a background queue is justified for your specific use case. Tune the implementation accordingly find a balance for particular use case.

### Two-step SwiftUI View Updates with Background Offloading

In a SwiftUI view, you can leverage Puredux's ability to handle presentation logic on a background queue:

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

### Two-step UIViewController Updates with Background Offloading

For a UIViewController, you can similarly manage background processing of presentation logic:

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

By incorporating a presentational layer in this way, you can ensure that resource-intensive computations do not block the main thread, 
resulting in a smoother and more responsive user experience.
