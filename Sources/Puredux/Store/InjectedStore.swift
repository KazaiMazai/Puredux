//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/08/2024.
//

import Foundation

/** Provides access to injected dependencies. */
public struct InjectedStores {
    
    /** This is only used as an accessor to the computed properties within extensions of `InjectedValues`. */
    private static var current = InjectedStores()
    
    /** A static subscript for updating the `currentValue` of `InjectionKey` instances. */
    static subscript<K>(key: K.Type) -> K.Value where K : InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    /** A static subscript accessor for updating and references dependencies directly. */
    static subscript<T>(_ keyPath: WritableKeyPath<InjectedStores, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
public struct InjectedStore<T> {
    private let keyPath: WritableKeyPath<InjectedStores, T>
    
    public var wrappedValue: T {
        get { InjectedStores[keyPath] }
    }
   
    public init<State, Action>(_ keyPath: WritableKeyPath<InjectedStores, T>) where T == StateStore<State, Action> {
        self.keyPath = keyPath
    }
    
    public init<State, Action>(_ keyPath: WritableKeyPath<InjectedStores, T>) where T == StateStore<State, Action>? {
        self.keyPath = keyPath
    }
}
 
public extension InjectedStore {
    func with<U, State, Action>(
        _ state: U,
        reducer: @escaping Reducer<U, Action>) -> StateStore<(State, U), Action> where T == StateStore<State, Action> {
        
        wrappedValue.stateStore(
            state,
            reducer: reducer
        )
    }
    
    func with<U, State, Action>(
        _ state: U,
        reducer: @escaping Reducer<U, Action>) -> StateStore<(State, U), Action>? where T == StateStore<State, Action>? {
        
        wrappedValue?.stateStore(
            state,
            reducer: reducer
        )
    }
}

public protocol InjectionKey {
    /** The associated type representing the type of the dependency injection key's value. */
    associatedtype Value

    /** The default value for the dependency injection key. */
    static var currentValue: Self.Value { get set }
}
