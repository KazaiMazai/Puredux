//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch


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

extension DispatchQueue {
    static let di = DispatchQueue(label: "com.puredux.dependencies", attributes: .concurrent)
}

public protocol DependencyContainer: Sendable {
    init()
}

/** Provides access to injected dependencies. */
extension DependencyContainer {
 
    /** A static subscript for updating the `currentValue` of `DependencyKey` instances. */
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey, Key.Value: Sendable {
        get {
            DispatchQueue.di.sync { key.currentValue }
        }
        set {
            DispatchQueue.di.async(flags: .barrier) { key.currentValue = newValue }
        }
    }

    /** A static subscript accessor for updating and references dependencies directly. */
    public static subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
        get {
            Self()[keyPath: keyPath]
        }
        set {
            var instance = Self()
            instance[keyPath: keyPath] = newValue
        }
    }
}


