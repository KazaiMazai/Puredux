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
public struct StateStore<State, Action>: Sendable where State: Sendable,
                                                        Action: Sendable {
    
    let storeObject: AnyStoreObject<State, Action>

    /**
     Dispatches an action to the store, which will be processed by the reducer to update the state.
     
     - Parameter action: The action to be dispatched.
    */
    @Sendable public func dispatch(_ action: Action) {
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
            qos: qos,
            reducer: reducer
        ))
    }
}

extension StateStore: Store {
    public typealias State = State
    public typealias Action = Action
    
    public func eraseToAnyStore() -> AnyStore<State, Action> {
        AnyStore<State, Action>(
            dispatcher: { [weak storeObject] in storeObject?.dispatch($0) },
            subscribe: { [weak storeObject] in storeObject?.subscribe(observer: $0) },
            referenced: ReferencedStore(strong: storeObject)
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
                actionMapping: { $0 },
                reducer: reducer
            )
        )
    }
}

//MARK: - AsyncActionsExecutor

extension StateStore: AsyncActionsExecutor {
    func executeAsyncAction(_ action: Action) {
        guard let action = action as? (any AsyncAction) else {
            return
        }

        action.execute { [weak storeObject] in
            storeObject?.dispatch($0)
        }
    }
}

// MARK: - Basic Transformations

extension StateStore {
    /**
     Maps the state of the store to a new state of type `T`.

     This function takes a transformation closure that converts the current state
     of the store into a new state of a different type.
     The transformation is applied to the current state whenever it is accessed, resulting in a new `StateStore` of type `T`.

     - Parameter transform: A closure that takes the current state of type `State` and returns a new state of type `T`.
     - Returns: A new `StateStore` with the transformed state of type `T` and the same action type `Action`.
    */
    func map<T>(_ transformation: @Sendable @escaping (State) -> T) -> StateStore<T, Action> {
        StateStore<T, Action>(
            storeObject: storeObject.createChildStore(
                initialState: Void(),
                stateMapping: { state, _ in transformation(state) }, 
                actionMapping: { $0 },
                reducer: {_, _ in }
            )
        )
    }
    
    /**
     Maps the a new store with actions of type `A`

     This function takes a transformation closure that  actions from local store to parent
     
     The transformation is applied to the action whenever it is dispatched.

     - Parameter transform: A closure that takes the local action of type `A` and returns a parent actions of type `Action`.
     - Returns: A new `StateStore` with local to global actions mapping.
    */
    func map<A>(actions transformation: @Sendable @escaping (A) -> Action) -> StateStore<State, A> {
        StateStore<State, A>(
            storeObject: storeObject.createChildStore(
                initialState: Void(),
                stateMapping: { state, _ in state },
                actionMapping: transformation,
                reducer: {_, _ in }
            )
        )
    }

    /**
     Maps the state of the store to a new optional state of type `T`, preserving optional results.

     This function applies a transformation closure that returns an optional value.
     The result is a new store where each state can either be `nil` or of the new type `T`,
     depending on the outcome of the transformation closure.

     - Parameter transform: A closure that takes the current state of type `State` and returns an optional new state of type `T?`.
     - Returns: A new `StateStore` with the transformed state of type `T?` (optional) and the same action type `Action`.
    */
    func flatMap<T>(_ transformation: @Sendable @escaping (State) -> T?) -> StateStore<T?, Action> {
        StateStore<T?, Action>(
            storeObject: storeObject.createChildStore(
                initialState: Void(),
                stateMapping: { state, _ in transformation(state) },
                actionMapping: { $0 },
                reducer: {_, _ in }
            )
        )
    }
}

// MARK: - KeyPath Transformations

public extension StateStore {
    /**
     Maps the state of the store to a new state of type `T` using a key path.

     This function transforms the current state of the store by applying a key path
     that extracts a specific property or substate.
     The resulting store has a state of the type corresponding to the extracted property.

     - Parameter keyPath: A key path that specifies the property of type `T` to extract from the current state of type `State`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
     - Note: This method allows you to create a store focused on a specific property of the original state using a key path, simplifying access to that property.
     */
    func map<T>(_ keyPath: KeyPath<State, T>) -> StateStore<T, Action> {
        map { $0[keyPath: keyPath] }
    }

    /**
     Maps the state of the store to a new optional state of type `T` using a key path, preserving optional results.

     This function applies a key path that extracts an optional property or substate from the current state.
     The result is a new store where each state can either be `nil` or of the new type `T`,
     depending on the value of the extracted property.

     - Parameter keyPath: A key path that specifies the optional property of type `T?` to extract from the current state of type `State`.
     - Returns: A new `Store` with the transformed state of type `T?` (optional) and the same action type `Action`.
     - Note: This method differs from `compactMap(_:)` by preserving the `nil` values extracted by the key path, resulting in a store where the state type is optional.
    */
    func flatMap<T>(_ keyPath: KeyPath<State, T?>) -> StateStore<T?, Action> {
        flatMap { $0[keyPath: keyPath] }
    }
}
