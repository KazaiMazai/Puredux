//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

final class Scheduler {
    private(set) var executing: [Effect.State: Weak<DispatchWorkItem>] = [:]
    private(set) var isSynced = true
    
    func run<State, Effects>(_ effects: Effects,
                             on queue: DispatchQueue,
                             state: State,
                             create: @escaping (State, Effect.State) -> Effect)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let expectedToRun = Set(effects).filter { $0.isInProgress }
        
        executing.keys
            .filter { !expectedToRun.contains($0) }
            .forEach {
                executing[$0]?.object?.cancel()
                executing[$0] = nil
            }
    
        expectedToRun
            .filter { !executing.keys.contains($0) }
            .map { effectState in (effectState, create(state, effectState)) }
            .filter { _, effect in effect.canBeExecuted }
            .forEach { effectState, effect in
                let workItem = DispatchWorkItem(block: effect.operation)
                executing[effectState] = Weak(workItem)
                queue.asyncAfter(delay: effectState.delay, execute: workItem)
            }
        
        isSynced = expectedToRun.count == executing.count
    }
}

final class Weak<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T?) {
        self.object = object
    }
}
  
fileprivate extension DispatchQueue {
    func asyncAfter(delay: TimeInterval?, execute workItem: DispatchWorkItem) {
        guard let delay, delay > .zero else {
            async(execute: workItem)
            return
        }
        
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
