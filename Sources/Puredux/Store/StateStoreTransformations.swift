//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 31/08/2024.
//

import Foundation

//MARK: - Basic Transformations

extension StateStore {
    
    func map<T>(_ transformation: @escaping (State) -> T) -> StateStore<T, Action> {
        
        StateStore<T, Action>(
            storeObject: storeObject.createChildStore(
                initialState: Void(),
                stateMapping: { state, _ in transformation(state) },
                reducer: {_,_ in }
            )
        )
    }
    
    func flatMap<T>(_ transformation: @escaping (State) -> T?) -> StateStore<T?, Action> {
        
        StateStore<T?, Action>(
            storeObject: storeObject.createChildStore(
                initialState: Void(),
                stateMapping: { state, _ in transformation(state) },
                reducer: {_,_ in }
            )
        )
    }
}


//MARK: - KeyPath Transformations

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
