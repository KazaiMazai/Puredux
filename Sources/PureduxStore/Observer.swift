//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public class Observer<State>: Hashable {
    public typealias CompleteHandler = (Status) -> Void
    private let observeClosure: (State, CompleteHandler) -> Void

    func observe(_ state: State, complete: @escaping CompleteHandler) {
        observeClosure(state, complete)
    }

    public init(observe: @escaping (State, CompleteHandler) -> Void) {
        self.observeClosure = observe
    }
}

extension Observer {
    public enum Status {
        case active
        case dead
    }
}

extension Observer {
    public static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }

}
