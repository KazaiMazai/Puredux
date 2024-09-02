## Puredux

### Basics

- State is a type describing the whole application state or a part of it
- Actions describe events that may happen in the system and mutate the state
- Reducer is a function, that describes how Actions mutate the state
- Store is the heart of the whole thing. It takes Initial State and Reducer, performs mutations when Actions dispatched and deilvers new State to Observers


### Quick Start Guide

1. Import:
```swift
import Puredux

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
 
let childStore: StateStore<(AppState, LocalState), Action> = storeFactory.childStore(
    initialState: LocalState(),
    reducer: { localState, action  in
        localState.reduce(action: action)
    }
)
 
let observer = Observer<(AppState, LocalState)> { stateComposition, complete in
    // Handle your latest state here and dispatch some actions to the store
    //
    // - Do some work here and dispatch actions
    // childStore.dispatch(SomeAction()) if needed
    //
    // - Wanna keep receiving updated? Then:
    // complete(.active)
    //
    // - Work is done? Then:
    // complete(.dead)
   
}

childStore.subscribe(observer: observer)


```



### Basics Q&A

<details><summary>Click for details</summary>
<p>

   
#### What is StoreFactory?

StoreFactory is a factory for Stores and StateStores.

It suppports creation of the following store types:
- Root Store - plain Store as proxy to the factory's' root store
- Scope Store - scoped Store as proxy to the factory root store
- Child Store - child StateStore with `(Root, Local) -> Composition` state mapping and it's own lifecycle

#### What queue does the root store operate on?

- By default, it works on a global serial queue with `userInteractive` quality of service. QoS can be changed.
 
 
#### What is a Store?

- Store is a lightweight store. 
- It's a proxy to its parent store: it forwards subscribtions and all dispatched Actions to it.
- Store is designed to be passed all over the app safely without extra effort.
- It's threadsafe. It allows to dispatch actions and subscribe from any thread. 


#### What is a Child StateStore?

- StateStore owns the state.
- It's a proxy to its parent store: it forwards subscribtions and all dispatched Actions to it.
- It's designed to manage state lifecycle
- It's threadsafe. It allows to dispatch actions and subscribe from any thread. 
- It keeps a *strong* reference to the root store, that's why requries a careful treatment.


#### How to unsubscribe from store?
 
Call store observer's complete handler with dead status:
  
```swift 
let observer = Observer<State> { state, complete in
    
    complete(.dead)
}
 
``` 

#### Does Puredux provide a single or multiple stores?

It does both. Puredux allows to have a single store that can be scoped to proxy substores for sake of features isolation.
It also allows to have a single root store with multiple plugable child stores for even deeper features isolation.
 
#### What if I don't know if I need a single or multi store?

Puredux is designed in a way that you can seamlessly scale up to multiple stores when needed.
- Start with a single store. 
- If the single app state is starting to feel overbloated think about using scope stores.
- If you start to plug/unplug some parts of the single state it might be a sign to start using
child stores.


</p>
</details>

### Root Store Q&A

<details><summary>Click for details</summary>
<p>

#### What is a root store?

- StoreFactory has an internal root store object, 
- Root Store is Store that is created by `rootStore()` method 
- Root Store is a simple proxy to the factory's root store object
- Root Store keeps weak reference to the factory root store object store

#### How to manage factory root store and its state lifecycle?

Root store object lifecycle and its state managed by factory. 
Initalized together with the factory and released when factory is released
It exist as long as the factory exist.

#### How to create a root store?

```swift
let store = factory.rootStore()

```

#### Is root store created with initial root state?

No. State is initialized when factory is created. Then it lives together with it.
Typically factory's' lifecycle matches app's lifecycle.

</p>
</details>

### Scoped Store Q&A

<details><summary>Click for details</summary>
<p>

#### What's the scoped store?
 
