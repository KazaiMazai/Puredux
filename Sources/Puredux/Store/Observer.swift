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
    
    ///     Observer's main closure that handle State changes and calls complete handler
    ///        - Parameter state: new observed State
    ///        - Parameter complete: complete handler that Observer calls when the work is done
    ///
    public typealias StateObserver = (_ state: State, _ prev: State?, _ complete: @escaping  StatusHandler) -> Void
    
    let id: UUID
    
    private let observeClosure: StateObserver
    private let prevState: Referenced<State?> = Referenced(value: nil)
    
    init(id: UUID, observe: @escaping StateHandler) {
        self.id = id
        self.observeClosure = { state, _, complete in observe(state, complete) }
    }
    
    init(id: UUID, observe: @escaping StateObserver) {
        self.id = id
        self.observeClosure = observe
    }
    
    func send(_ state: State, complete: @escaping StatusHandler) {
        let prev = prevState.value
        prevState.value = state
        observeClosure(state, prev, complete)
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

extension Observer {
    
    static func asObserver<Props, Action>(
        _ observer: AnyObject,
        of store: Store<State, Action>,
        props: @escaping (State, Store<State, Action>) -> Props,
        propsQueue: ObservationQueue = .sharedPresentationQueue,
        removeStateDuplicates equating: Equating<State> = .neverEqual,
        observerQueue: ObservationQueue = .main,
        handler: @escaping (Props) -> Void
        
    ) -> Observer<State> {
        
        Observer { [weak observer] state, prevState, complete in
            
            propsQueue.dispatchQueue.async { [weak observer] in
                guard let observer else {
                    complete(.dead)
                    return
                }
                
                if equating.isEqual(state, to: prevState) {
                    complete(.active)
                    return
                }
                
                let newProps = props(state, store)
                
                observerQueue.dispatchQueue.async { [weak observer] in
                    guard let observer else {
                        complete(.dead)
                        return
                    }
                    
                    handler(newProps)
                    complete(.active)
                }
            }
        }
    }
    
    static func asObserver<Action>(
        _ observer: AnyObject,
        of store: Store<State, Action>,
        removeStateDuplicates equating: Equating<State> = .neverEqual,
        observerQueue: ObservationQueue = .main,
        handler: @escaping (State) -> Void
        
    ) -> Observer<State> {
        
        Observer { [weak observer] state, prevState, complete in
            
            guard let observer else {
                complete(.dead)
                return
            }
            
            if equating.isEqual(state, to: prevState) {
                complete(.active)
                return
            }
            
            observerQueue.dispatchQueue.async { [weak observer] in
                guard let observer else {
                    complete(.dead)
                    return
                }
                
                handler(state)
                complete(.active)
            }
        }
    }
}

