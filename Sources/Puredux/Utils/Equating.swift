//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.05.2021.
//

import Foundation

public struct Equating<T>: Sendable {
    public let predicate: @Sendable (T, T) -> Bool

    public init(predicate: @Sendable @escaping (T, T) -> Bool) {
        self.predicate = predicate
    }
}

public extension Equating {
    static var neverEqual: Equating {
        Equating { _, _ in false }
    }

    static var alwaysEqual: Equating {
        Equating { _, _ in true }
    }

    static func equal<Value: Equatable>(value: @Sendable @escaping (T) -> Value) -> Equating<T> {
        Equating {
            value($0) == value($1)
        }
    }

    static func keyPath<Value: Equatable>(_ keyPath: @Sendable @autoclosure @escaping() -> KeyPath<T, Value>) -> Equating<T> {
        .equal(value: { $0[keyPath: keyPath()]})
    }
}

public extension Equating {
    static func with<S: Sequence>(_ sequence: S) -> Equating<T> where S.Element == Equating<T> {
        sequence.reduce(.alwaysEqual, &&)
    }

    static func && (lhs: Equating<T>, rhs: Equating<T>) -> Equating<T> {
        Equating<T> {
            lhs.predicate($0, $1) && rhs.predicate($0, $1)
        }
    }
}

public extension Equating where T: Equatable {
    static var asEquatable: Equating {
        Equating {
            $0 == $1
        }
    }
}

public extension Equating where T: Identifiable {
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
