
## PureduxStore Migration Guide

The old API will be deprecated in the next major release. 
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


## PureduxSwiftUI Bindings Migration Guide

Old API will be deprecated in the next major update. 
Good time to migrate to new API, especially if you plan to use new features like child stores.

<details><summary>Click for details</summary>
<p>

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


## PureduxUIKit Bindings Migration Guide

Nothing needs to be changed.
