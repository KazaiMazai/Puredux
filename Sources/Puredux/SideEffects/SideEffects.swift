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
                effectOperator.run(allEffects, on: queue, state: state, create: create)
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
                effectOperator.run([effect], on: queue, state: state) { state, _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect<T>(onChange keyPath: KeyPath<State, T>,
                       on queue: DispatchQueue = .main,
                       create: @escaping (State) -> Effect) where T: Equatable {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let effect = Effect.State.running()
                effectOperator.run([effect], on: queue, state: state) { state, _ in
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
                
                effectOperator.run([effect], on: queue, state: state) { state, _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
    
    func sideEffect(_ keyPath: KeyPath<State, Bool>,
                    on queue: DispatchQueue = .main,
                    run: @escaping (State) -> Void) {
        
        sideEffect(keyPath, on: queue) { state in
            Effect { run(state) }
        }
    }
}
 

extension Store where State == Effect.State {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect) {
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .asEquatable) { [effectOperator] state, prevState, complete in
                
                let effects = [state]
                effectOperator.run(effects, on: queue, state: state, create: create)
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
}

extension Store {
    func sideEffect(on queue: DispatchQueue = .main,
                    create: @escaping (State, Effect.State) -> Effect)
    where
    State: Collection & Hashable,
    State.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: .asEquatable) { [effectOperator] state, prevState, complete in
                
                effectOperator.run(state, on: queue, state: state, create: create)
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
    }
}


func foo() {
    let store = Store<(isAuth: Bool, inProgess: Bool), Int>(dispatcher: {_ in }, subscribe: {_ in})
    
    store.sideEffect(\.inProgess) { state in .skip }
}


extension Effect {
    static func doSomething(_ isAuth: Bool) -> Effect {
        guard isAuth else {
            return .skip
        }
        
        return Effect {
            
        }
    }
}

func foo2() {
    let store = Store<(isAuth: Bool, count: Int), Int>(dispatcher: {_ in }, subscribe: {_ in})
    
    store.sideEffect(onChange: \.count) { state in
        
        guard state.isAuth else {
            return .skip
        }
        
        return Effect {
            
        }
    }
}
