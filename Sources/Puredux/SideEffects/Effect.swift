//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

struct Effect {
    let operation: () -> Void
    
    init(operation: @escaping () -> Void) {
        self.operation = operation
    }
    
    @available(iOS 13.0, *)
    init(operation: @escaping () async -> Void) {
        self.operation = {
            Task {
                await operation()
            }
        }
    }
}

extension Effect {
    struct State: Codable, Equatable, Hashable {
        typealias ID = UUID
        
        private(set) var id = ID()
        private var state = InternalState()
        
        var status: Status {
            state.status
        }
        
        var isInProgress: Bool {
            state.isInProgress
        }
        
        var isSuccess: Bool {
            state.isSuccess
        }
        
        var isCancelled: Bool {
            state.isCancelled
        }
        
        var isIdle: Bool {
            state.isIdle
        }
        
        var isFailed: Bool {
            state.isFailed
        }
        
        var error: Error? {
            state.error
        }
        
        var currentAttempt: Int? {
            state.currentAttempt?.attempt
        }
        
        var currentAttemptDelay: TimeInterval? {
            state.currentAttempt?.delay
        }
    }
}

extension Effect.State {
    
    enum Status: Int {
        case none
        case inProgress
        case success
        case failure
        case cancelled
    }
}

extension Effect.State {
     
    mutating func run(maxAttemptCount: Int = 1,
                      delay: TimeInterval = .zero) {
        
        state.run(maxAttemptCount: maxAttemptCount, delay: delay)
    }
    
    mutating func restart(maxAttemptCount: Int = 1,
                          delay: TimeInterval = .zero) {
        
        state.restart(maxAttemptCount: maxAttemptCount, delay: delay)
    }
   
    mutating func retryOrFailWith(_ error: Error?) {
        state.retryOrFailWith(error)
    }
    
    mutating func cancel() {
        state.cancel()
    }
    
    mutating func succeed() {
        state.succeed()
    }
    
    mutating func reset() {
        state.reset()
    }
    
    mutating func fail(_ error: Error) {
        state.fail(error)
    }
}
 
