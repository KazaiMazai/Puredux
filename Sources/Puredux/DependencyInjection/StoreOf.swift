//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/08/2024.
//

import SwiftUI
import Crocodil

/**
A property wrapper that implements a Dependency Injection (DI) pattern by providing access to an injected instance of `StateStore`.

The `StoreOf` property wrapper is used to access and manage an instance of `StateStore` (or an optional `StateStore`) that is injected into the `SharedStores` type. This pattern facilitates dependency management by allowing components to retrieve dependencies directly through property wrappers.
- Note: This property wrapper can be initialized with key paths to injected `StateStore` or optional `StateStore` types.
- Parameter T: The type of the `StateStore` or optional `StateStore` being accessed.
 
Example usage:
 
 ```swift
 
 // Use StoreEntry to inject the store instance
 
 extension Stores {
    @StoreEntry var rootState = StateStore<AppRootState, Action>(AppRootState()) { state, action in
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

public typealias StoreOf<T> = InjectableKeyPath<SharedStores, T>
 
public extension InjectableKeyPath  {
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

    func with<Local, Action>(
        _ initialState: Local,
        reducer: @escaping Reducer<Local, Action>) -> StateStore<(Root, Local), Action> where Value == StateStore<Root, Action> {

        wrappedValue.with(
            initialState,
            reducer: reducer
        )
    }

    func with<Local, Action>(
        _ initialState: Local,
        reducer: @escaping Reducer<Local, Action>) -> StateStore<(Root, Local), Action>? where Value == StateStore<Root, Action>? {

        wrappedValue?.with(
            initialState,
            reducer: reducer
        )
    }
}
