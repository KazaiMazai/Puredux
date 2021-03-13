//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import Foundation

public struct Equating<T> {
    init(equals: @escaping (T, T) -> Bool) {
        self.equals = equals
    }

    let equals: (T, T) -> Bool
}

public extension Equating {
    static var neverEqual: Equating {
        Equating { _,_ in false }
    }

    static var alwaysEqual: Equating {
        Equating { _,_ in true }
    }

    static func with<T>(_ sequence: [Equating<T>]) -> Equating<T> {
        sequence.reduce(.alwaysEqual, +)
    }
}

public extension Equating where T: Identifiable {
    static var equalId: Equating {
        Equating {
            $0.id == $1.id
        }
    }
}

public extension Equating {
    static func equal<Value: Equatable>(value: @escaping (T) -> Value) -> Equating<T> {
        Equating {
            value($0) == value($1)
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

public extension Equating {
    static func + (lhs: Equating<T>, rhs: Equating<T>) -> Equating<T> {
        Equating<T> {
            lhs.equals($0, $1) && rhs.equals($0, $1)
        }
    }
}

