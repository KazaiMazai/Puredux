//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Dispatch
import Foundation

final class EffectOperator {
    private(set) var executing: [Effect.State: Weak<DispatchWorkItem>] = [:]
    private(set) var isSynced = true
    
    func run<Effects>(_ effects: Effects,
                      on queue: DispatchQueue,
                      create: (Effect.State) -> Effect)
    where
    Effects: Collection & Hashable,
    Effects.Element == Effect.State {
        
        let expectedToRun = Set(effects.filter { $0.isInProgress })
        
        executing.keys
            .filter { !expectedToRun.contains($0) }
            .forEach {
                executing[$0]?.object?.cancel()
                executing[$0] = nil
            }
    
        expectedToRun
            .filter { !executing.keys.contains($0) }
            .map { state in (state, create(state)) }
            .filter { _, effect in effect.canBeExecuted }
            .forEach { state, effect in
                let workItem = DispatchWorkItem(block: effect.operation)
                executing[state] = Weak(workItem)
                queue.asyncAfter(delay: state.delay, execute: workItem)
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