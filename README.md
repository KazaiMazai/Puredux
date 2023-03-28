<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
 </p>
 


# Puredux-Store

Yet another UDF state management lib
<p align="left">
    <a href="https://github.com/KazaiMazai/PureduxStore/actions">
        <img src="https://github.com/KazaiMazai/PureduxStore/workflows/Tests/badge.svg" alt="Continuous Integration">
    </a>
</p>

## Features

- Minimal API
- Single/Multiple Stores
- Operates on background queue
- Thread safe stores
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
let factory = StoreFactory<AppState, Action>(
    initialState: initialState,
    reducer: reducer
)

let store = factory.rootStore()
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

Execute side effects in the interceptor:

```swift

let storeFactory = StoreFactory<AppState, Action>(
    initialState: initialState, 
    interceptor:  { action, dispatch in
        guard let action = ($0 as? AsyncAppAction) else  {
            return
        }
    
        DispatchQueue.main.async {
            action.execute { dispatch($0) }
        } 
    },
    reducer: reducer
)

```

6. Create scoped stores with substate:

```swift
let scopedStore: Store<SubState, Action> = storeFactory.scopeStore { appState in appState.subState }

```

7. Create store observer and subscribe to store:


```swift 
let observer = Observer<SubState> { substate, completeHandler in
    
    // Handle your latest state here and dispatch some actions to the store
    
    scopedStore.dispatch(SomeAction())
    
    guard wannaKeepReceivingUpdates else {
        completeHandler(.dead)
        return 
    }
    
    completeHandler(.active)
}

scopedStore.subscribe(observer: observer)

```


8. Create child stores with local state and reducer:

```swift
 
let childStoreObject: StoreObject<(AppState, LocalState), Action> = storeFactory.childStore(
    initialState: LocalState(),
    reducer: { localState, action  in
        localState.reduce(action: action)
    }
)

let childStore = childStoreObject.store()


let observer = Observer<(AppState, LocalState)> { stateComposition, complete in
    // Handle your latest state here and dispatch some actions to the store

    childStore.dispatch(SomeAction())

    guard wannaKeepReceivingUpdates else {
        completeHandler(.dead)
        return 
    }

    completeHandler(.active)
}

childStore.subscribe(observer: observer)


```


## How to migrate from v1.0.x to v1.1.x

Old API will be deprecated in the next major release. 
Please consider migration to the new API.

<details><summary>Click for details, it's not a big deal</summary>
<p>

### 1. Migrate From `RootStore` to `StoreFactory`:

Before: 

```swift
let rootStore = RootStore<AppState, Action>(
    queue: StoreQueue = .global(qos: .userInteractive)
    initialState: initialState, 
    reducer: reducer
)

let store: Store<AppState, Action> = rootStore.store()

```

Now:

```swift
let storeFactory = StoreFactory<AppState, Action>(
    initialState: initialState, 
    qos: .userInteractive,
    reducer: reducer
)

let store: Store<AppState, Action> = storeFactory.rootStore()

```

MainQueue is not available for Stores any more. 
Since now, stores always operate on a global serial queue with configurable QoS.

### 2. Update actions interceptor and pass in to store factory:

Before:

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

Now:

```swift
let storeFactory = StoreFactory<AppState, Action>(
    initialState: initialState, 
    interceptor:  { action, dispatched in
        guard let action = ($0 as? AsyncAppAction) else  {
            return
        }
    
        DispatchQueue.main.async {
            action.execute { dispatch($0) }
        } 
    },
    reducer: reducer
)

```
### 3. Migrate from `proxy(...)` to `scope(...)`:

Before:

```swift
let storeProxy = rootStore.store().proxy { appState in appState.subState }

```

Now:

```swift
let scopeStore = storeFactory.scopeStore { appState in appState.subState }

```

</p>
</details>

## Basics Q&A

<details><summary>Click for details</summary>
<p>

  
### How to connect PureduxStore to UI?
  
