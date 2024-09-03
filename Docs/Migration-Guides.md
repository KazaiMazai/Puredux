
## Getting Prepared for Puredux 2.0

1. Update for the latest 1.x version
2. Follow deprecation notices to get prepared for smooth migration

Here is an overview of what to be changed:

### StoreFactory Changes

1. Replace `StoreFactory` with `StateStore`.

```swift
// Before:

let storeFactory = StoreFactory(
    MyInitialState(),
    qos: .userInteractive,
    reducer: myReducer
)

// After:

let store = StateStore(
    MyInitialState(),
    qos: .userInteractive,
    reducer: myReducer
)
```

2. Store Transformation Changes:

Before:

- `childStore(...)`
- `scopeStore(...)

After:

- `with(...)`
- `map(...)` or `flatMap(...)`

Follow deprecation notices documentation for more details.

### SwiftUI Bindings Changes

 Puredux 2.0 bind Stores with Views differently.
`StoreView` is a replacement for `ViewWithStore` provided to make the migration process easier.
 
 1. Migrate from `EnvStoreFactory` to `StateStore`
 2. Inject root store with `@InjectEntry`:

 ```swift
 
 extension Injected {
     @InjectEntry var appState = StateStore<AppState, Action>(AppState()) { state, action in
         state.reduce(action)
     }
 }
 
 ```

 3. Wrap your `FancyView` in a container view with  a`@State` store of a proper configuration
 4. Depending on how `ViewWithStore` was condigured:
    - `EnvStoreFactory` and an implicit single app store should use explicit `@StoreOf(\.appState)` store.
    - `ViewWithStore(...).childStore(...)`  should use `@StoreOf(\.appState).with(ChildState()) { ... }`
    - `ViewWithStore(...).scopeStore(...)` should use `@StoreOf(\.appState).map { ... }`
    - `ViewWithStore(...).store(...)`  should use explicit `Store(...)` or `StateStore(...)`
 5. Replace `ViewWithStore` with a `StoreView`

Follow deprecation notices documentation for more details.

### UIKit Bindings changes

The Presentable API is still available, so only minor changes are needed.

1. Replace deprecated methods:

```swift
// Before:

    myViewController.with(
         store: store,
         props: { state, store in
             // ...
         },
         presentationQueue: .sharedPresentationQueue,
         removeStateDuplicates: .keyPath(\.lastUpdated)
     )
     
// After:

    myViewController.setPresenter(
         store: store,
         props: { state, store in
             // ...
         },
         presentationQueue: .sharedPresentationQueue,
         removeStateDuplicates: .keyPath(\.lastUpdated)
     )
    
```

Follow deprecation notices documentation for more details.

## Puredux legacy to a single repository migration guide

Puredux was refactored from a set of packages to a single monorepository.

These changes will require a few updates.

### 1. Change the package:

If you were using any of the packages individually:

- PureduxStore
- PureduxSwiftUI
- PureduxUIKit

You should update them to Puredux:

In Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repository URL:

```
https://github.com/KazaiMazai/Puredux
```

Remove the individual repositories:

```
- https://github.com/KazaiMazai/PureduxUIKit
 
- https://github.com/KazaiMazai/PureduxSwiftUI
  
- https://github.com/KazaiMazai/PureduxStore
```

### 2. Fix imports:

Find and relace all the occurences of:

```swift
import PureduxSwiftUI
```

```
import PureduxUIKit
```

```
import PireduxStore

```

on 

```swift
import Puredux

```

## Puredux 1.0.x - 1.1.x Update

### Store migration

#### 1. Migrate From `RootStore` to `StoreFactory`:

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

#### 2. Update actions interceptor and pass in to store factory:

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
#### 3. Migrate from `proxy(...)` to `scope(...)`:

Before:

```swift
let storeProxy = rootStore.store().proxy { appState in appState.subState }

```

Now:

```swift
let scopeStore = storeFactory.scopeStore { appState in appState.subState }

```
 
### PureduxSwiftUI Bindings Migration Guide


1. Migrate to from `RootStore` to `StoreFactory` like mentioned in PureduxStore [docs](https://github.com/KazaiMazai/PureduxStore)

Before:

```swift
let appState = AppState()
let rootStore = RootStore<AppState, Action>(initialState: appState, reducer: reducer)
let rootEnvStore = RootEnvStore(rootStore: rootStore)
let fancyFeatureStore = rootEnvStore.store().proxy { $0.yourFancyFeatureSubstate }

let presenter = FancyViewPresenter() 

```

Now:

```swift
let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
let fancyFeatureStore = envStoreFactory.scopeStore { $0.yourFancyFeatureSubstate }

let presenter = FancyViewPresenter() 

```
2. Migrate from `StoreProvidingView` to `ViewWithStoreFactory` in case your implementation relied on injected `RootEnvStore`

Before:

```swift
 UIHostingController(
      rootView: StoreProvidingView(rootStore: rootEnvStore) {
        
        //content view
     }
 )
```

Now:

```swift
 UIHostingController(
    rootView: ViewWithStoreFactory(envStoreFactory) {
        
       //content view
    }
)
```


3. Migrate from `View.with(...)` extension to `ViewWithStore(...)`in case your implementation relied on explicit store

Before:

```swift 

 FancyView.with(
    store: fancyFeatureStore,
    removeStateDuplicates: .equal {
        $0.title
    },
    props: presenter.makeProps,
    queue: .main,
    content: { FancyView(props: $0) }
)
```

Now:

```swift 
ViewWithStore(props: presenter.makeProps) {
    FancyView(props: $0)
}
.usePresentationQueue(.main)
.removeStateDuplicates(.equal { $0.title })
.store(fancyFeatureStore)
                    
```

4. Migrate from `View.withEnvStore(...)` extension to `ViewWithStore(...)` in case your implementation relied on injected `RootEnvStore`

Before:

```swift 

 FancyView.withEnvStore(
    removeStateDuplicates: .equal {
        $0.title
    },
    props: presenter.makeProps,
    queue: .main,
    content: { FancyView(props: $0) }
)
```
Now:

```swift 
ViewWithStore(props: presenter.makeProps) {
  FancyView(props: $0)
}
.usePresentationQueue(.main)
.removeStateDuplicates(.equal { $0.title })

                    
```


### PureduxUIKit Bindings Migration Guide

Nothing needs to be changed.
