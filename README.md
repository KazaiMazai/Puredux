<p align="center">
  <img src="Logo.svg?raw=true" alt="Sublime's custom image"/>
</p>

Yet another UDF Architecture Store implementation


## Features

- Minimalistic 
- Operates on Main or Background queue
- Light-weight Store proxies
- Thread Safe 
- Actions Interceptor 
____________


# Installation
 

## Swift Package Manager.

PureduxStore is available through Swift Package Manager. 
To install it, in Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repositoies URLs for the modules requried:

```
https://github.com/KazaiMazai/PureduxStore
```
____________


# Quick Start Guide

1. Import:
```swift
import PureduxStore

```

2. Create initial app state:

```swift
let initialState = AppState()

```

3. Create reducer:

```swift 
let reducer: (inout State, Action) -> Void = { state, action in

    //mutate state here

}

```

4. Create root store with initial app state and reducer. Get light-weight store:

```swift
let rootStore = RootStore<AppState, Action>(initialState: initialState, reducer: reducer)

let store = rootStore.getStore()
 
```

5.  Setup `AsyncActions` interceptor:

```swift
rootStore.interceptActions { action in
    guard let action = (action as? AsyncActions) else {
        return
    }
    
    action.execute(with: store)
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

