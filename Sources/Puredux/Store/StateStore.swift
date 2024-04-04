//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 04/04/2024.
//

import Foundation

public struct StateStore<State, Action> {
    let storeObject: any StoreProtocol<State, Action>
    
    public func store() -> Store<State, Action> {
        Store<State, Action>(
            dispatcher: { [weak storeObject] in storeObject?.dispatch($0) },
            subscribe: { [weak storeObject] in storeObject?.subscribe(observer: $0) })
    }
    
    public func dispatch(_ action: Action) {
        storeObject.dispatch(action)
    }
    
    public func subscribe(observer: Observer<State>) {
        storeObject.subscribe(observer: observer)
    }
}