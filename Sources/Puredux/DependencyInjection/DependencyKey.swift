//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/09/2024.
//

import Foundation

/**
 A protocol that defines a key used for dependency injection.

 Types conforming to `DependencyKey` provide a mechanism to inject dependencies  by associating a specific type of value (`Value`) .
 */
public protocol DependencyKey {
    /** The associated type representing the type of the dependency injection key's value. */
    associatedtype Value

    /** The default value for the dependency injection key. */
    static var currentValue: Self.Value { get set }
}

/**
 A protocol that defines a key used for store injection.

 Types conforming to `StoreInjectionKey` provide a mechanism to inject .
 */
public protocol StoreInjectionKey: DependencyKey where Value: Store {
    /** The associated type representing the type of the dependency injection key's value. */
    
}
