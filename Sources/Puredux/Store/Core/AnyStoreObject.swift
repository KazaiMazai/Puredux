//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30/08/2024.
//

import Foundation

final class AnyStoreObject<State, Action>: StoreObjectProtocol  {
    
    private let boxed: BaseBox
    
    init<StoreObject: StoreObjectProtocol>(_ storeObject: StoreObject)
        where
        StoreObject.State == State,
        StoreObject.Action == Action  {
            
        self.boxed = Box(storeObject)
    }
    
    func dispatch(_ action: Action) {
        boxed.dispatch(action)
    }
    
    var queue: DispatchQueue {
        boxed.queue
    }
    
    var actionsInterceptor: ActionsInterceptor<Action>? {
        boxed.actionsInterceptor
    }
    
    func unsubscribe(observer: Observer<State>) {
        boxed.unsubscribe(observer: observer)
    }
    
    func subscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        boxed.subscribe(observer: observer, receiveCurrentState: receiveCurrentState)
    }
    
    func dispatch(scopedAction: ScopedAction<Action>) {
        boxed.dispatch(scopedAction: scopedAction)
    }
    
    func subscribe(observer: Observer<State>) {
        boxed.subscribe(observer: observer)
    }
    
    func syncUnsubscribe(observer: Observer<State>) {
        boxed.syncUnsubscribe(observer: observer)
    }
    
    func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool) {
        boxed.syncSubscribe(observer: observer, receiveCurrentState: receiveCurrentState)
    }
    
    func syncDispatch(scopedAction: ScopedAction<Action>) {
        boxed.syncDispatch(scopedAction: scopedAction)
    }
}

extension AnyStoreObject {
    func map<T>(_ transform: @escaping (State) -> T) -> AnyStoreObject<T, Action> {
        AnyStoreObject<T, Action>(boxed.map(transform: transform))
    }
}

private extension AnyStoreObject {
    final class Box<StoreObject: StoreObjectProtocol>: BaseBox
    where
    StoreObject.State == State,
    StoreObject.Action == Action {
        
        private var storeObject: StoreObject
        
        init(_ storeObject: StoreObject) {
            self.storeObject = storeObject
        }
        
        override func dispatch(_ action: Action) {
            storeObject.dispatch(action)
        }
        
        override var queue: DispatchQueue {
            storeObject.queue
        }
        
        override var actionsInterceptor: ActionsInterceptor<Action>? {
            storeObject.actionsInterceptor
        }
        
        override func unsubscribe(observer: Observer<State>) {
            storeObject.unsubscribe(observer: observer)
        }
        
        override func subscribe(observer: Observer<State>, receiveCurrentState: Bool) {
            storeObject.subscribe(observer: observer, receiveCurrentState: receiveCurrentState)
        }
        
        override func dispatch(scopedAction: ScopedAction<Action>) {
            storeObject.dispatch(scopedAction: scopedAction)
        }
        
        override func subscribe(observer: Observer<State>) {
            storeObject.subscribe(observer: observer)
        }
        
        override func syncUnsubscribe(observer: Observer<State>) {
            storeObject.syncUnsubscribe(observer: observer)
        }
        
        override  func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool) {
            storeObject.syncSubscribe(observer: observer, receiveCurrentState: receiveCurrentState)
        }
        
        override func syncDispatch(scopedAction: ScopedAction<Action>) {
            storeObject.syncDispatch(scopedAction: scopedAction)
        }
    }
}

private extension AnyStoreObject {
    class BaseBox: StoreObjectProtocol {
        init() {
            guard type(of: self) != BaseBox.self else {
                fatalError("Cannot initialise, must subclass")
            }
        }
        
        func dispatch(_ action: Action) {
            fatalError("Cannot initialise, must subclass")
        }
        
        var queue: DispatchQueue {
            fatalError("Cannot initialise, must subclass")
        }
        
        var actionsInterceptor: ActionsInterceptor<Action>? {
            fatalError("Cannot initialise, must subclass")
        }
        
        func unsubscribe(observer: Observer<State>) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func subscribe(observer: Observer<State>, receiveCurrentState: Bool) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func dispatch(scopedAction: ScopedAction<Action>) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func subscribe(observer: Observer<State>) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func syncUnsubscribe(observer: Observer<State>) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func syncSubscribe(observer: Observer<State>, receiveCurrentState: Bool) {
            fatalError("Cannot initialise, must subclass")
        }
        
        func syncDispatch(scopedAction: ScopedAction<Action>) {
            fatalError("Cannot initialise, must subclass")
        }
    }
}