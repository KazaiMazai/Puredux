//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public class Observer<State>: Hashable {
    private let observeClosure: (State) -> Status

    func observe(_ state: State) -> Status {
        observeClosure(state)
    }

    public init(observe: @escaping (State) -> Status) {
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
