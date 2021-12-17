<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
 </p>
 


# Puredux-Store

Yet another UDF Architecture Store implementation
<p align="left">
    <a href="https://github.com/KazaiMazai/PureduxStore/actions">
        <img src="https://github.com/KazaiMazai/PureduxStore/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

## Features

- Minimalistic 
- Operates on main or background queue
- Light-weight store proxies
- Thread safe 
- Simple actions interceptor for side effects
____________


## Installation
 

### Swift Package Manager.

PureduxStore is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/PureduxStore
```
____________

## Basics

- State is a type describing the whole application state or a part of it
- Actions describe events that may happen in the system and mutate the state
- Reducer is a function, that describes how Actions mutate the state
- Store is the heart of the whole thing. It takes Initial State and Reducer, performs mutations when Actions dispatched and deilvers new State to Observers


## Quick Start Guide

1. Import:
```swift
import PureduxStore

```

2. Create initial app state:

```swift
let initialState = AppState()
```

and `Action` protocol:

```swift

protocol Action {

}

```

3. Create reducer:

```swift 
let reducer: (inout AppState, Action) -> Void = { state, action in

    //mutate state here

}

```

4. Create root store with initial app state and reducer. Get light-weight store:

```swift
let rootStore = RootStore<AppState, Action>(initialState: initialState, reducer: reducer)

let store = rootStore.store()
```

5. Setup actions interceptor for side effects:

Let's have an `AsyncAction` protocol defined as:

```swift

protocol AsyncAction: Action {
    func execute(completeHandler: @escaping (Action) -> Void)
}
```

and some long running action that with injected service:

```swift
struct SomeAsyncAction: AsyncAction {
    @DI var service: SomeInjectedService

    func execute(completeHandler: @escaping (Action) -> Void) {  
        service.doTheWork {
            switch $0 {
            case .success(let result):
                completeHandler(SomeResultAction(result))
            case .success(let error):
                completeHandler(SomeErrorAction(error))
            }
        }
    }
}

```

Execute side effect:

```swift

rootStore.interceptActions { action in
    guard let action = ($0 as? AsyncAppAction) else  {
        return
    }
    
    DispatchQueue.main.async {
        action.execute { store.dispatch($0) }
    }   
}

```

6. Create substate store proxy:

```swift
let storeProxy = store.proxy { appState in appState.subState }

```

7. Create store observer and subscribe to store:


```swift 
let observer = Observer<SubState> { substate, completeHandler in
    
    // Handle your latest state here and dispatch some actions to the store
    
    storeProxy.dispatch(SomeAction())
    
    guard wannaKeepReceivingUpdates else {
        completeHandler(.dead)
        return 
    }
    
    completeHandler(.active)
}

storeProxy.subscribe(observer: observer)

```

## Q&A

<details><summary>Click for details</summary>
<p>


### What is RootStore?

- Although RootStore is called so, it behaves more like a root than a store.
- It plays a role of a factory for light-weight Stores that are created as proxies for the real internal store 
that lives under the hood of a RootStore

### What queue does it operate on?

- By default, it works on a global serial queue with user interactive quality of service, but you can configure it to work on the main dispatch queue.


### What is Store?

- Store is a lightweight store. 
- It's only a proxy to the real store that lives under the hood of a RootStore: it forwards subscribtions and all dispatched Actions to it.
- Store is designed to be passed all over the app safely without extra effort.
- It's threadsafe. Technically it's not, but it forwards everything to a thread safe internal store. 
It allows to dispatch actions, subscribe and unsubscribe from any distpach queue.
- It keeps weak reference to the real store, that allows to avoid creating reference cycles accidentally.


### What's the Proxy Store?

- With Store it's possible to create substate proxies that allows to scope app features effectively.
  
### Does Proxy Store deduplicate state changes somehow?
- No, Proxy Store observers are triggered at every root store state change. Store proxy is only for scopeing state to app features
  
### How to unsubscribe from store?
 
- Call store observer's complete handler with dead status:
  
```swift 
let observer = Observer<State> { state, completeHandler in
    //
    completeHandler(.dead)
}
 
``` 


</p>
</details>


## Licensing

PureduxStore is licensed under MIT license.
