//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/04/2024.
//

import Foundation

final class Referenced<T> {
    var value: T

    init(_ value: T) {
        self.value = value
    }
}

enum ReferencedObject<Object: AnyObject> {
    case strong(Object)
    case weak(() -> Object?)
    
    init(weak object: Object) {
        self = .weak { [weak object] in object }
    }
    
    init(strong object: Object) {
        self = .strong(object)
    }
    
    func map<T: AnyObject>(_ transform: @escaping (Object) -> T) -> ReferencedObject<T> {
        switch self {
        case .strong(let object):
            return .strong(transform(object))
        case .weak(let objectClosure):
            let storeObject = objectClosure().map { transform($0) }
            return .weak { [weak storeObject] in storeObject }
        }
    }
    
    func weak() -> ReferencedObject<Object> {
        switch self {
        case .strong(let object):
            return .weak { [weak object] in object }
        case .weak:
            return self
        }
    }
    
    func strong() -> ReferencedObject<Object>? {
        switch self {
        case .strong:
            return self
        case .weak(let objectClosure):
            guard let object = objectClosure() else {
                return nil
            }
           
            return ReferencedObject(strong: object)
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
