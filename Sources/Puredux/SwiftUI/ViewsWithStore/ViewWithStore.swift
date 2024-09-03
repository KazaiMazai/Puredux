//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09.03.2023.
//

import SwiftUI

/**
 ViewWithStore connects its `ContentView` to the store.

 Every time we dispatch an action to the store, it triggers a view update cycle.
 `Props` are re-evaluated according to state deduplication rules.
 `Content` is re-rendered when props change.

 **Props Evaluation**

 The typical flow is:

 `State` -> `Props` -> `Content`.

 It allows optimizing the `Props` evaluation by hopping to a global queue.

 However, `Props` is an extra layer that is not required and can be skipped,
 making the flow simpler:

 `State` -> `Content`.

 **Important to note:**

 Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

 **Usage:**

 ```swift
 let factory = StoreFactory(
    initialState: AppState(),
    reducer: { state, action in state.reduce(action) }
 )

 let envFactory = EnvStoreFactory(factory)

 UIHostingController(
     rootView: ViewWithStoreFactory(envFactory) {

        ViewWithStore { state, dispatch in
            FancyView(
                title: state.title,
                onTap: { dispatch(TapAction()) }
            )
        }
   }
 )
 ```
 
 ## Migration to 2.0
 
 Puredux 2.0 bind Stores with Views differently. `StoreView` is provided to make the migration process easier..
 
 
 1. Migrate from `StoreFactory` and `EnvStoreFactory` to `StateStore`
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

 */

@available(*, deprecated, message: "Will be removed in 2.0. Checkout migration guide.")
public struct ViewWithStore<ViewState, Action, Props, Content: View>: View {
    let props: (_ state: ViewState, _ store: PublishingStore<ViewState, Action>) -> Props
    let content: (_ props: Props) -> Content
    private(set) var presentationSettings: PresentationSettings<ViewState> = .default

    public var body: some View {
        ViewWithRootStore(
            content: self,
            presentationSettings: presentationSettings
        )
    }
}

public extension ViewWithStore {
    /**
     View modifier that updates `ViewWithStore` deduplication settings.
     
     Allows deduplicating state changes and skipping the evaluation of `Props` when not necessary.
     When the new state is equal to the previous one, deduplication occurs.
     
     **Important to note:**
     By default, deduplication is not applied.
     
     - Parameter equating: defines the rule allowing states to be considered equal
     
     - Returns: `ViewWithStore` with modified deduplication settings
        
     */
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.removeDuplicates = equating.predicate
        return selfCopy
    }

    /**
     View modifier that updates `ViewWithStore` presentation settings.
     
     Allows choosing the queue on which evaluation of `Props` would occur.
     The following PresentationQueue configs are supported:
     - Shared presentation queue: global serial queue with userInteractive QoS
     - Main: main queue
     - Serial queue: use queue provided by developer
     
     **Important to note:**
     - By default, the shared presentation queue is used.
     - Serial queue config should be used with exactly *serial* queue.
     
     - Parameter equating: defines the rule allowing to consider states as equal
     
     - Returns: `ViewWithStore` with modified deduplication settings
     */
    func usePresentationQueue(_ queue: PresentationQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.queue = queue
        return selfCopy
    }
}


public extension ViewWithStore {

