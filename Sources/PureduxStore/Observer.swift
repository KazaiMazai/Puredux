//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch

public class Observer<State>: Hashable {
    private let queue: DispatchQueue
    private let observeClosure: (State) -> Status

    func observe(_ state: State, complete: @escaping (Status) -> Void) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                complete(.dead)
                return
            }
            let status = self.observeClosure(state)
            complete(status)
        }
    }

    public init(queue: DispatchQueue, observe: @escaping (State) -> Status) {
        self.queue = queue
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
