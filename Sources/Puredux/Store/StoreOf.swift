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
