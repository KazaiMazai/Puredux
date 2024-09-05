## Table Of Contents

- [Getting Prepared for Puredux 2.0](#getting-prepared-for-puredux-20)
  * [StoreFactory Changes](#storefactory-changes)
  * [Child Store Changes](#child-store-changes)
  * [Scope Store Tranformation Changes](#scope-store-tranformation-changes)
  * [SwiftUI Bindings Changes](#swiftui-bindings-changes)
  * [UIKit Bindings changes](#uikit-bindings-changes)
- [Puredux 1.2.0 - 1.3.0 Minor breaking changes](#puredux-120---130-minor-breaking-changes)
  * [Referenced StoreObject](#referenced-storeobject)
  * [StoreObject constructor](#storeobject-constructor)
- [Puredux 1.2.0: From legacy multirepo to a single repository](#puredux-120--from-legacy-multirepo-to-a-single-repository)
  * [1. Change the package:](#1-change-the-package-)
  * [2. Fix imports:](#2-fix-imports-)
- [Puredux 1.0.x - 1.1.x Update](#puredux-10x---11x-update)
  * [Store migration](#store-migration)
    + [1. Migrate From `RootStore` to `StoreFactory`:](#1-migrate-from--rootstore--to--storefactory--)
    + [2. Update actions interceptor and pass in to store factory:](#2-update-actions-interceptor-and-pass-in-to-store-factory-)
    + [3. Migrate from `proxy(...)` to `scope(...)`:](#3-migrate-from--proxy----to--scope----)
  * [PureduxSwiftUI Bindings Migration Guide](#pureduxswiftui-bindings-migration-guide)
  * [PureduxUIKit Bindings Migration Guide](#pureduxuikit-bindings-migration-guide)


## Puredux 1.9.x - 2.0

## Store breaking changes

`Store<State, Action>`  was renamed to `AnyStoreStore<State, Action>`

```diff
- Store<State, Action> 
+ AnyStore<State, Action>

```

`StoreProtocol<State, Action>`  was renamed to `Store<State, Action>`
 
```diff
- any StoreProtocol<State, Action> 
+ any Store<State, Action>

```

## Getting Prepared for Puredux 2.0

1. Update for the latest 1.x version
2. Follow deprecation notices to get prepared for smooth migration

Here is an overview of what to be changed:

### StoreFactory Changes

1. Replace `StoreFactory` with `StateStore`.

```diff

- let storeFactory = StoreFactory(
-     MyInitialState(),
-     qos: .userInteractive,
-     reducer: myReducer
- )

+ let store = StateStore(
+     MyInitialState(),
+     qos: .userInteractive,
+     reducer: myReducer
+ )
```

### Action Interceptor Changes

Now there is no need in Action Interceptor any more, built-in `AsyncActions` protocol should be used instead:


```diff

- protocol AsyncAppAction: Action {
-     func execute(completeHandler: @escaping (AppAction) -> Void)
- }
+ protocol AsyncAppAction: AsyncAction & AppAction {}

- let storeFactory = StoreFactory<AppState, Action>(
-     initialState: initialState, 
-     interceptor: { action, dispatch in
-        guard let action = (action as? AsyncAppAction) else  {
-            return
-        }
-
-        DispatchQueue.main.async {
-            action.execute(completeHandler: dispatch)
-        }
-    },
-   reducer: reducer
-)

+ let store = StateStore(
+     MyInitialState(),
+     qos: .userInteractive,
+     reducer: myReducer
+ )
```



### Child Store Changes

```diff
- let childStore: StateStore<(AppState, LocalState), Action> = storeFactory.childStore(
-   initialState: LocalState(),
-    reducer: { localState, action  in
-        localState.reduce(action: action)
-    }
- )


+ let childStore: StateStore<(AppState, LocalState), Action> = rootStore.with(
+       LocalState(),
+       reducer: { localState, action  in
+           localState.reduce(action: action)
+       }
+ )
 
```

### Scope Store Tranformation Changes

```diff
- let scopeStore = storeFactory.scopeStore { appState in appState.subState }

+ let scopeStore = rootStore.map { appState in appState.subState }

```

Follow deprecation notices documentation for more details.

### SwiftUI Bindings Changes

 Puredux 2.0 bind Stores with Views differently.
`StoreView` is a replacement for `ViewWithStore` provided to make the migration process easier.
 
 1. Migrate from `StoreFactory` and `EnvStoreFactory` to `StateStore`
 2. Inject root store with `@InjectEntry`:

 ```diff
 
+ extension Injected {
+     @InjectEntry var appState = StateStore<AppState, Action>(AppState()) { state, action in
+         state.reduce(action)
+     }
+  }
 
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

```diff

-    myViewController.with(
-         store: store,
-         props: { state, store in
-             // ...
-         },
-         presentationQueue: .sharedPresentationQueue,
-         removeStateDuplicates: .keyPath(\.lastUpdated)
-     )
     
+    myViewController.setPresenter(
+         store: store,
+        props: { state, store in
+             // ...
+         },
+         presentationQueue: .sharedPresentationQueue,
+         removeStateDuplicates: .keyPath(\.lastUpdated)
+     )
    
```

Follow deprecation notices documentation for more details.

## Puredux 1.2.0 - 1.3.0 Minor breaking changes

There are a few breaking changes related to the replacement of StoreObject with a StateStore.

### Referenced StoreObject
StoreObject used to be a class, StateStore is a struct.

StoreObject that were weakly referenced wll require a fix.
Since is StoreObjectnow a typealias of StateStore the compiler will point you to all the places that require a fix:

```diff
- let storeObject: StoreObject = ....

- doSomethingWithStore() { [weak storeObject] in
-     storeObject?.dispatch(...)
- }

+ let stateStore: StateStore = ....
+ let store = stateStore.store()
+ doSomethingWithStore() { 
+    store.dispatch(...)
+ }
```

### StoreObject constructor

The following StoreObject's constructor is no longer available. It was not needed except for the cases when you wanted to mock your StoreObject.

It can be fixed by replacing StoreObject with a Store
```diff
- StoreObject(dispatch: { ... }, subscribe: { ... })
+ Store(dispatch: { ... }, subscribe: { ... })
```




## Puredux 1.2.0: From legacy multirepo to a single repository 

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
