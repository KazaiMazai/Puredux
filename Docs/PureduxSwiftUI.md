<p align="center">
  <img src="PureduxSwiftUI.svg?raw=true" alt="Sublime's custom image"/>
 </p>
 

## Quick Start Guide

1. Import:

```swift
import Puredux

```

2. Implement your FancyView

```swift

typealias Command = () -> Void

struct FancyView: View {
    let title: String
    let didAppear: Command
    
    var body: some View {
        Text(title)
            .onAppear { didAppear() }
    }
}
```

3. Declare how view connects to store:

```swift

extension FancyView {

  init(state: AppState, dispatch: @escaping Dispatch<Action>) {
      self.init(
          title: state.title,
          didAppear: { dispatch(FancyViewDidAppearAction()) }
      )
   }
}
```

3. Connect your fancy view to the store, providing **how** it should be connected:

```swift

let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(
    initialState: state,
    reducer: { state, action in state.reduce(action) }
)
 
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
 
UIHostingController(
    rootView: ViewWithStoreFactory(envStoreFactory) {
        
        ViewWithStore { state, dispatch in
            FancyView(
              state: state,
              dispatch: dispatch
            )
        }
    }
)
 
```



</p>
</details>

## Q&A

<details><summary>Click for details</summary>
<p>


### What is PureduxStore?

