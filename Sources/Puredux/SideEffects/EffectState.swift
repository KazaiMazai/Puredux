//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

extension Effect.State {
    enum InternalState: Codable, Equatable, Hashable {
        case none
        case inProgress(Attempt)
        case success
        case failure(Failure)
        case cancelled
        
        init() {
            self = .none
        }
    }
}

extension Effect.State.InternalState {
    var status: Effect.State.Status {
        switch self {
        case .none:
            return .none
        case .inProgress:
            return .inProgress
        case .success:
            return .success
        case .failure(_):
            return .failure
        case .cancelled:
            return .cancelled
        }
    }
    
    var error: Error? {
        guard case .failure(let effectFailure) = self else {
            return nil
        }
        
        return effectFailure
    }
    
    var currentAttempt: Attempt? {
        guard case let .inProgress(attempt) = self else {
            return nil
        }
        
        return attempt
    }
    
    var isInProgress: Bool {
        currentAttempt != nil
    }
}

extension Effect.State.InternalState {
    struct Failure: Codable, Equatable, Hashable, LocalizedError {
        let underlyingErrorDescription: String
        private(set) var underlyingError: Error?
        
        private enum CodingKeys: String, CodingKey {
            case underlyingErrorDescription
        }
        
        var errorDescription: String? {
            underlyingErrorDescription
        }
        
        init(_ error: Error) {
            self.underlyingErrorDescription = error.localizedDescription
            self.underlyingError = error
        }
        
        static func == (lhs: Failure, rhs: Failure) -> Bool {
            lhs.underlyingErrorDescription == rhs.underlyingErrorDescription
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(underlyingErrorDescription)
        }
    }
    
    enum Errors: LocalizedError {
        case unknownEffectExecutionError
        
        var errorDescription: String? {
            "Unknown effect execution error"
        }
    }
}

extension Effect.State.InternalState  {
    mutating func run(maxAttempts: Int,
                      delay: TimeInterval) {
        
        guard !isInProgress else {
            return
        }
        
        self = .inProgress(
            Attempt(
                maxAttempts: maxAttempts,
                delay: delay
            )
        )
    }
    
    mutating func restart(maxAttempts: Int,
                          delay: TimeInterval) {
        
        self = .inProgress(
            Attempt(
                maxAttempts: maxAttempts,
                delay: delay
            )
        )
    }
    
    mutating func retryOrFailWith(_ error: Error?) {
        self = nextAttemptOrFailWith(error ?? Errors.unknownEffectExecutionError)
    }
    
    mutating func fail(_ error: Error?) {
        self = .failure(Failure(error ?? Errors.unknownEffectExecutionError))
    }
    
    mutating func cancel() {
        self = .cancelled
    }
    
    mutating func succeed() {
        self = .success
    }
    
    mutating func reset() {
        self = .none
    }
}

extension Effect.State.InternalState {
    
    func nextAttemptOrFailWith(_ error: Error) -> Effect.State.InternalState {
        guard let job = currentAttempt,
              let next = job.nextAttempt()
        else {
            return .failure(Failure(error))
        }
        
        return .inProgress(next)
    }
}


extension Effect.State.InternalState {
    
    struct Attempt: Codable, Equatable, Hashable {
        typealias ID = UUID
        
        private(set) var id = ID()
        private(set) var attempt: Int = 0
        private(set) var maxAttempts: Int
        private(set) var delay: TimeInterval
        
        var hasMoreAttempts: Bool {
            attempt < (maxAttempts - 1)
        }
        
        func nextAttempt() -> Attempt? {
            guard hasMoreAttempts else {
                return nil
            }
            
            return Attempt(
                attempt: attempt + 1,
                maxAttempts: maxAttempts,
                delay: pow(2.0, Double(attempt + 1))
            )
        }
    }
}
