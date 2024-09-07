# Migrating to 2.0
 
## Getting Prepared

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

## UIKit Bindings changes

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

## Update to 2.0.x Package Version

At this point, all the deprecations mentioned above will be removed.

Still, there will be a few things to be updated.

### Store and StoreProtocol Changes

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
