//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

@available(*, deprecated, renamed: "StateStore", message: "Will be removed in the next major release. StateStore is a former StoreObject replacement")
public typealias StoreObject = StateStore
/**
 A generic state store for managing state and handling actions within a store.

 This struct encapsulates state management and action dispatching. 
 It allows interaction with the store through dispatching actions and subscribing to state changes.
 
 
 ```text
 
                +-----------------------------------------+
                |                  Store                  |
                |                                         |
                |  +-----------+   +-------------------+  |
                |  |  Reducer  |<--|   Current State   |  |
      New State |  +-----------+   +-------------------+  |  Actions
    <-----------+      |                            A     |<----------+
    |           |      |                            |     |           A
    |           |      V                            |     |           |
    |           |  +-------------------+            |     |           |
    |           |  |     New State     |------------+     |           |
    |           |  +-------------------+                  |           |
    |           |                                         |           |
    |           +-----------------------------------------+           |
    |                                                                 |
    |                                                                 |
    |                                                                 |
    |           +----------------+                +---+----+          |
    V Observer  |                |   Async Work   |        |          |
    +---------->|  Side Effects  |--------------->| Action |--------->|
    |           |                |     Result     |        |          |
    |           +----------------+                +----+---+          |
    |                                                                 |
    |           +----------------+                   +---+----+       |
    V Observer  |                |       User        |        |       |
    +---------->|       UI       |------------------>| Action |------>+
                |                |   Interactions    |        |
                +----------------+                   +----+---+
        
 ```

 - Parameters:
    - State: The type of the state managed by the store.
    - Action: The type of actions that can be dispatched to the store.
 */
public struct StateStore<State, Action> {
    private let storeObject: AnyStoreObject<State, Action>
    private let erasedStore: Store<State, Action>

    /**
     Returns the `Store` instance associated with this `StateStore`.

     - Returns: The `Store` instance.
    */
    public func store() -> Store<State, Action> {
        weakStore()
    }
    
    /**
     Dispatches an action to the store, which will be processed by the reducer to update the state.
     
     - Parameter action: The action to be dispatched.
    */
    public func dispatch(_ action: Action) {
        erasedStore.dispatch(action)
    }
    
    /**
     Subscribes an observer to receive updates whenever the state changes.

     - Parameter observer: an Observer instance
     */
    public func subscribe(observer: Observer<State>) {
        erasedStore.subscribe(observer: observer)
    }
    
    init(storeObject: any StoreObjectProtocol<State, Action>) {
        let storeObjectBox = AnyStoreObject(storeObject)
        self.storeObject = storeObjectBox
        self.erasedStore = Store<State, Action>(
            dispatcher: { [weak storeObjectBox] in storeObjectBox?.dispatch($0) },
            subscribe: { [weak storeObjectBox] in storeObjectBox?.subscribe(observer: $0) },
            storeObject: { [storeObjectBox] in storeObjectBox }
        )
    }
}

public extension StateStore {
    /**
         Initializes a new root `StateStore` with the provided initial state, QoS, and reducer.
         
         - Parameter initialState: The initial state for the store.
         - Parameter qos: Defines the `DispatchQueue` Quality of Service (QoS) for the reducer.
           The default value is `.userInteractive`, which provides high-priority processing.
         - Parameter reducer: A function that is called on every dispatched action and performs state mutations.
         - Returns: A `StateStore<State, Action>` instance configured with the provided parameters.
         
         Example usage:
         ```swift
         let store = StateStore(
             initialState: MyInitialState(),
             qos: .background,
             reducer: myReducer
         )
         ```
         
         The `qos` parameter determines the priority of the queue on which the reducer operates,
        which can affect the responsiveness and performance of the state updates. 
     
        Available QoS levels include: `.userInteractive`, `.userInitiated`, `.default`, `.utility`, and `.background`.
    */
    init(_ initialState: State,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<State, Action>) {
        
        self.init(storeObject: RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: { _, _ in },
            qos: qos,
            reducer: reducer
        ))
    }
}

