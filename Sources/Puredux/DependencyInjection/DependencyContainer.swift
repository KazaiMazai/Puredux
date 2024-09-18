//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch



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


