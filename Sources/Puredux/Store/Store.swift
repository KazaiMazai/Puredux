//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29/08/2024.
//

import Foundation

/**
 A protocol that defines the core requirements for a store in a state management system.

 `Store` is a generic protocol that outlines the essential operations for a store that manages application state and handles actions.

 - Associated Types:
    - `State`: The type representing the state managed by the store. This type encapsulates all the information about the current state of the application.
    - `Action`: The type representing the actions that can be dispatched to the store to trigger state changes. Actions define the possible changes that can occur in the state.

 - Requirements:
    - `eraseToAnyStore()`: A function that returns an `AnyStore` instance. This method provides a type-erased store, which hides the concrete implementation details while exposing the store's functionality.
    - `dispatch(_:)`: A method for dispatching an action to the store. This triggers a state change based on the logic defined for the particular action.
    - `subscribe(observer:)`: A method for subscribing an observer to state changes. This allows external entities to react to state updates.

 - Usage:
    The `Store` protocol serves as an abstraction layer for different store implementations in a state management system. Types conforming to this protocol must specify the `State` and `Action` associated types and provide concrete implementations of the `eraseToAnyStore()`, `dispatch(_:)`, and `subscribe(observer:)` methods.
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

