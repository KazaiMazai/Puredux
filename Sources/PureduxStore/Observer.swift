//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch
import Foundation

public typealias StatusHandler = (ObserverStatus) -> Void

public enum ObserverStatus {
    case active
    case dead
}

public struct Observer<State>: Hashable {
    let id: UUID

    private let observeClosure: (State, @escaping StatusHandler) -> Void

    init(id: UUID, observe: @escaping (State, @escaping StatusHandler) -> Void) {
        self.id = id
        self.observeClosure = observe
    }
}

public extension Observer {
    init(observe: @escaping (State, @escaping StatusHandler) -> Void) {
        id = UUID()
        self.observeClosure = observe
    }

    func send(_ state: State, complete: @escaping StatusHandler) {
        observeClosure(state, complete)
    }
}

public extension Observer {
    static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
