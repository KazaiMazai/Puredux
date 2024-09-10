//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09/09/2024.
//

import Foundation

enum Referenced<Object: AnyObject>: Sendable where Object: Sendable {
    case strong(Object)
    case weak(@Sendable () -> Object?)

    init(weak object: Object) {
        self = .weak { [weak object] in object }
    }

    init(strong object: Object) {
        self = .strong(object)
    }

    func map<T: AnyObject>(_ transform: @escaping (Object) -> T) -> Referenced<T> {
        switch self {
        case .strong(let object):
            return .strong(transform(object))
        case .weak(let objectClosure):
            let storeObject = objectClosure().map { transform($0) }
            return .weak { [weak storeObject] in storeObject }
        }
    }

    func weak() -> Referenced<Object> {
        switch self {
        case .strong(let object):
            return .weak { [weak object] in object }
        case .weak:
            return self
        }
    }

    func strong() -> Referenced<Object>? {
        switch self {
        case .strong:
            return self
        case .weak(let objectClosure):
            guard let object = objectClosure() else {
                return nil
            }

            return Referenced(strong: object)
        }
    }

    func object() -> Object? {
        switch self {
        case .strong(let object):
            return object
        case .weak(let objectClosure):
            return objectClosure()
        }
    }
}
