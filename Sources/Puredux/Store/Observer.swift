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
    /**     
     Observer's main closure that handle State changes and calls complete handler
        - Parameter state: newly observed State
        - Parameter complete: complete handler that Observer calls when the work is done
    */
    typealias StateHandler = @Sendable (_ state: State) -> ObserverStatus
}

/** Observer can be subscribed to Store to handle state updates */
public struct Observer<State>: Hashable, Sendable {
    typealias LastStatesHandler = @Sendable (_ state: State, _ prev: State?) -> ObserverStatus
    typealias ObserverHandler = @Sendable (_ state: State, _ prev: State?) -> (ObserverStatus, State?)

    let id: UUID

    private let statesObserver: ObserverHandler
    private let keepPrevState: Bool
    private let prevState: UncheckedReference<State?> = UncheckedReference(nil)

    init(id: UUID = UUID(),
         keepPrevState: Bool,
         observe: @escaping ObserverHandler) {
        self.id = id
        self.keepPrevState = keepPrevState
        self.statesObserver = observe
    }

    var state: State? {
        prevState.value
    }

    func send(_ state: State) -> ObserverStatus {
        guard keepPrevState else {
            let (status, _) = statesObserver(state, nil)
            return status
        }

        let prev = prevState.value
        let (status, state) = statesObserver(state, prev)
        prevState.value = state
        return status
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

public extension Observer {
    /**
     Initializes a new `Observer` instance.

     - Parameters:
        - id: A unique identifier for the observer. Defaults to a new UUID if not provided.
        - observe: A closure of type `StateHandler` that is invoked when the observer is notified of a state change.

     The `Observer` is initialized with the given `id` and an `observe` closure. The `keepPrevState` parameter is set to `false`, and the `observe` closure is called with the current state and the previous state (which is ignored).
     */
    init(id: UUID = UUID(), observe: @escaping StateHandler) {
        self.init(id: id, keepPrevState: false) { state, _ in
            (observe(state), state)
        }
    }
}

// MARK: - Observer attached to Object's lifecycle

extension Observer {
    init<ObserverObject: AnyObject & Sendable>(_ observer: ObserverObject?,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping StateHandler) {

        self.init(observer, id: id, removeStateDuplicates: equating) { state, _ in
            (observe(state), state)
        }
    }

    init<ObserverObject: AnyObject & Sendable>(_ observer: ObserverObject?,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping ObserverHandler) {

        self.init(id: id, keepPrevState: equating != nil) { [weak observer] state, prevState in
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
}
