//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/08/2024.
//

import Foundation

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
