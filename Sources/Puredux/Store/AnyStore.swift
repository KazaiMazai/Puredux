//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

public typealias Dispatch<Action> = (_ action: Action) -> Void

typealias Subscribe<State> = (_ observer: Observer<State>) -> Void

typealias ReferencedStore<State, Action> = ReferencedObject<AnyStoreObject<State, Action>>

public struct AnyStore<State, Action>: Store {
    let dispatchHandler: Dispatch<Action>
    let subscriptionHandler: Subscribe<State>
    let referencedStore: ReferencedStore<State, Action>
    
    public func eraseToAnyStore() -> AnyStore<State, Action> { self }
   
}

public extension AnyStore {
    func dispatch(_ action: Action) {
        dispatchHandler(action)
        executeAsyncAction(action)
    }

    func subscribe(observer: Observer<State>) {
        subscriptionHandler(observer)
    }
}

extension AnyStore {
    init(dispatcher: @escaping Dispatch<Action>,
         subscribe: @escaping Subscribe<State> ,
         referenced storeObject: ReferencedStore<State, Action>) {

        dispatchHandler = { dispatcher($0) }
        subscriptionHandler = { subscribe($0) }
        referencedStore = storeObject
    }
    
    func referencedStoreObject() -> AnyStoreObject<State, Action>? {
        referencedStore.object()
    }

    func weak() -> AnyStore<State, Action> {
        AnyStore<State, Action>(
            dispatcher: dispatchHandler,
            subscribe: subscriptionHandler,
            referenced: referencedStore.weak()
        )
    }
}

extension AnyStore {
    func executeAsyncAction(_ action: Action) {
        guard let action = action as? (any AsyncAction) else {
            return
        }

        action.execute(self.dispatchHandler)
    }
}

// MARK: - Basic Transformations

public extension AnyStore {
    /**
     Maps the state of the store to a new state of type `T`.

     This function takes a transformation closure that converts the current state
     of the store into a new state of a different type.
     The transformation is applied to the current state whenever it is accessed, resulting in a new `Store` of type `T`.

     - Parameter transform: A closure that takes the current state of type `State` and returns a new state of type `T`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
    */
    func map<T>(_ transform: @escaping (State) -> T) -> AnyStore<T, Action> {
        AnyStore<T, Action>(
            dispatcher: dispatchHandler,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            },
            referenced: referencedStore.map { $0.map(transform) }
        )
    }

    /**
     Maps the state of the store to a new optional state of type `T`, preserving optional results.

     This function applies a transformation closure that returns an optional value.
     The result is a new store where each state can either be `nil` or of the new type `T`,
     depending on the outcome of the transformation closure.

     - Parameter transform: A closure that takes the current state of type `State` and returns an optional new state of type `T?`.
     - Returns: A new `Store` with the transformed state of type `T?` (optional) and the same action type `Action`.
     - Note: This method differs from `compactMap(_:)` in that it preserves the `nil` values returned by the transformation closure, resulting in a store where the state type is optional.
    */
    func flatMap<T>(_ transform: @escaping (State) -> T?) -> AnyStore<T?, Action> {
        AnyStore<T?, Action>(
            dispatcher: dispatchHandler,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            },
            referenced: referencedStore.map { $0.map(transform) }
        )
    }
}

// MARK: - KeyPath Transformations

