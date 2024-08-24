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
    typealias StateHandler = (_ state: State, _ complete: @escaping  StatusHandler) -> Void
    
    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: newly observed State
    ///        - Parameter prev: previous State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    @available(*, deprecated, renamed: "StatesHandler", message: "StateObserver was renamed to StatesHandler")
    typealias StateObserver = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> Void
    ///
    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: newly observed State
    ///        - Parameter prev: previous State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    typealias StatesHandler = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> Void
}

/// Observer can be subscribed to Store to handle state updates
///
public struct Observer<State>: Hashable {
    typealias ObserverHandler = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> State?
    
    let id: UUID
    
    private let statesObserver: ObserverHandler
    private let keepsCurrentState: Bool
    private let prevState: Referenced<State?> = Referenced(nil)
    
    init(id: UUID = UUID(),
         keepsCurrentState: Bool,
         observe: @escaping ObserverHandler) {
        self.id = id
        self.keepsCurrentState = keepsCurrentState
        self.statesObserver = observe
    }
    
    var state: State? {
        prevState.value
    }
    
    func send(_ state: State, complete: @escaping StatusHandler) {
        guard keepsCurrentState else {
            let _ = statesObserver(state, nil, complete)
            prevState.value = nil
            return
        }
        
        let prev = prevState.value
        prevState.value = statesObserver(state, prev, complete)
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
        self.init(id: UUID(), observe: observe)
    }
    ///     Initializes a new store Observer
    ///
    ///     - Parameter observe:Is a closure that receive state and StatusHandler as parameters.
    ///     When Observer decides to unsubscribe from store it passes .dead status parameter to status handler.
    ///
    ///     - Returns: Observer
    ///
    ///     Observer handles new states, sent by the Store.
    ///
    init(observe: @escaping StatesHandler) {
        self.init(id: UUID(), observe: observe)
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

extension Observer {
    init(id: UUID, observe: @escaping StateHandler) {
        self.init(id: id, keepsCurrentState: false) { state, _, complete in
            observe(state, complete)
            return nil
        }
    }
    
    init(id: UUID, observe: @escaping StatesHandler) {
        self.init(id: id, keepsCurrentState: false) { state, prevState, complete in
            observe(state, prevState, complete)
            return state
        }
    }
}


// MARK: - Deduplicating Observers

extension Observer {
    
    init(_ observer: AnyObject,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping StateHandler) {
        
        self.init(observer, id: id, removeStateDuplicates: equating) { state, _, complete in
            observe(state, complete)
            return state
        }
    }
    
    init(_ observer: AnyObject,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping ObserverHandler) {
        
        self.init(id: id, keepsCurrentState: equating != nil) { [weak observer] state, prevState, complete in
            guard observer != nil else {
                complete(.dead)
                return state
            }
            
            guard let equating else {
                return observe(state, prevState, complete)
            }
            
            guard !equating.isEqual(state, to: prevState) else {
                complete(.active)
                return state
            }
            
            return observe(state, prevState, complete)
        }
    }
    
    init(id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping ObserverHandler) {
        
        self.init(id: id, keepsCurrentState: equating != nil) { state, prevState, complete in
            guard let equating else {
                complete(.active)
                return observe(state, prevState, complete)
            }
            
            guard !equating.isEqual(state, to: prevState) else {
                complete(.active)
                return state
            }
            
            return observe(state, prevState, complete)
        }
    }
}

