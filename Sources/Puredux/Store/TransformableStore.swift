//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

/**
 A protocol that defines a type capable of providing a `Store` object.
 
 Types conforming to `TransformableStore` must specify the `State` and `Action`
 associated types and provide a `transformable` computed property that returns a `Store` object.
 */
public protocol TransformableStore {
    /** The type representing the state managed by the store. */
    associatedtype State
    
    /** The type representing the actions that can be performed on the store.  */
    associatedtype Action
    
    /**
     A computed property that returns a `Store` object that matches the specified `State` and `Action` types.
     This allows transformation or access to the underlying store instance.
     */
    var transformable: Store<State, Action> { get }
}

/**
 Extends the `Store` class to conform to the `TransformableStore` protocol.
 
 This extension allows any `Store` instance to be used where a `TransformableStore` is required.
 */
extension Store: TransformableStore {
    /**  The `State` typealias is defined as itself, since `Store` already has a `State` type. */
    public typealias State = State
    
    /** The `Action` typealias is defined as itself, since `Store` already has an `Action` type.  */
    public typealias Action = Action
   
    /**
     Provides a transformable `Store` by returning the current instance (`self`).
        This computed property makes the `Store` itself transformable.
    */
    public var transformable: Store<State, Action> { self }
}

/**
 Extends the `StateStore` class to conform to the `TransformableStore` protocol.
 
 This extension allows any `StateStore` instance to be used where a `TransformableStore` is required.
 */
extension StateStore: TransformableStore {
    /** The `State` typealias is defined as itself, since `StateStore` already has a `State` type.  */
    public typealias State = State
    
    /** The `Action` typealias is defined as itself, since `StateStore` already has an `Action` type. */
    public typealias Action = Action
    
    /**
     Provides a transformable `Store` by calling the `strongStore` method, which returns a `Store` instance.
     
     This computed property allows transformation or access to the underlying `Store` within `StateStore`.
     */
    public var transformable: Store<State, Action> { strongStore() }
}

//MARK: - Basic Transformations

public extension TransformableStore {
    /**
     Maps the state of the store to a new state of type `T`.

     This function takes a transformation closure that converts the current state 
     of the store into a new state of a different type.
     The transformation is applied to the current state whenever it is accessed, resulting in a new `Store` of type `T`.

     - Parameter transform: A closure that takes the current state of type `State` and returns a new state of type `T`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
    */
    func map<T>(_ transform: @escaping (State) -> T) -> Store<T, Action> {
        Store<T, Action>(
            dispatcher: transformable.dispatchHandler,
            subscribe: { localStateObserver in
                transformable.subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }
    
    /**
     Maps the state of the store to a new state of type `T`, filtering out `nil` results.

     This function is similar to `map(_:)` but returns a new store that only includes non-`nil` transformed states.
     If the transformation closure returns `nil`, those states are excluded from the resulting store.

     - Parameter transform: A closure that takes the current state of type `State` and returns an optional new state of type `T?`.
     - Returns: A new `Store` with the non-optional transformed state of type `T` and the same action type `Action`.
     - Note: This method filters out states where the transformation closure returns `nil`, resulting in a store with a reduced set of states.
    */
    func compactMap<T>(_ transform: @escaping (State) -> T?) -> Store<T, Action> {
        Store<T, Action>(
            dispatcher: transformable.dispatchHandler,
            subscribe: { localStateObserver in
                transformable.subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    guard let localState = transform(state) else {
                        complete(.active)
                        return
                    }

                    localStateObserver.send(localState, complete: complete)
                })
            }
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
    func flatMap<T>(_ transform: @escaping (State) -> T?) -> Store<T?, Action> {
        Store<T?, Action>(
            dispatcher: transformable.dispatchHandler,
            subscribe: { localStateObserver in
                transformable.subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }
}

//MARK: - KeyPath Transformations

public extension TransformableStore {
    /**
     Maps the state of the store to a new state of type `T` using a key path.

     This function transforms the current state of the store by applying a key path 
     that extracts a specific property or substate.
     The resulting store has a state of the type corresponding to the extracted property.

     - Parameter keyPath: A key path that specifies the property of type `T` to extract from the current state of type `State`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
     - Note: This method allows you to create a store focused on a specific property of the original state using a key path, simplifying access to that property.
     */
    func map<T>(_ keyPath: KeyPath<State, T>) -> Store<T, Action> {
        map { $0[keyPath: keyPath] }
    }

    /**
     Maps the state of the store to a new state of type `T` using a key path, filtering out `nil` results.

     This function transforms the current state of the store 
     by applying a key path that extracts an optional property or substate.
     Only non-`nil` extracted properties are included in the resulting store.

     - Parameter keyPath: A key path that specifies the optional property of type `T?` to extract from the current state of type `State`.
     - Returns: A new `Store` with the non-optional transformed state of type `T` and the same action type `Action`.
     - Note: This method filters out states where the key path resolves to `nil`, resulting in a store with a reduced set of non-optional states.
    */
    func compactMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T, Action> {
        compactMap { $0[keyPath: keyPath] }
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
    func flatMap<T>(_ keyPath: KeyPath<State, T?>) -> Store<T?, Action> {
        flatMap { $0[keyPath: keyPath] }
    }
}


//MARK: - Tuples Transformations

// swiftlint:disable large_tuple identifier_name
public extension TransformableStore {
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
        Store<(T1, T2, T3), Action>
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
        Store<(T1, T2, T3, T4), Action>
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
        Store<(T1, T2, T3, T4, T5), Action>
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
        Store<(T1, T2, T3, T4, T5, T6), Action>
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
        Store<(T1, T2, T3, T4, T5, T6, T7), Action>
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
        Store<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
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
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
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
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), Action>
        where
        State == (((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9), T10) {

        map {
            let (((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9), t10) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)
        }
    }
}

// swiftlint:enable large_tuple identifier_name
