# Migrating to 1.1.x 

No breaking changes but a few deprecations to address.

## Store Changes

### 1. Migrate From `RootStore` to `StoreFactory`:

Before: 

```diff
- let rootStore = RootStore<AppState, Action>(
-     queue: StoreQueue = .global(qos: .userInteractive)
-     initialState: initialState, 
-     reducer: reducer
- )
- 
- let store: Store<AppState, Action> = rootStore.store()


+ let storeFactory = StoreFactory<AppState, Action>(
+     initialState: initialState, 
+     qos: .userInteractive,
+     reducer: reducer
+ )
+ 
+ let store: Store<AppState, Action> = storeFactory.rootStore()

```

MainQueue is not available for Stores any more. 
Since now, stores always operate on a global serial queue with configurable QoS.

### 2. Update actions interceptor and pass in to store factory:


```diff

- rootStore.interceptActions { action in
-     guard let action = ($0 as? AsyncAppAction) else  {
-         return
-     }
-     
-     DispatchQueue.main.async {
-         action.execute { store.dispatch($0) }
-     }   
- }


+ let storeFactory = StoreFactory<AppState, Action>(
+     initialState: initialState, 
+     interceptor:  { action, dispatched in
+         guard let action = ($0 as? AsyncAppAction) else  {
+             return
+         }
+     
+         DispatchQueue.main.async {
+             action.execute { dispatch($0) }
+         } 
+     },
+     reducer: reducer
+ )

```
### 3. Migrate from `proxy(...)` to `scope(...)`:


```diff
- let storeProxy = rootStore.store().proxy { appState in appState.subState }

+ let scopeStore = storeFactory.scopeStore { appState in appState.subState }

```
 
## UI-Related Changes

### SwiftUI Bindings Changes


1. Migrate to from `RootStore` to `StoreFactory` like mentioned in PureduxStore [docs](https://github.com/KazaiMazai/PureduxStore)


```diff
- let appState = AppState()
- let rootStore = RootStore<AppState, Action>(initialState: appState, reducer: reducer)
- let rootEnvStore = RootEnvStore(rootStore: rootStore)
- let fancyFeatureStore = rootEnvStore.store().proxy { $0.yourFancyFeatureSubstate }
- 
- let presenter = FancyViewPresenter() 

+ let appState = AppState()
+ let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
+ let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
+ let fancyFeatureStore = envStoreFactory.scopeStore { $0.yourFancyFeatureSubstate }
+ 
+ let presenter = FancyViewPresenter() 

```
2. Migrate from `StoreProvidingView` to `ViewWithStoreFactory` in case your implementation relied on injected `RootEnvStore`

```diff
- UIHostingController(
-       rootView: StoreProvidingView(rootStore: rootEnvStore) {
-         
-         //content view
-      }
-  )


+ UIHostingController(
+     rootView: ViewWithStoreFactory(envStoreFactory) {
+         
+        //content view
+     }
+ )
```


3. Migrate from `View.with(...)` extension to `ViewWithStore(...)`in case your implementation relied on explicit store

```diff 

- FancyView.with(
-     store: fancyFeatureStore,
-     removeStateDuplicates: .equal {
-         $0.title
-     },
-     props: presenter.makeProps,
-     queue: .main,
-     content: { FancyView(props: $0) }
- )

+ ViewWithStore(props: presenter.makeProps) {
+     FancyView(props: $0)
+ }
+ .usePresentationQueue(.main)
+ .removeStateDuplicates(.equal { $0.title })
+ .store(fancyFeatureStore)
                    
```

4. Migrate from `View.withEnvStore(...)` extension to `ViewWithStore(...)` in case your implementation relied on injected `RootEnvStore`

 
```diff 

- FancyView.withEnvStore(
-    removeStateDuplicates: .equal {
-        $0.title
-    },
-    props: presenter.makeProps,
-    queue: .main,
-    content: { FancyView(props: $0) }
-)


+ ViewWithStore(props: presenter.makeProps) {
+   FancyView(props: $0)
+ }
+ .usePresentationQueue(.main)
+ .removeStateDuplicates(.equal { $0.title })

```

### UIKit Bindings 

Nothing needs to be changed.
