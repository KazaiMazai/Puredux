//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

// MARK: - Store Effects
extension Store {
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State == Effect.State  {
        
        effect(\.self, on: queue, create: create)
    }
    
    @discardableResult
    func forEachEffect(on queue: DispatchQueue = .main,
                       create: @escaping (State, Effect.State) -> Effect) -> Self
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        forEachEffect(\.self, on: queue, create: create)
    }
    
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State: Equatable {
        
        effect(\.self, on: queue, create: create)
    }
    
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State == Bool {
        
        effect(\.self, on: queue, create: create)
    }
}

// MARK: - StateStore Effects

extension StateStore {
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State == Effect.State   {
        
        strongStore().effect(on: queue, create: create)
        return self
    }
    
    @discardableResult
    func forEachEffect(on queue: DispatchQueue = .main,
                       create: @escaping (State, Effect.State) -> Effect) -> Self
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        strongStore().forEachEffect(on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State: Equatable {
        
        strongStore().effect(on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect(on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self where State == Bool {
        
        strongStore().effect(on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect(withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        strongStore().effect(
            withDelay: timeInterval,
            removeStateDuplicates: removeStateDuplicates,
            on: queue,
            create: create
        )
        return self
    }
}

// MARK: - StateStore Effects

extension StateStore {
    @discardableResult
    func forEachEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping (State, Effect.State) -> Effect) -> Self
    
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        strongStore().forEachEffect(keyPath, on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        strongStore().effect(keyPath, on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect<T>(_ keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping (State) -> Effect) -> Self where T: Equatable {
        
        strongStore().effect(keyPath, on: queue, create: create)
        return self
    }
    
    @discardableResult
    func effect(_ keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        strongStore().effect(keyPath, on: queue, create: create)
        return self
    }
}

extension Store {
    @discardableResult
    func forEachEffect<Effects>(_ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping (State, Effect.State) -> Effect) -> Self
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
        
        return self
    }
    
    @discardableResult
    func effect(_ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
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
        
        return self
    }
    
    @discardableResult
    func effect<T>(_ keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping (State) -> Effect) -> Self where T: Equatable {
        
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
        
        return self
    }
    
    @discardableResult
    func effect(_ keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
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
        
        return self
    }
    
    @discardableResult
    func effect(withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState, complete in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
}

extension Store {
    @discardableResult
    func forEachEffect<Effects>(_ observer: AnyObject,
                                _ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping (State, Effect.State) -> Effect) -> Self
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let allEffects = state[keyPath: keyPath]
                effectOperator.run(allEffects, on: queue) { effectState in
                    create(state, effectState)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
    
    @discardableResult
    func effect(_ observer: AnyObject,
                _ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let effect = state[keyPath: keyPath]
                effectOperator.run(effect, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
    
    @discardableResult
    func effect<T>(_ observer: AnyObject,
                   _ keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping (State) -> Effect) -> Self where T: Equatable {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                let effect: Effect.State = prevState == nil ? .idle() : .running()
                effectOperator.run(effect, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
    
    @discardableResult
    func effect(_ observer: AnyObject,
                _ keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            observer,
            removeStateDuplicates: .keyPath(keyPath)) { [effectOperator] state, prevState, complete in
                
                let isRunning = state[keyPath: keyPath]
                effectOperator.run(isRunning, on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
    
    @discardableResult
    func effect(_ observer: AnyObject,
                withDelay timeInterval: TimeInterval,
                removeStateDuplicates: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping (State) -> Effect) -> Self {
        
        let effectOperator = EffectOperator()
        
        subscribe(observer: Observer(
            observer,
            removeStateDuplicates: removeStateDuplicates) { [effectOperator] state, prevState, complete in
                effectOperator.run(.running(delay: timeInterval), on: queue) { _ in
                    create(state)
                }
                complete(.active)
                return effectOperator.isSynced ? state : prevState
            }
        )
        
        return self
    }
}
