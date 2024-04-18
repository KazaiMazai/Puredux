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
    ///
    typealias StateObserver = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> Void
}

/// Observer can be subscribed to Store to handle state updates
///
public struct Observer<State>: Hashable {
    let id: UUID
    
    private let stateHandler: StatesObserver
    private let keepsCurrentState: Bool
    private let prevState: Referenced<State?> = Referenced(nil)
    
    var state: State? {
        prevState.value
    }
    
    func send(_ state: State, complete: @escaping StatusHandler) {
        guard keepsCurrentState else {
            let _ = stateHandler(state, nil, complete)
            prevState.value = nil
            return
        }
        
        let prev = prevState.value
        prevState.value = stateHandler(state, prev, complete)
        
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
    init(observe: @escaping StateObserver) {
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
    init(id: UUID = UUID(), observe: @escaping StateHandler) {
        self.id = id
        self.keepsCurrentState = false
        self.stateHandler = { state, _, complete in
            observe(state, complete)
            return nil
        }
    }
    
    
    init(id: UUID = UUID(),
         observe: @escaping StateObserver) {
        self.id = id
        self.keepsCurrentState = false
        self.stateHandler = { state, prevState, complete in
            observe(state, prevState, complete)
            return state
        }
    }
    
    init(_ observer: AnyObject,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping StateHandler) {
        
        self.id = id
        self.keepsCurrentState = equating != nil
        self.stateHandler = { [weak observer] state, prevState, complete in
            guard observer != nil else {
                complete(.dead)
                return state
            }
            
            guard let equating else {
                observe(state, complete)
                return state
            }
            
            guard !equating.isEqual(state, to: prevState) else {
                complete(.active)
                return state
            }
            
            observe(state, complete)
            return state
        }
    }
    
    private init(id: UUID = UUID(),
                 keepsCurrentState: Bool,
                 observe: @escaping StatesObserver) {
        self.id = id
        self.keepsCurrentState = false
        self.stateHandler = observe
    }
    
    static func alwaysActive(id: UUID = UUID(),
                             removeStateDuplicates equating: Equating<State>,
                             observe: @escaping StatesObserver) -> Observer {
        
        Observer(id: id, keepsCurrentState: true) { state, prevState, complete in
            
            guard !equating.isEqual(state, to: prevState) else {
                complete(.active)
                return state
            }
            
            return observe(state, prevState, complete)
        }
    }
}
 

private extension Observer {
    final class Referenced<T> {
        var value: T
        
        init(_ value: T) {
            self.value = value
        }
    }
}

extension Observer {
    typealias StatesObserver = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> State?
    
}