- It can be done with the help of [PureduxUIKit](https://github.com/KazaiMazai/PureduxUIKit) or [PureduxSwiftUI](https://github.com/KazaiMazai/PureduxSwiftUI)


### What is StoreFactory?

StoreFactory is a factory for Stores and StoreObjects.
It suppports creation of the following store types:
- Root Store - plain Store as proxy to the factory's' root store
- Scope Store - scoped Store as proxy to the factory root store
- Child Store - child StoreObject with `(Root, Local) -> Composition` state mapping and it's own lifecycle

### What queue does the root store operate on?

- By default, it works on a global serial queue with `userInteractive` quality of service. QoS can be changed.
 
 
### What is a Store?

- Store is a lightweight store. 
- It's a proxy to its parent store: it forwards subscribtions and all dispatched Actions to it.
- Store is designed to be passed all over the app safely without extra effort.
- It's threadsafe. It allows to dispatch actions and subscribe from any thread. 
- It keeps weak reference to the parent store, that allows to avoid creating reference cycles accidentally.

### What is a StoreObject?

- StoreObject is a class store.
- It's a proxy to its parent store: it forwards subscribtions and all dispatched Actions to it.
- It's designed to manage stores lifecycle
- It's threadsafe. It allows to dispatch actions and subscribe from any thread. 
- It keeps a *strong* reference to the root store, that's why requries a careful treatment.


### How to unsubscribe from store?
 
Call store observer's complete handler with dead status:
  
```swift 
let observer = Observer<State> { state, completeHandler in
    //
    completeHandler(.dead)
}
 
``` 

### Does Puredux provide a single or multiple stores?

It does both. Puredux allows to have a single store that can be scoped to proxy substores for sake of features isolation.
It also allows to have a single root store with multiple plugable child stores for even deeper features isolation.
 
### What if I don't know if I need a single or multi store?

Puredux is designed in a way that you can seamlessly scale up to multiple stores when needed.
- Start with a single store. 
- If the single app state is starting to feel overbloated think about using scope stores.
- If you start to plug/unplug some parts of the single state it might be a sign to start using
child stores.


</p>
</details>

## Root Store Q&A

<details><summary>Click for details</summary>
<p>

### What is a root store?

- StoreFactory has an internal root store object, 
- Root Store is Store that is created by `rootStore()` method 
- Root Store is a simple proxy to the factory's root store object
- Root Store keeps weak reference to the factory root store object store

### How to manage factory root store and its state lifecycle?

Root store object lifecycle and its state managed by factory. 
Initalized together with the factory and released when factory is released
It exist as long as the factory exist.

### How to create a root store?

```swift
let store = factory.rootStore()

```

### Is root store created with initial root state?

No. State is initialized when factory is created. Then it lives together with it.
Typically factory's' lifecycle matches app's lifecycle.

</p>
</details>

## Scoped Store Q&A

<details><summary>Click for details</summary>
<p>

### What's the scoped store?
 
- Scoped store is a proxy to the root store  
- Scoped doesn't have its own local state.
- Scoped doesn't have its own reducer
- Scoped store's state is a mapping of the root state.
- Doesn't create any child-parent hierarchy

### How to create a scoped store?

```swift
let scopedStore: Store<Substate, Action> = storeFactory.scopeStore { appState in appState.subState }

```

### Does Proxy Store deduplicate state changes somehow?
- No, Proxy Store observers are triggered at every root store state change.

### What for?
- The purpose is to scope entire app's state to local app feature state
  
</p>
</details>

## Child Store Q&A

<details><summary>Click for details</summary>
<p>

### What is child store?

- Child store is a separate store 
- Child store has its own local state
- Child store has its own local state reducer
- Child store is attached to the factory root store
- Child store's state is a composition of parent state and local state
- Creates child-parent hierarchy

### How to create child store?

StoreFactory allows to create child stores. 
You should only provide initial state and reducer:

```swift
 
let childStoreObject: StoreObject<(AppState, LocalState), Action> storeFactory.childStore(
    initialState: LocalState(),
    reducer: { localState, action  in
        localState.reduce(action: action)
    }
)

```
### How to manage child store's and its state lifecycle?

Child store is a `StoreObject` it will exist while you keep a strong reference to it.

### Why root store and scope store is a Store<State, Action> and child store is a `StoreObject<State, Action>`?

Root store's and scope store's lifecycle is controlled by StoreFactory. 
They exist while factory exist. Typically during the whole app lifecycle.

Child store is for the cases when we want to take over the control of the store lifecycle.
Typically when we present screens or some flows of the app.

`StoreObject<State, Action>` prevents from errors that could occur because of confusion with 
Store<State, Action 

### How are Actions dispatched with parent/child stores?

First of all it follows the rules:
- Actions flow to the root. From child stores to parent
- State changes flow from the root. From Parent to Child stores. From Stores to Subscribers.
- Actions never flow from the root. From parent to child stores.
- Action never flow horizontally. From childStoreA to childStoreB
- Interceptor dispatches new actions to the same store where the initial action was dispatched. 

According to the rules above.

When action is dispatched to RootStore:
- action is delivered to root store's reducer
- action is *not* delivered to child store's reducer
- root state update triggers root store's subscribers
- root state update triggers child stores' subscribers
- Interceptor dispatches additional actions to RootStore

When action is dispatched to ChildStore:
- action is delivered to root store's reducer
- action is delivered to child store's reducer
- root state update triggers root store's subscribers.
- root state update triggers child store's subscribers.
- local state update triggers child stores' subscribers.
- Interceptor dispatches additional actions to ChildStore

### Does Child Store deduplicate state changes somehow?
- No. Child Store observers are triggered at every state change: both parent's state changes and child's ones.

</p>
</details>


## Licensing

PureduxStore is licensed under MIT license.