- Scoped store is a proxy to the root store  
- Scoped doesn't have its own local state.
- Scoped doesn't have its own reducer
- Scoped store's state is a mapping of the root state.
- Doesn't create any child-parent hierarchy

#### How to create a scoped store?

```swift
let scopedStore: Store<Substate, Action> = storeFactory.scopeStore { appState in appState.subState }

```

#### Does Proxy Store deduplicate state changes somehow?
- No, Proxy Store observers are triggered at every root store state change.

#### What for?
- The purpose is to scope entire app's state to local app feature state
  
</p>
</details>

### Child Store Q&A

<details><summary>Click for details</summary>
<p>

#### What is child store?

- Child store is a separate store 
- Child store has its own local state
- Child store has its own local state reducer
- Child store is attached to the factory root store
- Child store's state is a composition of parent state and local state
- Creates child-parent hierarchy

#### How to create child store?

StoreFactory allows to create child stores. 
You should only provide initial state and reducer:

```swift
 
let childStateStore: StateStore<(AppState, LocalState), Action> storeFactory.childStore(
    initialState: LocalState(),
    reducer: { localState, action  in
        localState.reduce(action: action)
    }
)

```
#### How to manage child store and its state lifecycle?

Child store is a `StateStore`. The state will exist while StateStore exists.

#### Why root store and scope store is a Store<State, Action> and child store is a `StateStore<State, Action>`?

Root store's and scope store's lifecycle is controlled by StoreFactory. 
They exist while factory exist. Typically during the whole app lifecycle.

Child store is for the cases when we want to take over the control of the state lifecycle.
Typically when we present screens or some flows of the app.
 
`StateStore<State, Action>` prevents from errors that could occur because of confusion with 
Store<State, Action 


#### How are Actions dispatched with parent/child stores?

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

#### Does Child Store deduplicate state changes somehow?
- No. Child Store observers are triggered at every state change: both parent's state changes and child's ones.

</p>
</details>

## SwiftUI Integration

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

### Q&A

<details><summary>Click for details</summary>
<p>


#### How to connect view to store?

PureduxSwiftUI allows to connect view to the following kinds of stores:

- Explicitly provided store
- Root store - app's central single store
- Scope store - scoped proxy to app's central single store
- Child store - a composition of independent store with app's root store 

#### How to connect view to the explicitly provided store:

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

#### How to connect view to the EnvStoreFactory's root store:
 
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

#### How to connect view to the EnvStoreFactory's root scope store

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
#### How to connect view to the EnvStoreFactory's root child store

Child store is special.

- ChildStore is a composition of root store and newly created local store.
- ChildStore's state is a mapping of the local child state and root store's state
- Child store has its own reducer. 
- ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore's` lifecycle.
- Child state would be destroyed when ViewWithStore disappears from the hierarchy.

When child store is used, view recieves composition of root and child state.
This allows `View` to use both a local child state as well as global app's root state.

###### Child actions dispatching also works in a special way.
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


#### How to split view from state with props?

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


#### Which DispatchQueue is used to prepare props?

- By default, it works on a shared PresentationQueue. It is a global serial queue with user interactive quality of service. The purpose is to do as little as possible on the main thread queue.
  
  
#### Is it safe at all?
  
- PureduxSwiftUI hops to the main dispatch queue in the end to update View. 
So yes, it's safe. Unless you try to do UI related things (you should not) during your `Props` preparation.  

#### How to change  presentation queue that is used to prepare props?


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
 
#### Why we might need to prepare props on background queue?
  
- Props evaluation maybe heavier than we would love to. 
We may deal with a large array of items, AttributedStrings, and any other slow things.
Doing it on the main queue may eventually slow down our fancy app.


#### How to deduplicate state changes?

- State deduplication is done by providing a way to compare two states on equality.
- It allows to avoid props evaluation on every state update
- It's done with the help of `Equating<State>` guy:

