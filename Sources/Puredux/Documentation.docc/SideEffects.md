# Side Effects

In UDF world we call "side effects" async work: network requests, database fetches and other I/O operations, timer events, location service callbacks, etc.

In Puredix it can be done with Async Actions.

## Async Actions

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
