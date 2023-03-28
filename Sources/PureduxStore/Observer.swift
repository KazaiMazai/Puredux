//
//  File.swift
//
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import Dispatch
import Foundation

public enum ObserverStatus {
    case active
    case dead
}

/// Observer can be subscribed to Store to handle state updates
///
public struct Observer<State>: Hashable {

    ///     Closure that handles  Observer's status
    ///     - Parameter  status: observer status to handle
    ///
    public typealias StatusHandler = (_ status: ObserverStatus) -> Void

    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: new observed State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    ///
    public typealias StateHandler = (_ state: State, _ complete: @escaping  StatusHandler) -> Void

    let id: UUID

    private let observeClosure: StateHandler

    init(id: UUID, observe: @escaping (State, @escaping StatusHandler) -> Void) {
        self.id = id
        self.observeClosure = observe
    }

    func send(_ state: State, complete: @escaping StatusHandler) {
        observeClosure(state, complete)
    }
}

public extension Observer {

    ///     Initializes a new store Observer
    ///
    ///     - Parameter observe:Is a closure that receive state and StatusHandler as parameters.
    ///     When Observer decides to unsubscribe from store it passes .dead status parameter to status handler.
    ///
    ///     - Returns: Observer
    ///
    ///     Observer handles new states, sent by the Store.
    ///
    init(observe: @escaping StateHandler) {
        id = UUID()
        self.observeClosure = observe
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