```swift 
ViewWithStore {
   //Your content here
}
.removeStateDuplicates(.equal { $0.title })
  
```
#### Why we might need to deduplicate state changes?
  
- Props evaluation maybe heavier than we would love to. 
The app state may be huuuuge and we might love to re-evaluate `Props` only when it's necessary.

#### Why we need `Equating<State>` guy?

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


#### Any other `Equating<State>` details ?

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

## UIKit Integration

1. Import:
```swift
import Puredux

```

2. Implement view controller and conform it to `Presentable`

```swift

final class FancyViewController: UIViewController, Presentable {
    var presenter: PresenterProtocol? { get set }

    //update views here
    func setProps(_ props: Props) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.subscribeToStore()
    }
}

extension FancyViewController {
    struct Props {
        let title: String
        let onTap: () -> Void
    }
}

```


3.  Prepare `Props` with current state and store. For e.g. as a part of some fancy presenter:

```swift

struct FancyVCPresenter {
    //prepare props for your fancy view controller
    func makeProps(state: FancyFeatureState, 
                   store: Store<FancyFeatureState, Action>) -> FancyViewController.Props {
        
        Props(title: "Hello"
              onTap: {
                  store.dispatch(
                      FancyTapAction()
                  )
              }
        )
    }
}

```

4.  Connect your fancy view controller to store, providing **how** it should be connected:

```swift
let appState = AppState()
let factory = StoreFactory<AppState, Action>(initialState: appState, reducer: reducer)

let fancyFeatureStore = rootStore.scopeStore { $0.yourFancyFeatureSubstate }
 
let presenter = FancyVCPresenter()
let viewController = FancyViewController()

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps)
 
```


5. Present it immediately!


### Q&A

<details><summary>Click for details</summary>
<p>


#### What is PureduxStore?

- It's minilistic MVI architecture state store implementation. More details can be found in [PureduxStore Docs](Docs/PureduxStore.md)


#### Which DispatchQueue is used to prepare props?

- By default, it works on a shared PresentationQueue. It is a global serial queue with user interactive quality of service. The purpose is to do as little as possible on the main thread queue.
  
  
#### Is it safe at all?
  
- PureduxUIKit hops to the main dispatch queue to update UIViewController. So yes, it's safe. Unless you try to do UIKit related things (you should not) during your `Props` preparation.  

#### How to change  presentation queue that is used to prepare props?


- PureduxUIKit allows to use main queue or user-provided custom queue. The only requirement for the custom queue is to be **serial** one.

```swift 
viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    presentationQueue: .main)
                    
```

or standalone queue:
              
```swift       

let queue = DispatchQueue(label: "some.queue", qos: .userInteractive)

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    presentationQueue: .serialQueue(queue))
        
```

#### How to deduplicate state changes?

- State deduplication is done by providing a way to compare two states on equality.
- It's done with the help of `Equating<State>` guy:

```swift 

viewController.with(store: fancyFeatureStore,
                    props: presenter.makeProps,
                    removeStateDuplicates: .equal {
                        $0.title
                    })
                    
```

#### Why we need `Equating<State>` guy?

- Depending on context (or particular screen), we might be interested in different part of the state. Different properties of the same type.
- And would like to deduplicate updates depending on it.
- That's why single `Equatable` implementation won't work here.

```swift 

firstViewController.with(store: fancyFeatureStore,
                        props: firstVCpresenter.makeProps,
                        removeStateDuplicates: .equal {
                            $0.title
                        })
                    
secondViewController.with(store: fancyFeatureStore,
                    props: secondVCpresenter.makeProps,
                    removeStateDuplicates: .equal {
                        $0.subtitle
                    })
                    
```

#### Any other `Equating<State>`  details ?

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

viewController.with(store: fancyFeatureStore,
                    props: vcPresenter.makeProps,
                    removeStateDuplicates: 
                        .equal { $0.title } &&
                        .equal { $0.subtitle }
                    )
            
```


</p>
</details>
 
