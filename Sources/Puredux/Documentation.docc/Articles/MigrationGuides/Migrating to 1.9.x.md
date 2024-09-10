# Migrating to 1.9.x 

Getting Ready for 2.0. 

## Overview

There are no breaking changes, but a big number of deprecations that will be needed to fix before migrating to 2.0
Generally, updating to the latest 1.9.x and following deprecation notices might go smoothly enough. 

Here are the details of the changes.

## Store Changes

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
+ protocol AsyncAppAction: AsyncAction & Action {}

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
-     },
-     reducer: reducer
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
-    initialState: LocalState(),
-    reducer: { localState, action  in
-       localState.reduce(action: action)
-    }   
- )


+ let childStore: StateStore<(AppState, LocalState), Action> = rootStore.with(
+    LocalState(),
+    reducer: { localState, action  in
        localState.reduce(action: action)
+    }  
+ )
 
```

### Scope Store Tranformation Changes

```diff
- let scopeStore = storeFactory.scopeStore { appState in appState.subState }

+ let scopeStore = rootStore.map { appState in appState.subState }

```

Follow deprecation notices documentation for more details.

## UI Related Changes

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
+         props: { state, store in
+             // ...
+         },
+         presentationQueue: .sharedPresentationQueue,
+         removeStateDuplicates: .keyPath(\.lastUpdated)
+     )
    
```
