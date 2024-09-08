# Side Effects

Performing SideEffects with Puredux

## Overview

In the context of UDF architecture, "side effects" refer to asynchronous operations that interact with external systems or services. These can include:

- Network Requests: Fetching data from web services or APIs.
- Database Fetches: Retrieving or updating information in a database.
- I/O Operations: Reading from or writing to files, streams, or other I/O devices.
- Timer Events: Handling delays, timeouts, or scheduled tasks.
- Location Service Callbacks: Responding to changes in location data or retrieving location-specific information.

## Handling Side Effects in Puredux

In the Puredix framework, managing these side effects is achieved through two main mechanisms:
- Async Actions
- State-Driven Side Effects

## Async Actions

Async Actions are designed for straightforward, fire-and-forget scenarios. They allow you to initiate asynchronous operations and integrate them seamlessly into your application logic. These actions handle tasks such as network requests or database operations, enabling your application to respond to the outcomes of these operations.
Define actions that perform asynchronous work and then use them within your app.

**Step 1: Define result and Error Actions**

```swift
 
struct FetchDataResult: Action {
    // ...
}

struct FetchDataError: Action {
    // ...
}
```

**Step 2: Define AsyncAction**

```swift
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
```

**Step 3: Dispatch AsyncAction**

When async action is dispatched to the store, it will be executed:

```swift
store.dispatch(FetchDataAction())

```

## State-Driven Side Effects

State-driven Side Effects offer more advanced capabilities for handling asynchronous operations. This mechanism is particularly useful when you need precise control over execution, including retry logic, cancellation, and synchronization with the UI or other parts of the application. Despite its advanced features, it is also suitable for simpler use cases due to its minimal boilerplate code.
 
 **Step 1: Add effect state to the state**
 
 ```swift
struct AppState {
    private(set) var theJob: Effect.State = .idle()
}
```

**Step 2: Add related actions**
 
 ```swift 
enum Action {
    case jobSuccess(Something)
    case startJob
    case cancelJob
    case jobFailure(Error)
}
 
```

 **Step 3: Handle actions in the reducer**
 
```swift
extension AppState {
    mutating func reduce(_ action: Action) {
        switch action {
        case .jobSuccess:
            theJob.succeed()
        case .startJob:
            theJob.run()
        case .cancelJob:
            theJob.cancel()
        case .jobFailure(let error):
            theJob.retryOrFailWith(error)
        }
    }
}
 ```
 
**Step 4: Add SideEffect to the store:**
 
```swift
let store = StateStore<AppState, Action>(AppState()) { state, action in 
    state.reduce(action) 
}
.effect(\.theJob, on: .main) { appState, dispatch in
    Effect {
        do {
            let result = try await apiService.fetch()
            dispatch(.jobSuccess(result))
        } catch {
            dispatch(.jobFailure(error))
        }
    }
}

store.dispatch(.startJob)
```