It's minilistic UDF architecture store implementation. 
More details can be found [here](https://github.com/KazaiMazai/PureduxStore)


### How to connect view to store?

PureduxSwiftUI allows to connect view to the following kinds of stores:

- Explicitly provided store
- Root store - app's central single store
- Scope store - scoped proxy to app's central single store
- Child store - a composition of independent store with app's root store 

### How to connect view to the explicitly provided store:

```swift

let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
let featureStore = envStoreFactory.scopeStore { $0.yourFancyFeatureSubstate }
 
UIHostingController(
    rootView: ViewWithStore { state, dispatch in
        FancyView(
          state: state,
          dispatch: dispatch
        )
    }
    .store(featureStore)
)

```

### How to connect view to the EnvStoreFactory's root store:
 
```swift
let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
 
UIHostingController(
    rootView: ViewWithStoreFactory(envStoreFactory) {
        
        ViewWithStore { appState, dispatch in
            FancyView(
              state: state,
              dispatch: dispatch
            )
        }
    }
)

```

### How to connect view to the EnvStoreFactory's root scope store

```swift

let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
 
UIHostingController(
    rootView: ViewWithStoreFactory(envStoreFactory) {
        
        ViewWithStore { featureSubstate, dispatch in
            FancyView(
              state: substate,
              dispatch: dispatch
            )
        }
        .scopeStore({ $0.yourFancyFeatureSubstate })
    }
)

```
### How to connect view to the EnvStoreFactory's root child store

Child store is special. More details in PureduxStore [docs](https://github.com/KazaiMazai/PureduxStore)

- ChildStore is a composition of root store and newly created local store.
- ChildStore's state is a mapping of the local child state and root store's state
- Child store has its own reducer. 
- ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore's` lifecycle.
- Child state would be destroyed when ViewWithStore disappears from the hierarchy.

When child store is used, view recieves composition of root and child state.
This allows `View` to use both a local child state as well as global app's root state.

#### Child actions dispatching also works in a special way.
Child actions dispatching and state delivery works in the following way:
- Actions go down from child stores to root store
- Actions never go from one child stores to another child store
- States go up from root store to child stores and views

When action is dispatched to RootStore:
- action is delivered to root store's reducer
- action is not delivered to child store's reducer
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


```swift

let appState = AppState()
let storeFactory = StoreFactory<AppState, Action>(initialState: state, reducer: reducer)
let envStoreFactory = EnvStoreFactory(storeFactory: storeFactory)
 
UIHostingController(
    rootView: ViewWithStoreFactory(envStoreFactory) {
        
        ViewWithStore { stateComposition, dispatch in
            FancyView(
              state: substate,
              dispatch: dispatch
            )
        }
        .childStore(
            initialState: ChildState(),
            stateMapping: { appState, childState in
                StateComposition(appState, childState)
            },
            reducer: { childState, action in childState.reduce(action) }
        )
    }
)

```


### How to split view from state with props?

PureduxSwiftUI allows to add an extra presentation layer between view and state.
It can be done for view reusability purposes. 
It also allows to improve performance by moving props preparation to background queue.

We can add `Props`:

```swift
struct FancyView: View {
    let props: Props
    
    var body: some View {
        Text(props.title)
            .onAppear { props.didAppear() }
    }
}

extension FancyView {
    struct Props {
        let title: String
        let didAppear: Command
    }
}

```
`Props` can be though of as a view model.

2.  Prepare `Props` . 

```swift

extension FancyView.Props {
    static func makeProps(
          state: AppState, 
          dispatch: @escaping Dispatch<Action>) -> FancyView.Props {
        
        //prepare props for your fancy view
    }
}

```

3. Connect View with store by providing props closure and content view from `Props`:

```swift

ViewWithStore(props: FancyView.Props.makeProps) { props in
    FancyView(
      props: props
    )
}

```

This allows to make Views dependent only on `Props` and reuse it in different ways.


### Which DispatchQueue is used to prepare props?

- By default, it works on a shared PresentationQueue. It is a global serial queue with user interactive quality of service. The purpose is to do as little as possible on the main thread queue.
  
  
### Is it safe at all?
  
- PureduxSwiftUI hops to the main dispatch queue in the end to update View. 
So yes, it's safe. Unless you try to do UI related things (you should not) during your `Props` preparation.  

### How to change  presentation queue that is used to prepare props?


- PureduxSwiftUI allows to use main queue or user-provided custom queue. The only requirement for the custom queue is to be **serial** one.

```swift 
ViewWithStore {
   //Your content here
}
.usePresentationQueue(.main)
  
```

or standalone queue:
              
```swift       
let queue = DispatchQueue(label: "some.queue", qos: .userInteractive)
  
```
  
```swift 
ViewWithStore {
   //your content here
}
.usePresentationQueue(.serialQueue(queue))
  
```
 
### Why we might need to prepare props on background queue?
  
- Props evaluation maybe heavier than we would love to. 
We may deal with a large array of items, AttributedStrings, and any other slow things.
Doing it on the main queue may eventually slow down our fancy app.


### How to deduplicate state changes?

- State deduplication is done by providing a way to compare two states on equality.
- It allows to avoid props evaluation on every state update
- It's done with the help of `Equating<State>` guy:

```swift 
ViewWithStore {
   //Your content here
}
.removeStateDuplicates(.equal { $0.title })
  
```
### Why we might need to deduplicate state changes?
  
- Props evaluation maybe heavier than we would love to. 
The app state may be huuuuge and we might love to re-evaluate `Props` only when it's necessary.

### Why we need `Equating<State>` guy?

- Depending on context (or particular screen), we might be interested in different part of the state. Different properties of the same type.
- And would like to deduplicate updates depending on it.
- That's why single `Equatable` implementation won't work here.

```swift 
VStack {  
    ViewWithStore { state, dispatch in
        FancyTitleView(state: state, dispatch: dispatch)
    )
    .removeStateDuplicates(.equal { $0.title })

    ViewWithStore { state, dispatch in
        FancySubtitleView(state: state, dispatch: dispatch)
    )
    .removeStateDuplicates(.equal { $0.subtitle })
}               
```


### Any other `Equating<State>` details ?

- Equating is a protocol witness for Equtable. It answers the question: "Are these states equal?" 
- With the help of it, deduplication happens.

Here is the definition:

```swift
  
    Equating<T> { (lhs: T, rhs: T) -> Bool
        //compare here
    }

```

It has handy extensions, like  `Equating.alwaysEqual` or `Equating.neverEqual` as well as `&&` operator:

```swift 

ViewWithStore { state, dispatch in
        FancyView(state: state, dispatch: dispatch)
)
.removeStateDuplicates(
    .equal { $0.title } &&
    .equal { $0.subtitle }
)            
```


</p>
</details>