public extension StateStore {
    /**
     Initializes a new child `StateStore` with a specified initial state and a reducer function.
     
     - Parameter initialState: The initial state for the new child store.
     - Parameter reducer: A function that handles dispatched actions and updates the state of the child store.
     - Returns: A `StateStore` instance that integrates with the root store and manages the new local state.
     
     The child store's state is a composition of the root store's state and the new local state.
     This method helps build the app's store hierarchy:
     
     - Actions are propagated upstream from the child store to the root store.
     - State updates are propagated downstream from the root store to the child stores and eventually to store observers: UI and Side Effects.
     
     Example usage:
 
     ```swift
     let rootStore = StateStore<RootState, RootAction>(...)
     let childStore = rootStore.with(
         initialState: ChildState(...),
         reducer: childReducer
     )
     ```
     
     Stores can be used to build up the tree hierarchy:
 
     ```text
                   +------------+    +--------------+
                   | Root Store | -- | Side Effects |
                   +------------+    +--------------+
                         |
                         |
            +------------+-------------------------+
            |                                      |
            |                                      |
            |                                      |
            |                                      |
      +---------------+                     +---------------+    +--------------+
      | Child Store 1 |                     | Child Store 2 | -- | Side Effects |
      +---------------+                     +---------------+    +--------------+
         |       |                                 |
      +----+  +--------------+                     |
      | UI |  | Side Effects |        +------------+------------+
      +----+  +--------------+        |                         |
                                      |                         |
                                      |                         |
                                      |                         |
                               +---------------+         +---------------+
                               | Child Store 3 |         | Child Store 4 |
                               +---------------+         +---------------+
                                  |         |               |
                               +----+  +--------------+  +----+
                               | UI |  | Side Effects |  | UI |
                               +----+  +--------------+  +----+
    ```
    */
    func with<T>(_ initialState: T,
                 reducer: @escaping Reducer<T, Action>) -> StateStore<(State, T), Action> {
        
        StateStore<(State, T), Action>(
            storeObject: storeObject.createChildStore(
                initialState: initialState,
                stateMapping: { ($0, $1) },
                reducer: reducer
            )
        )
    }
}

extension StateStore: StoreProtocol {
    public typealias State = State
    public typealias Action = Action
   
    public func getStore() -> Store<State, Action> {
        erasedStore
    }
}

public extension StateStore {
    @available(*, deprecated, renamed: "init(_:qos:reducer:)", message: "Actions Interceptor will be removed in 2.0, use AsyncAction instead.")
    init(_ initialState: State,
         interceptor: @escaping (Action, @escaping Dispatch<Action>) -> Void,
         qos: DispatchQoS = .userInteractive,
         reducer: @escaping Reducer<State, Action>) {
        
        self.init(storeObject: RootStoreNode.initRootStore(
            initialState: initialState,
            interceptor: interceptor,
            qos: qos,
            reducer: reducer
        ))
    }
}

public extension StateStore {
    @available(*, deprecated, renamed: "stateStore(_:stateMapping:qos:reducer:)", message: "Will be removed in 2.0")
    func childStore<LocalState, ResultState>(
        initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        qos: DispatchQoS = .userInteractive,
        reducer: @escaping Reducer<LocalState, Action>) -> StateStore<ResultState, Action> {
           
            stateStore(
                initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
    }

    @available(*, deprecated, message: "Use with(_:reducer) and store transformations instead. Will be removed in 2.0. ")
    func stateStore<LocalState, ResultState>(
        _ initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        qos: DispatchQoS,
        reducer: @escaping Reducer<LocalState, Action>
    
    ) -> StateStore<ResultState, Action> {
            
            StateStore<ResultState, Action>(
                storeObject: storeObject.createChildStore(
                    initialState: initialState,
                    stateMapping: stateMapping,
                    qos: qos,
                    reducer: reducer
                )
            )
        }
    
    @available(*, deprecated, message: "Use with(_:reducer) and store transformations instead. Will be removed in 2.0.")
    func stateStore<LocalState, ResultState>(
        _ initialState: LocalState,
        stateMapping: @escaping (State, LocalState) -> ResultState,
        reducer: @escaping Reducer<LocalState, Action>
    
    ) -> StateStore<ResultState, Action> {
            
            StateStore<ResultState, Action>(
                storeObject: storeObject.createChildStore(
                    initialState: initialState,
                    stateMapping: stateMapping,
                    reducer: reducer
                )
            )
        }
}

extension StateStore {
    @available(*, deprecated, message: "Qos parameter will have no effect. Root store's QoS is used. Use with(_:reducer) and store transformations instead. Will be removed in 2.0.")
    public func stateStore<T>(
        _ state: T,
        qos: DispatchQoS = .userInitiated,
        reducer: @escaping Reducer<T, Action>
        
    ) -> StateStore<(State, T), Action> {
        
        with(state, reducer: reducer)
    }
}


extension StateStore {
    func weakStore() -> Store<State, Action> {
        erasedStore.weakStore()
    }
    
    func strongStore() -> Store<State, Action> {
        erasedStore
    }
}
