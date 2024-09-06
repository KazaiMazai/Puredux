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

public extension Observer {
    ///     Closure that handles  Observer's status
    ///     - Parameter  status: observer status to handle
    ///
    typealias StatusHandler = (_ status: ObserverStatus) -> Void

    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: newly observed State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    ///
    typealias StateHandler = (_ state: State) -> ObserverStatus

    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: newly observed State
    ///        - Parameter prev: previous State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    typealias StatesHandler = (_ state: State, _ prev: State?) -> ObserverStatus
}

/// Observer can be subscribed to Store to handle state updates
///
public struct Observer<State>: Hashable {
    typealias ObserverHandler = (_ state: State, _ prev: State?) -> (ObserverStatus, State?)

    let id: UUID

    private let statesObserver: ObserverHandler
    private let keepsPrevState: Bool
    private let prevState: Referenced<State?> = Referenced(nil)

    init(id: UUID = UUID(),
         keepsPrevState: Bool,
         observe: @escaping ObserverHandler) {
        self.id = id
        self.keepsPrevState = keepsPrevState
        self.statesObserver = observe
    }

    var state: State? {
        prevState.value
    }

    func send(_ state: State) -> ObserverStatus {
        guard keepsPrevState else {
            let (status, state) = statesObserver(state, nil)
            return status
        }

        let prev = prevState.value
        let (status, state) = statesObserver(state, prev)
        prevState.value = state
        return status
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
//    init(observe: @escaping StateHandler) {
//        self.init(id: UUID(), observe: observe)
//    }
    ///     Initializes a new store Observer
    ///
    ///     - Parameter observe:Is a closure that receive state and StatusHandler as parameters.
    ///     When Observer decides to unsubscribe from store it passes .dead status parameter to status handler.
    ///
    ///     - Returns: Observer
    ///
    ///     Observer handles new states, sent by the Store.
    ///
//    init(observe: @escaping StatesHandler) {
//        self.init(id: UUID(), observe: observe)
//    }
}

public extension Observer {
    static func == (lhs: Observer<State>, rhs: Observer<State>) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Observer {
    init(id: UUID = UUID(), observe: @escaping StateHandler) {
        self.init(id: id, keepsPrevState: false) { state,_ in
            (observe(state), state)
        }
    }

    init(id: UUID = UUID(), observe: @escaping StatesHandler) {
        self.init(id: id, keepsPrevState: false) { state, prevState in
            (observe(state, prevState), state)
        }
    }
}

// MARK: - Deduplicating Observers

extension Observer {

    init(_ observer: AnyObject?,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping StateHandler) {

        self.init(observer, id: id, removeStateDuplicates: equating) { state, _ in
            (observe(state), state)
        }
    }

    init(_ observer: AnyObject?,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping ObserverHandler) {

        self.init(id: id, keepsPrevState: equating != nil) { [weak observer] state, prevState in
            guard observer != nil else {
                return (.dead, state)
            }

            guard let equating else {
                return observe(state, prevState)
            }

            guard !equating.isEqual(state, to: prevState) else {
                return (.active, state)
            }

            return observe(state, prevState)
        }
    }

//    init(id: UUID = UUID(),
//         removeStateDuplicates equating: Equating<State>? = nil,
//         observe: @escaping ObserverHandler) {
//
//        self.init(id: id, keepsPrevState: equating != nil) { state, prevState in
//            guard let equating else {
//                return observe(state, prevState)
//            }
//
//            guard !equating.isEqual(state, to: prevState) else {
//                return (.active, state)
//            }
//
//            return observe(state, prevState)
//        }
//    }
}
