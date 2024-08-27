//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import Foundation

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
