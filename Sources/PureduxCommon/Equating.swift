//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.05.2021.
//

import Foundation

public struct Equating<T> {
    public let predicate: (T, T) -> Bool

    public init(predicate: @escaping (T, T) -> Bool) {
        self.predicate = predicate
    }
}

public extension Equating {
    static var neverEqual: Equating {
        Equating { _,_ in false }
    }

    static var alwaysEqual: Equating {
        Equating { _,_ in true }
    }

    static func equal<Value: Equatable>(value: @escaping (T) -> Value) -> Equating<T> {
        Equating {
            value($0) == value($1)
        }
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
