//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch

/** Provides access to injected dependencies. */
public struct Injected: Sendable {
    private static let queue = DispatchQueue(label: "com.puredux.injected", attributes: .concurrent)

    /** This is only used as an accessor to the computed properties within extensions of `InjectedValues`. */
 
    /** A static subscript for updating the `currentValue` of `InjectionKey` instances. */
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: InjectionKey, Key.Value: Sendable {
        get {
            Self.queue.sync { key.currentValue }
        }
        set {
            Self.queue.async(flags: .barrier) { key.currentValue = newValue }
        }
    }

    /** A static subscript accessor for updating and references dependencies directly. */
    public static subscript<T>(_ keyPath: WritableKeyPath<Injected, T>) -> T {
        get {
            Injected()[keyPath: keyPath]
        }
        set {
            var instance = Injected()
            instance[keyPath: keyPath] = newValue
        }
    }
}

/**
 A protocol that defines a key used for dependency injection.

 Types conforming to `InjectionKey` provide a mechanism to inject dependencies into a `Injected` by associating a specific type of value (`Value`) with the key and providing default value
 */
public protocol InjectionKey {
    /** The associated type representing the type of the dependency injection key's value. */
    associatedtype Value

    /** The default value for the dependency injection key. */
    static var currentValue: Self.Value { get set }
}

