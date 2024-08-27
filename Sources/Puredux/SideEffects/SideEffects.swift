//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

protocol EffectsSource {
    associatedtype State
    associatedtype Action
    
    var effectsStore: Store<State, Action> { get }
}

extension Store: EffectsSource {
    var effectsStore: Store<State, Action> { self }
}

extension StateStore: EffectsSource {
    var effectsStore: Store<State, Action> { strongStore() }
}

extension EffectsSource {
    typealias CreateForEachEffect = (State, Effect.State) -> Effect
    typealias CreateEffect = (State) -> Effect
    
    @discardableResult
    func effect(_ observer: AnyObject,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State == Effect.State  {
        
        effect(observer, \.self, on: queue, create: create)
    }
    
    @discardableResult
    func forEachEffect(_ observer: AnyObject,
                       on queue: DispatchQueue = .main,
                       create: @escaping CreateForEachEffect) -> Self
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        forEachEffect(observer, \.self, on: queue, create: create)
    }
    
    @discardableResult
    func onChangeEffect(_ observer: AnyObject,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State: Equatable {
        
        effect(observer, onChange: \.self, on: queue, create: create)
    }
    
    @discardableResult
    func toggleEffect(_ observer: AnyObject,
                      on queue: DispatchQueue = .main,
                      create: @escaping CreateEffect) -> Self where State == Bool {
        
        effect(observer, toggle: \.self, on: queue, create: create)
    }
}

extension EffectsSource {
    @discardableResult
    func effect(_ cancellables: inout Set<CancellableEffect>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State == Effect.State  {
        
        effect(&cancellables, \.self, on: queue, create: create)
    }
    
    @discardableResult
    func forEachEffect(_ cancellables: inout Set<CancellableEffect>,
                       on queue: DispatchQueue = .main,
                       create: @escaping CreateForEachEffect) -> Self
    
    where State: Collection & Hashable, State.Element == Effect.State {
        
        forEachEffect(&cancellables, \.self, on: queue, create: create)
    }
    
    @discardableResult
    func onChangeEffect(_ cancellables: inout Set<CancellableEffect>,
                        on queue: DispatchQueue = .main,
                        create: @escaping CreateEffect) -> Self where State: Equatable {
        
        effect(&cancellables, onChange: \.self, on: queue, create: create)
    }
    
    @discardableResult
    func toggleEffect(_ cancellables: inout Set<CancellableEffect>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self where State == Bool {
        
        effect(&cancellables, toggle: \.self, on: queue, create: create)
    }
}

extension EffectsSource {
    @discardableResult
    func forEachEffect<Effects>(_ observer: AnyObject,
                                _ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping CreateForEachEffect) -> Self
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        let effectOperator = EffectOperator()
        
        effectsStore.subscribe(observer: Observer(
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
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        
        effectsStore.subscribe(observer: Observer(
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
                   onChange keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping CreateEffect) -> Self where T: Equatable {
        
        let effectOperator = EffectOperator()
        
        effectsStore.subscribe(observer: Observer(
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
                toggle keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        
        effectsStore.subscribe(observer: Observer(
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
                create: @escaping CreateEffect) -> Self {
        
        let effectOperator = EffectOperator()
        
        effectsStore.subscribe(observer: Observer(
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


extension EffectsSource {
    @discardableResult
    func forEachEffect<Effects>(_ cancellables: inout Set<CancellableEffect>,
                                _ keyPath: KeyPath<State, Effects>,
                                on queue: DispatchQueue = .main,
                                create: @escaping CreateForEachEffect) -> Self
    where Effects: Collection & Hashable, Effects.Element == Effect.State {
        
        let cancellable = CancellableEffect()
        cancellables.insert(cancellable)
        return forEachEffect(cancellable, keyPath, on: queue, create: create)
    }
    
    @discardableResult
    func effect(_ cancellables: inout Set<CancellableEffect>,
                _ keyPath: KeyPath<State, Effect.State>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let cancellable = CancellableEffect()
        cancellables.insert(cancellable)
        return effect(cancellable, keyPath, on: queue, create: create)
    }
    
    @discardableResult
    func effect<T>(_ cancellables: inout Set<CancellableEffect>,
                   onChange keyPath: KeyPath<State, T>,
                   on queue: DispatchQueue = .main,
                   create: @escaping CreateEffect) -> Self where T: Equatable {
        
        let cancellable = CancellableEffect()
        cancellables.insert(cancellable)
        return effect(cancellable, onChange: keyPath, on: queue, create: create)
    }
    
    @discardableResult
    func effect(_ cancellables: inout Set<CancellableEffect>,
                toggle keyPath: KeyPath<State, Bool>,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let cancellable = CancellableEffect()
        cancellables.insert(cancellable)
        return effect(cancellable, toggle: keyPath, on: queue, create: create)
    }
    
    @discardableResult
    func effect(_ cancellables: inout Set<CancellableEffect>,
                withDelay timeInterval: TimeInterval,
                removeStateDuplicates equating: Equating<State>?,
                on queue: DispatchQueue = .main,
                create: @escaping CreateEffect) -> Self {
        
        let cancellable = CancellableEffect()
        cancellables.insert(cancellable)
        return effect(
            cancellable,
            withDelay: timeInterval,
            removeStateDuplicates: equating,
            on: queue, 
            create: create
        )
    }
}

class CancellableEffect: Hashable {
    class EffectStateObserver { }
    
    let id = UUID()
    var observer: AnyObject = EffectStateObserver()
    
    static func == (lhs: CancellableEffect, rhs: CancellableEffect) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func cancel() {
        observer = EffectStateObserver()
    }
}
  
