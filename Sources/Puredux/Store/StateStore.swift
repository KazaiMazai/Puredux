//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

public typealias Reducer<State, Action> = (inout State, Action) -> Void

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
    let storeObject: AnyStoreObject<State, Action>
    
    /**
     Dispatches an action to the store, which will be processed by the reducer to update the state.
     
     - Parameter action: The action to be dispatched.
    */
    public func dispatch(_ action: Action) {
        storeObject.dispatch(action)
        executeAsyncAction(action)
    }
    
    /**
     Subscribes an observer to receive updates whenever the state changes.

     - Parameter observer: an Observer instance
     */
    public func subscribe(observer: Observer<State>) {
        storeObject.subscribe(observer: observer)
    }
    
    init(storeObject: any StoreObjectProtocol<State, Action>) {
        self.storeObject = AnyStoreObject(storeObject)
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
             MyInitialState(),
             qos: .userInteractive,
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

extension StateStore: StoreProtocol {
    public typealias State = State
    public typealias Action = Action
   
    public var instance: Store<State, Action> {
        Store<State, Action>(
            dispatcher: { [weak storeObject] in storeObject?.dispatch($0) },
            subscribe: { [weak storeObject] in storeObject?.subscribe(observer: $0) },
            storeObject: { [storeObject] in storeObject }
        )
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

  
extension StateStore {
    func executeAsyncAction(_ action: Action) {
        guard let action = action as? (any AsyncAction) else {
            return
        }
        
        action.execute { [weak storeObject] in
            storeObject?.dispatch($0)
        }
    }
}
