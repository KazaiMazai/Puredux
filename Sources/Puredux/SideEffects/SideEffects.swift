//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch

extension Store {
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State == Effect.State  {
        
        effect(\.self, on: queue, create: create)
    }
    
    func forEachEffect(on queue: DispatchQueue = .main,
                       create: @escaping (State, Effect.State) -> Effect)
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        forEachEffect(\.self, on: queue, create: create)
    }
    
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State: Equatable  {
        
        effect(\.self, on: queue, create: create)
    }
    
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State == Bool  {
        
        effect(\.self, on: queue, create: create)
    }
}

extension StateStore {
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State == Effect.State  {
        
        strongStore().effect(on: queue, create: create)
    }
    
    func forEachEffect(on queue: DispatchQueue = .main,
                       create: @escaping (State, Effect.State) -> Effect)
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        strongStore().forEachEffect(on: queue, create: create)
    }
    
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State: Equatable  {
        
        strongStore().effect(on: queue, create: create)
    }
    
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) where State == Bool  {
        
        strongStore().effect(on: queue, create: create)
    }
    
    func effect(_ removeStateDuplicates: Equating<State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        strongStore().effect(removeStateDuplicates, on: queue, create: create)
    }
}

extension StateStore {
    func forEachEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping (State, Effect.State) -> Effect)
    
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        strongStore().forEachEffect(keyPath, on: queue, create: create)
    }
    
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        strongStore().effect(keyPath, on: queue, create: create)
    }
    
    func effect<T>(_ keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping (State) -> Effect) where T: Equatable {
        
        strongStore().effect(keyPath, on: queue, create: create)
    }
    
    func effect(_ keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        strongStore().effect(keyPath, on: queue, create: create)
    }
}

extension Store {
    func forEachEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping (State, Effect.State) -> Effect)
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
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
    
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func effect<T>(_ keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping (State) -> Effect) where T: Equatable {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func effect(_ keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func effect(_ removeStateDuplicates: Equating<State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState, complete in
                effectOperator.run(.running(), on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
}
