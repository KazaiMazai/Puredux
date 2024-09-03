//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29/08/2024.
//

import Foundation

/**
 A protocol that defines the basic requirements for a store in a state management system.

 `Store` is a generic protocol that defines the fundamental operations required for a store that manages application state and actions.

 - Associated Types:
    - `State`: The type representing the state managed by the store. This type encapsulates all the information about the current state of the application.
    - `Action`: The type representing the actions that can be dispatched to the store to trigger state changes. Actions define the possible changes that can occur in the state.

 - Requirements:
    - `getStore()`: A function that returns a `Store` instance. This function provides access to the store that manages state and handles actions.

 - Usage:
    The `Store` is used as an abstraction layer for different store implementations. Types conforming to this protocol must specify the `State` and `Action` associated types and provide a concrete implementation of the `getStore()` method.
*/
public protocol Store<State, Action> {
    /** The type representing the state managed by the store. */
    associatedtype State

    /** The type representing the actions that can be performed on the store.  */
    associatedtype Action

    /**
     A func that returns a `Store` object that matches the specified `State` and `Action` types.
     */
    func eraseToAnyStore() -> AnyStore<State, Action>

    func dispatch(_ action: Action)

    func subscribe(observer: Observer<State>)
}

extension Store {
    func weakStore() -> AnyStore<State, Action> {
        eraseToAnyStore().weakStore()
    }
}