public extension AnyStore {
    /**
     Maps the state of the store to a new state of type `T` using a key path.

     This function transforms the current state of the store by applying a key path
     that extracts a specific property or substate.
     The resulting store has a state of the type corresponding to the extracted property.

     - Parameter keyPath: A key path that specifies the property of type `T` to extract from the current state of type `State`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
     - Note: This method allows you to create a store focused on a specific property of the original state using a key path, simplifying access to that property.
     */
    func map<T>(_ keyPath: KeyPath<State, T>) -> AnyStore<T, Action> {
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
    func flatMap<T>(_ keyPath: KeyPath<State, T?>) -> AnyStore<T?, Action> {
        flatMap { $0[keyPath: keyPath] }
    }
}

// MARK: - Tuples Transformations

// swiftlint:disable large_tuple identifier_name
public extension AnyStore {
    /**
     Flattens the state of the store from a nested tuple to a flat tuple.

     This function transforms the store's state from a nested tuple type `((T1, T2), T3)` to a flat tuple type `(T1, T2, T3)`.
     The transformation makes it easier to work with the individual components
     of the nested tuple state by bringing all elements to the same level in a flat tuple.

     - Returns: A new `Store` with the flattened state of type `(T1, T2, T3)` and the same action type `Action`.
     - Note: This method is only available when the store's state is a nested tuple of the form `((T1, T2), T3)`.
     The transformation extracts the inner tuple elements `T1` and `T2` and combines them with `T3` into a flat tuple `(T1, T2, T3)`.
     */
    func flatMap<T1, T2, T3>() ->
        AnyStore<(T1, T2, T3), Action>
        where
        State == ((T1, T2), T3) {

        map {
            let ((t1, t2), t3) = $0
            return (t1, t2, t3)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4>() ->
        AnyStore<(T1, T2, T3, T4), Action>
        where
        State == (((T1, T2), T3), T4) {

        map {
            let (((t1, t2), t3), t4) = $0
            return (t1, t2, t3, t4)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5>() ->
        AnyStore<(T1, T2, T3, T4, T5), Action>
        where
        State == ((((T1, T2), T3), T4), T5) {

        map {
            let ((((t1, t2), t3), t4), t5) = $0
            return (t1, t2, t3, t4, t5)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6>() ->
        AnyStore<(T1, T2, T3, T4, T5, T6), Action>
        where
        State == (((((T1, T2), T3), T4), T5), T6) {

        map {
            let (((((t1, t2), t3), t4), t5), t6) = $0
            return (t1, t2, t3, t4, t5, t6)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7>() ->
        AnyStore<(T1, T2, T3, T4, T5, T6, T7), Action>
        where
        State == ((((((T1, T2), T3), T4), T5), T6), T7) {

        map {
            let ((((((t1, t2), t3), t4), t5), t6), t7) = $0
            return (t1, t2, t3, t4, t5, t6, t7)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8>() ->
        AnyStore<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
        where
        State == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {

        map {
            let (((((((t1, t2), t3), t4), t5), t6), t7), t8) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9>() ->
        AnyStore<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
        where
        State == ((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9) {

        map {
            let ((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>() ->
        AnyStore<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), Action>
        where
        State == (((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9), T10) {

        map {
            let (((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9), t10) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)
        }
    }
}

// swiftlint:enable large_tuple identifier_name

// MARK: - Actions Transformations

//
// extension Store {
//    func map<A>(action transform: @escaping (A) -> Action) -> AnyStore<State, A> {
//        let store = instance
//        let weakStore = weakStore()
//        return AnyStore<State, A>(
//            dispatcher: { action in weakStore.dispatch(transform(action)) },
//            subscribe: weakStore.subscribeHandler,
//            storeObject: store.getStoreObject
//        )
//    }
// }
//
// extension StateStore {
//    func map<A>(action transform: @escaping (A) -> Action) -> AnyStore<State, A> {
//        instance.map(action: transform)
//    }
// }

//
//enum ReferencedStore<S, A> {
//    case strong(AnyStoreObject<S, A>)
//    case weak(() -> AnyStoreObject<S, A>?)
//    
//    init(weak storeObject: AnyStoreObject<S, A>) {
//        self = .weak { [weak storeObject] in storeObject }
//    }
//    
//    init(strong storeObject: AnyStoreObject<S, A>) {
//        self = .strong(storeObject)
//    }
//    
//    func map<T>(_ transform: @escaping (S) -> T) -> ReferencedStore<T, A> {
//        switch self {
//        case .strong(let storeObject):
//            return .strong(storeObject.map(transform))
//        case .weak(let storeObjectClosure):
//            let storeObject = storeObjectClosure()?.map(transform)
//            return .weak { [weak storeObject] in storeObject }
//        }
//    }
//    
//    func weakReferencedStore() -> ReferencedStore<S, A> {
//        switch self {
//        case .strong(let storeObject):
//            return .weak { [weak storeObject] in storeObject }
//        case .weak:
//            return self
//        }
//    }
//    
//    func storeObject() -> AnyStoreObject<S, A>? {
//        switch self {
//        case .strong(let storeObject):
//            return storeObject
//        case .weak(let storeObjectClosure):
//            return storeObjectClosure()
//        }
//    }
//}