    /**
     Initializes ViewWithStore which connects its `ContentView` to the store.
     
     - Parameter props: defines how `Props` are created from the state and store for action dispatching
     - Parameter content: defines how `ContentView` is created from props.
     
     This constructor is provided mainly for backward compatibility and easier migration.
     The following construction with a dispatch closure is preferable:
     ```swift
     init(props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props, content: @escaping (Props) -> Content) {
        // ...
     }
     ```
     Usage:
     
     ```swift
     UIHostingController(rootView: ViewWithStoreFactory(envFactory) {
        ViewWithStore(
              props: { state, store in
                  FancyView.Props(
                      title: state.title,
                      onTap: { store.dispatch(TapAction()) }
                  )
              },
              content: { FancyView(props: $0) }
          )
      }
    ```
        
    ## Migtation to 2.0
     
     `EnvStoreFactory` and an implicit single app store should migrate to explicit `@StoreOf(\.appState)` store.
     
     ```swift
     struct FancyViewContainer: View  {
        @State @StoreOf(\.appState) var singleAppStore: StateStore<AppState, Action>
           
        var body: some View {
              StoreView(store) { state, dispatch in
                  FancyView(
                      // ...
                  )
              }
         }
     }
    ```
     - Note: Cheсkout the `ViewWithStore` migration guide.
    */
    init(props: @escaping (ViewState, PublishingStore<ViewState, Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = props
        self.content = content
    }

    /**
     Initializes ViewWithStore which connects its `ContentView` to the store.

     - Parameter props: defines how `Props` are created from the state and action dispatching closure.
     - Parameter content: defines how `ContentView` is created from props.

     Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

     Usage:
     ```swift
     UIHostingController(rootView: ViewWithStoreFactory(envFactory) {
        ViewWithStore(
            props: { state, dispatch in
                FancyView.Props(
                    title: state.title,
                    onTap: { dispatch(TapAction()) }
                  )
              },
              content: { FancyView(props: $0) }
        )
     }
     ```
     ## Migtation to 2.0
      
      `EnvStoreFactory` and an implicit single app store should migrate to explicit `@StoreOf(\.appState)` store.
      
      ```swift
      struct FancyViewContainer: View  {
         @State @StoreOf(\.appState) var singleAppStore: StateStore<AppState, Action>
            
         var body: some View {
               StoreView(store) { state, dispatch in
                   FancyView(
                       // ...
                   )
               }
          }
      }
     ```
      - Note: Cheсkout the `ViewWithStore` migration guide.
     
    */
    init(props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = { state, store in props(state, store.dispatch) }
        self.content = content
    }
}


public extension ViewWithStore where Props == (ViewState, PublishingStore<ViewState, Action>) {
    
    /**
     Initializes ViewWithStore which connects its `ContentView` to the store.

      - Parameter content: defines how `ContentView` is created from the state and store for action dispatching

      This constructor is provided mainly for backward compatibility and easier migration.
      The following construction with a dispatch closure is preferable:
     
     ```swift
     init(content: @escaping (Props) -> Content) { ... }
     ```
        
     Usage:
     
     ```swift
     UIHostingController( rootView: ViewWithStoreFactory(envFactory) {
        ViewWithStore { state, store in
            FancyView(
                title: state.title,
                onTap: { store.dispatch(TapAction()) }
            )
        }
    })
        
    ```
     ## Migtation to 2.0
      
      `EnvStoreFactory` and an implicit single app store should migrate to explicit `@StoreOf(\.appState)` store.
      
      ```swift
      struct FancyViewContainer: View  {
         @State @StoreOf(\.appState) var singleAppStore: StateStore<AppState, Action>
            
         var body: some View {
               StoreView(store) { state, dispatch in
                   FancyView(
                       // ...
                   )
               }
          }
      }
     ```
      - Note: Cheсkout the `ViewWithStore` migration guide.
     */
    init(_ content: @escaping (Props) -> Content) {
        self.props = { state, store in (state, store) }
        self.content = content
    }
}

public extension ViewWithStore where Props == (ViewState, PublishingStore<ViewState, Action>) {
    /**
     Initializes ViewWithStore which connects its `ContentView` to the store.

     - Parameter content: defines how `ContentView` is created from the state and store for action dispatching

     Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

     Usage:
     
     ```swift
     UIHostingController( rootView: ViewWithStoreFactory(envFactory) {
        ViewWithStore { state, dispatch in
            FancyView(
                title: state.title,
                onTap: { dispatch(TapAction()) }
            )
        }
     })
     
     ```
     ## Migtation to 2.0
      
      `EnvStoreFactory` and an implicit single app store should migrate to explicit `@StoreOf(\.appState)` store.
      
      ```swift
      struct FancyViewContainer: View  {
         @State @StoreOf(\.appState) var singleAppStore: StateStore<AppState, Action>
            
         var body: some View {
               StoreView(store) { state, dispatch in
                   FancyView(
                       // ...
                   )
               }
          }
      }
     ```
      - Note: Cheсkout the `ViewWithStore` migration guide.
     
     */
    
