//
//  File.swift
//
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

public extension Store {
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
            dispatcher: dispatchHandler,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
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
            dispatcher: dispatchHandler,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
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
            dispatcher: dispatchHandler,
            subscribe: { localStateObserver in
                subscribe(observer: Observer<State>(id: localStateObserver.id) { state, complete in
                    let localState = transform(state)
                    localStateObserver.send(localState, complete: complete)
                })
            }
        )
    }
}

public extension Store {
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
    func map<T>(_ keyPath: KeyPath<State, T>) -> Store<T, Action> {
        strongStore().map(keyPath)
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
        strongStore().compactMap(keyPath)
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
        strongStore().flatMap(keyPath)
    }
}

public extension StateStore {
    /**
     Maps the state of the store to a new state of type `T`.

     This function takes a transformation closure that converts the current state 
     of the store into a new state of a different type.
     The transformation is applied to the current state whenever it is accessed, resulting in a new `Store` of type `T`.

     - Parameter transform: A closure that takes the current state of type `State` and returns a new state of type `T`.
     - Returns: A new `Store` with the transformed state of type `T` and the same action type `Action`.
     */
    func map<T>(_ transform: @escaping (State) -> T) -> Store<T, Action> {
        strongStore().map(transform)
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
        strongStore().compactMap(transform)
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
        strongStore().flatMap(transform)
    }
}
