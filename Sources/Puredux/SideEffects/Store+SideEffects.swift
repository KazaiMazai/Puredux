//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch

extension Store {
    func sideEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                             on queue: DispatchQueue = .main,
                             create: @escaping (State, Effect.State) -> Effect?)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let sideEffects = SideEffects()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [sideEffects] state, prevState, complete in
                
                let allEffects = state[keyPath: keyPath]
                sideEffects.run(allEffects, on: queue, state: state, create: create)
                complete(.active)
                return sideEffects.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Effect.State>,
                    on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect?) {
        
        let sideEffects = SideEffects()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [sideEffects] state, prevState, complete in
                
                let effects = [state[keyPath: keyPath]]
                sideEffects.run(effects, on: queue, state: state, create: create)
                complete(.active)
                return sideEffects.isSynced ? state : prevState
            }
        )
    }
}

extension Store where State == Effect.State {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect?) {
        let sideEffects = SideEffects()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .asEquatable) { [sideEffects] state, prevState, complete in
                
                let effects = [state]
                sideEffects.run(effects, on: queue, state: state, create: create)
                complete(.active)
                return sideEffects.isSynced ? state : prevState
            }
        )
    }
}

extension Store {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect?)
    where
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        let sideEffects = SideEffects()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .asEquatable) { [sideEffects] state, prevState, complete in
                
                sideEffects.run(state, on: queue, state: state, create: create)
                complete(.active)
                return sideEffects.isSynced ? state : prevState
            }
        )
    }
}
