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
                             create: @escaping (State, Effect.State) -> Effect)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Effect.State>,
                    on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let effect = state[keyPath: keyPath]
                effectOperator.run([effect], on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect<T>(_ keyPath: KeyPath<State, T>,
                       on queue: DispatchQueue = .main,
                       create: @escaping (State) -> Effect) where T: Equatable {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let effect = Effect.State.running()
                effectOperator.run([effect], on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Bool>,
                    on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
              
                let isRunning = state[keyPath: keyPath]
                let effect: Effect.State = isRunning ? .running() : .idle()
                
                effectOperator.run([effect], on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
}
 
extension Store {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State == Effect.State  {
        
        sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect)
    where
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State: Equatable  {
        
        sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State == Bool  {
        
        sideEffect(\.self, on: queue, create: create)
    }
}


extension StateStore {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State == Effect.State  {
        
        strongStore().sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect)
    where
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        strongStore().sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State: Equatable  {
        
        strongStore().sideEffect(\.self, on: queue, create: create)
    }
    
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) where State == Bool  {
        
        strongStore().sideEffect(\.self, on: queue, create: create)
    }
}


extension StateStore {
    func sideEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                             on queue: DispatchQueue = .main,
                             create: @escaping (State, Effect.State) -> Effect)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        strongStore().sideEffect(keyPath, on: queue, create: create)
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Effect.State>,
                    on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) {
        
        strongStore().sideEffect(keyPath, on: queue, create: create)
    }
    
    func sideEffect<T>(_ keyPath: KeyPath<State, T>,
                       on queue: DispatchQueue = .main,
                       create: @escaping (State) -> Effect) where T: Equatable {
        
        strongStore().sideEffect(keyPath, on: queue, create: create)
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Bool>,
                    on queue: DispatchQueue = .main,
                    create: @escaping (State) -> Effect) {
        
        strongStore().sideEffect(keyPath, on: queue, create: create)
    }
}
