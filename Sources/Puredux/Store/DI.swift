//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation

/** Provides access to injected dependencies. */
@MainActor
public struct Injected {

    /** This is only used as an accessor to the computed properties within extensions of `InjectedValues`. */
    private static var current = Injected()

    /** A static subscript for updating the `currentValue` of `InjectionKey` instances. */
    static subscript<K>(key: K.Type) -> K.Value where K: InjectionKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }

    /** A static subscript accessor for updating and references dependencies directly. */
    public static subscript<T>(_ keyPath: WritableKeyPath<Injected, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

public protocol InjectionKey {
    /** The associated type representing the type of the dependency injection key's value. */
    associatedtype Value

    /** The default value for the dependency injection key. */
    static var currentValue: Self.Value { get set }
}
