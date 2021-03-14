//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
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

    static func with<S: Sequence>(_ sequence: S) -> Equating<T> where S.Element == Equating<T> {
        sequence.reduce(.alwaysEqual, &&)
    }

    static func equal<Value: Equatable>(value: @escaping (T) -> Value) -> Equating<T> {
        Equating {
            value($0) == value($1)
        }
    }

    static func && (lhs: Equating<T>, rhs: Equating<T>) -> Equating<T> {
        Equating<T> {
            lhs.predicate($0, $1) && rhs.predicate($0, $1)
        }
    }
}

public extension Equating where T: Identifiable {
    static var equalIds: Equating {
        Equating {
            $0.id == $1.id
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
