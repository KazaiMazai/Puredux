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
    ///        - Parameter state: newly observed State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    ///
    public typealias StateHandler = (_ state: State, _ complete: @escaping  StatusHandler) -> Void
    
    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: newly observed State
    ///        - Parameter prev: previous State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    ///
    public typealias StateObserver = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> Void
    
    let id: UUID
    
    private let observeClosure: StateObserver
    private let removeStateDuplicates: Equating<State>?
    private let prevState: Referenced<State?> = Referenced(value: nil)
   
    func send(_ state: State, complete: @escaping StatusHandler) {
        guard let removeStateDuplicates else {
            observeClosure(state, nil, complete)
            return
        }
        let prev = prevState.value
        prevState.value = state
        observeClosure(state, prev, complete)
    }
}

extension Observer {
    init(id: UUID, observe: @escaping StateHandler) {
        self.id = id
        self.removeStateDuplicates = nil
        self.observeClosure = { state, _, complete in observe(state, complete) }
    }
    
    init(id: UUID, observe: @escaping StateObserver) {
        self.id = id
        self.removeStateDuplicates = nil
        self.observeClosure = observe
    }
    
    init(_ observer: AnyObject,
         id: UUID = UUID(),
         removeStateDuplicates equating: Equating<State>? = nil,
         observe: @escaping StateHandler) {
        
        self.id = id
        self.removeStateDuplicates = equating
        self.observeClosure = { [weak observer] state, prevState, complete in
            guard observer != nil else {
                complete(.dead)
                return
            }
            
            let isEqual = equating?.isEqual(state, to: prevState) ?? false
            
            guard isEqual else {
                complete(.active)
                return
            }
            
            observe(state, complete)
        }
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

private extension Observer {
    final class Referenced<T> {
        var value: T
        
        init(value: T) {
            self.value = value
        }
    }
}