    init(_ content: @escaping (ViewState, @escaping Dispatch<Action>) -> Content) {
        self.props = { state, store in (state, store) }
        self.content = { props in content(props.0, props.1.dispatch) }
    }
}


public extension ViewWithStore {
    /**
      Connects ViewWithStore's `ContentView` to the provided store.

      This method allows skipping the use of `EnvStoreFactory`'s root store and connects `ContentView` directly to the provided store.

      This can be useful for manually crafted store configurations or for testing purposes.

      - Parameter store: provided store to connect to
      - Returns: `ViewWithStore` connected to the provided store

      **Usage:**
     
        ```swift
        let testState = AppState() 
        let statePublisher = CurrentValueSubject<TestAppState, Never>(testState)
        
        let testStore = PublishingStore( 
            statePublisher: statePublisher.eraseToAnyPublisher(),
            dispatch: { action in print(action) }
        )

        UIHostingController(
            rootView: ViewWithStore { state, dispatch in
                FancyView(
                    title: state.title,
                    onTap: { dispatch(TapAction()) }
                )
                .store(testStore)
        })
     
     ```
     
     ## Migration to 2.0
     
     `ViewWithStore(...).store(...)`  should migrate to explicit `Store(...)` or `StateStore(...)`
     
     ```swift
     struct FancyViewContainer: View  {
        let store = Store<ViewState, Action>
           
        var body: some View {
              StoreView(store) { state, dispatch in
                  FancyView(
                      // ...
                  )
              }
         }
     }
     ```
     - Note:  Cheсkout the `ViewWithStore` migration guide.
     */
    @available(*, deprecated, message: "Cheсkout the `ViewWithStore` migration guide. Will be removed in 2.0")
    func store(_ store: PublishingStore<ViewState, Action>) -> some View {
        ViewWithPublishingStore(
            store: store,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    /**
      Connects ViewWithStore's `ContentView` to the scope store.

      Scope store is a proxy to the EnvStoreFactory's root store with a mapping of root store state to local state.

      - Parameter localState: root to local state mapping

      - Returns: `ViewWithStore` connected to the scope store

      All dispatched actions are forwarded to the root store.
      PublishingStore's state publisher is a mapping of the root store state publisher.

      **Important to note:**

      Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

      **Usage:**
     
    
     ```swift
     let factory = StoreFactory(
        initialState: AppState(),
        reducer: { state, action in state.reduce(action) }
     )

     let envFactory = EnvStoreFactory(factory)

     UIHostingController( 
        rootView: ViewWithStoreFactory(envFactory) {
            ViewWithStore { state, dispatch in
                FancyView(
                    title: state.title,
                    onTap: { dispatch(TapAction()) }
                )
            }
            .scopeStore { (appState: AppState) in state.substate }
     })
    
     ```
     
     ## Migration to 2.0
     
     `ViewWithStore(...).scopeStore { ... }` should migrate to `@StoreOf(\.appState).map { ... }`
     
     ```swift
     struct FancyViewContainer: View  {
        @State var scopeStore = StoreOf(\.appState).map { ... }`
           
        var body: some View {
              StoreView(store) { state, dispatch in
                  FancyView(
                      // ...
                  )
              }
         }
     }
     ```
     
     - Note: Cheсkout the `ViewWithStore` migration guide.
     */
    @available(*, deprecated, message: "Cheсkout the `ViewWithStore` migration guide. Will be removed in 2.0")
    func scopeStore<AppState>(to localState: @escaping (AppState) -> ViewState) -> some View {
        ViewWithScopeStore(
            localState: localState,
            content: self,
            presentationSettings: presentationSettings
        )
    }

   
    /**
     Connects ViewWithStore's `ContentView` to the child store.

      - Parameter initialState: initial state of the child store
      - Parameter stateMapping: mapping of root state and child state in the view state
      - Parameter qos: quality of service for the child store
      - Parameter reducer: reducer for the child state

      - Returns: `ViewWithStore` connected to the child store

      ChildStore is a composition of the root store and a newly created local store.
      ChildStore's state is a mapping of the local state and the root store's state.

      ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore's` lifecycle.
      Child state will be destroyed when ViewWithStore disappears from the hierarchy.

      **RootStore vs ChildStore Action Dispatch:**

      When an action is dispatched to RootStore:
      - action is delivered to the root store's reducer
      - action is not delivered to the child store's reducer
      - root state update triggers root store's subscribers
      - root state update triggers child stores' subscribers
      - Interceptor dispatches additional actions to RootStore

      When an action is dispatched to ChildStore:
      - action is delivered to the root store's reducer
      - action is delivered to the child store's reducer
      - root state update triggers root store's subscribers
      - root state update triggers child store's subscribers
      - local state update triggers child store's subscribers
      - Interceptor dispatches additional actions to ChildStore

      **Important to note:**

      Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

      **Usage:**
     
     ```swift
     let factory = StoreFactory( initialState: AppState(), reducer: { state, action in state.reduce(action) } )

     let envFactory = EnvStoreFactory(factory)

     UIHostingController( 
        rootView: ViewWithStoreFactory(envFactory) {
             ViewWithStore { state, dispatch in
                     FancyView(
                         title: state.title,
                         onTap: { dispatch(TapAction()) }
                     )
                 }
                 .childStore(
                      initialState: ChildState(),
                      stateMapping: { appState, childState in
                          StateComposition(appState, childState)
                      },
                      reducer: { state, action in state.reduce(action) }
                 )
              }
        }
    )
     
    ```
     
     ## Migration to 2.0
     
     `ViewWithStore(...).childStore(...)`  should migrate to `StoreOf(\.appState).with(ChildState()) { ... }`
     
     ```swift
     struct FancyViewContainer: View  {
        @State var store = StoreOf(\.appState).with(ChildState()) { ... }
           
        var body: some View {
              StoreView(store) { state, dispatch in
                  FancyView(
                      // ...
                  )
              }
         }
     }
     ```
     
    */
    @available(*, deprecated, message: "Cheсkout the `ViewWithStore` migration guide. Will be removed in 2.0")
    func childStore<AppState, ChildState>(initialState: ChildState,
                                          stateMapping: @escaping (AppState, ChildState) -> ViewState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View {

        ViewWithChildStore(
            initialState: initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    /**
     Connects ViewWithStore's `ContentView` to the child store.

      - Parameter initialState: initial state of the child store
      - Parameter qos: quality of service for the child store
      - Parameter reducer: reducer for the child state

      - Returns: `ViewWithStore` connected to the child store

      ChildStore is a composition of the root store and a newly created local store.
      ChildStore's state is a mapping of the local state and the root store's state.

      ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore`'s lifecycle.
      The child state will be destroyed when ViewWithStore disappears from the hierarchy.

      **RootStore vs ChildStore Action Dispatch:**

      When an action is dispatched to RootStore:
      - action is delivered to the root store's reducer
      - action is not delivered to the child store's reducer
      - root state update triggers root store's subscribers
      - root state update triggers child store's subscribers
      - Interceptor dispatches additional actions to RootStore

      When an action is dispatched to ChildStore:
      - action is delivered to the root store's reducer
      - action is delivered to the child store's reducer
      - root state update triggers root store's subscribers
      - root state update triggers child store's subscribers
      - local state update triggers child store's subscribers
      - Interceptor dispatches additional actions to ChildStore

      **Important to note:**

      Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.

      **Usage:**
     
     ```swift
     let factory = StoreFactory( initialState: AppState(), reducer: { state, action in state.reduce(action) } )

     let envFactory = EnvStoreFactory(factory)

     UIHostingController(
        rootView: ViewWithStoreFactory(envFactory) {
            ViewWithStore { state, dispatch in
                FancyView(
                    title: state.title,
                    onTap: { dispatch(TapAction()) }
            )
          }
          .childStore(
                initialState: ChildState(),
                reducer: { state, action in state.reduce(action) }
            )
        }
     )
     ```
     
     ## Migration to 2.0
     
     `ViewWithStore(...).childStore(...)`  should migrate to `StoreOf(\.appState).with(ChildState()) { ... }`
     
     ```swift
     struct FancyViewContainer: View  {
        @State var childStore = StoreOf(\.appState).with(ChildState()) { ... }
           
        var body: some View {
              StoreView(store) { state, dispatch in
                  FancyView(
                      // ...
                  )
              }
         }
     }
     ```
     
     - Note: Cheсkout the `ViewWithStore` migration guide.
     */
    @available(*, deprecated, message: "Cheсkout the `ViewWithStore` migration guide. Will be removed in 2.0")
    func childStore<AppState, ChildState>(initialState: ChildState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View

    where ViewState == (AppState, ChildState) {

        ViewWithChildStore(
            initialState: initialState,
            stateMapping: { ($0, $1) },
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }
}
