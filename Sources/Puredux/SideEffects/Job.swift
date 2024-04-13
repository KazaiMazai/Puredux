//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

struct Job: Codable, Equatable {
    private var state: State
    
    init() {
        state = State()
    }
    
    init(_ error: Error) {
        state = State(error)
    }
    
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

extension Job {
    
    enum Status: Int {
        case none
        case inProgress
        case success
        case failure
        case cancelled
    }
}

extension Job {
     
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
}
 
