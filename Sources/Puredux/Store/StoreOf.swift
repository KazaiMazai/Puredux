//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/08/2024.
//

import SwiftUI

/**
A property wrapper that implements a Dependency Injection (DI) pattern by providing access to an injected instance of `StateStore`.

The `StoreOf` property wrapper is used to access and manage an instance of `StateStore` (or an optional `StateStore`) that is injected into the `Injected` type. This pattern facilitates dependency management by allowing components to retrieve dependencies directly through property wrappers.
- Note: This property wrapper can be initialized with key paths to injected `StateStore` or optional `StateStore` types.
- Parameter T: The type of the `StateStore` or optional `StateStore` being accessed.
 
Example usage:
 
 ```swift
 
 // Use InjectEntry to inject the instance
 
 extension Injected {
    @InjectEntry var rootState = StateStore<AppRootState, Action>(AppRootState()) { state, action in
        // Here is a reducer used to mutate the state
    }
 }
 

 // Use @StoreOf property wrapper to obtain injected instance:
 
 struct MyView: View {
     @State @StoreOf(\.rootState)
     var store: StateStore<AppRootState, Action>
     
     var body: some View {
        // ...
     }
 }
 ```
*/
@propertyWrapper
public struct StoreOf<T> {
    private let keyPath: WritableKeyPath<Injected, T>

    public var wrappedValue: T {
        get { Injected[keyPath] }
    }

    public init<State, Action>(_ keyPath: WritableKeyPath<Injected, T>) where T == StateStore<State, Action> {
        self.keyPath = keyPath
    }

    public init<State, Action>(_ keyPath: WritableKeyPath<Injected, T>) where T == StateStore<State, Action>? {
        self.keyPath = keyPath
    }

    public func store() -> T {
        wrappedValue
    }
}

public extension StoreOf {
    /**
     Initializes a new child StateStore with initial state
     - Parameter initialState: The initial state for the store
     - Parameter reducer: The function that is called on every dispatched Action and performs state mutations
     - Returns: `StateStore<(Root, Local), Action>`
   
     ChildStore is a composition of root store and newly created local store.

     When action is dispatched to RootStore:
     - action is delivered to root store's reducer
     - action is not delivered to child store's reducer
     - root & child stores subscribers receive updates
     - AsyncAction dispatches result actions to RootStore

     When action is dispatched to ChildStore:
     - action is delivered to root store's reducer
     - action is delivered to child store's reducer
     - root & child stores subscribers receive updates
     - AsyncAction dispatches result actions to ChildStore
     */
    func with<Root, Local, Action>(
        _ initialState: Local,
        reducer: @escaping Reducer<Local, Action>) -> StateStore<(Root, Local), Action> where T == StateStore<Root, Action> {

        wrappedValue.with(
            initialState,
            reducer: reducer
        )
    }

    func with<Root, Local, Action>(
        _ initialState: Local,
        reducer: @escaping Reducer<Local, Action>) -> StateStore<(Root, Local), Action>? where T == StateStore<Root, Action>? {

        wrappedValue?.with(
            initialState,
            reducer: reducer
        )
    }
}
