//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.05.2021.
//

import Foundation

/**
 A generic structure `Equating` that allows the comparison of two values of type `T` based on a custom predicate.

 */
public struct Equating<T>: Sendable {
    public let predicate: @Sendable (T, T) -> Bool

    /**
    Initializes an `Equating` instance with a custom predicate.

    - Parameter predicate: A custom comparison function that takes two values of type `T` and returns a Boolean value indicating whether they are equal.
    */
    public init(predicate: @Sendable @escaping (T, T) -> Bool) {
        self.predicate = predicate
    }
}

public extension Equating {
    /**
     A static property that provides an `Equating` instance where no two values are never considered equal.

     - Returns: An `Equating` instance that always returns `false` when comparing two values.
     */
    static var neverEqual: Equating {
        Equating { _, _ in false }
    }

    /**
     A static property that provides an `Equating` instance where all values are always considered equal.

     - Returns: An `Equating` instance that always returns `true` when comparing two values.
     */
    static var alwaysEqual: Equating {
        Equating { _, _ in true }
    }

    /**
     A static method that creates an `Equating` instance based on an `Equatable` value derived from a function applied to values of type `T`.

     - Parameter value: A function that maps a value of type `T` to a value of type `Value` that conforms to `Equatable`.
     - Returns: An `Equating` instance that compares the results of the `value` function applied to two values of type `T`.
     */
    static func equal<Value: Equatable>(value: @Sendable @escaping (T) -> Value) -> Equating<T> {
        Equating {
            value($0) == value($1)
        }
    }

    /**
     A static method that creates an `Equating` instance based on a `KeyPath` to an `Equatable` value within a value of type `T`.

     - Parameter keyPath: A `KeyPath` from `T` to a `Value` that conforms to `Equatable`.
     - Returns: An `Equating` instance that compares the values at the given `KeyPath` for two values of type `T`.
     */
    static func keyPath<Value: Equatable>(_ keyPath: KeyPath<T, Value>) -> Equating<T> {
        .equal(value: { $0[keyPath: keyPath]})
    }
}

public extension Equating {
    /**
    A static method that combines multiple `Equating` instances from a sequence into a single `Equating` instance.

    This method applies a logical AND (`&&`) between all `Equating` instances in the sequence, ensuring that all predicates must return `true` for the combined `Equating` instance to consider two values equal.

    - Parameter sequence: A sequence of `Equating<T>` instances to be combined.
    - Returns: A single `Equating<T>` instance that performs the AND operation on the predicates of the sequence.
    */
    static func with<S: Sequence>(_ sequence: S) -> Equating<T> where S.Element == Equating<T> {
        sequence.reduce(.alwaysEqual, &&)
    }

    /**
     A static method that creates a new `Equating` instance by combining two existing `Equating` instances using a logical AND (`&&`).

     The resulting `Equating` instance will only return `true` if both the `lhs` and `rhs` predicates return `true` for the given values.

     - Parameters:
        - lhs: The left-hand `Equating` instance.
        - rhs: The right-hand `Equating` instance.
     - Returns: A new `Equating<T>` instance that combines the predicates of `lhs` and `rhs` using a logical AND.
     */
    static func && (lhs: Equating<T>, rhs: Equating<T>) -> Equating<T> {
        Equating<T> {
            lhs.predicate($0, $1) && rhs.predicate($0, $1)
        }
    }
}

public extension Equating where T: Equatable {
    /**
     A static property that creates a new `Equating` instance for types that conform to `Equatable`.

     This `Equating` instance uses the default equality operator  to compare two values of type `T`.

     - Returns: An `Equating<T>` instance that compares two values using `Equatable`'s `==` operator.
     */
    static var asEquatable: Equating {
        Equating {
            $0 == $1
        }
    }
}

public extension Equating where T: Identifiable {
    /**
     A static property that creates an `Equating` instance for types that conform to `Identifiable`.

     This `Equating` instance compares the `id` property of two values to determine if they are considered equal.

     - Returns: An `Equating<T>` instance that compares two values based on their `id` property.
     */
    static var asIdentifiable: Equating {
        Equating {
            $0.id == $1.id
        }
    }
}

extension Equating {
    func isEqual(_ lhs: T?, to rhs: T?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.some(let lhsValue), .some(let rhsValue)):
            return predicate(lhsValue, rhsValue)
        default:
            return false
        }
    }
}
