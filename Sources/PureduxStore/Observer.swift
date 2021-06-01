//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public typealias StatusHandler = (Status) -> Void

public class Observer<State>: Hashable {

    private let observeClosure: (State, @escaping StatusHandler) -> Void

    public func observe(_ state: State, complete: @escaping StatusHandler) {
        observeClosure(state, complete)
    }

    public init(observe: @escaping (State, @escaping StatusHandler) -> Void) {
        self.observeClosure = observe
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

public enum Status {
    case active
    case dead
}
