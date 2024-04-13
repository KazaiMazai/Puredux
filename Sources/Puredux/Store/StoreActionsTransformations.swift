//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

extension Store {
    
    func map<A>(_ transform: @escaping (A) -> Action) -> Store<State, A> {
        Store<State, A>(
            dispatcher: { action in dispatch(transform(action)) },
            subscribe: subscribe
        )
    }
}

extension StateStore {
    
    func map<A>(_ transform: @escaping (A) -> Action) -> Store<State, A> {
        strongStore().map(transform)
    }
}
