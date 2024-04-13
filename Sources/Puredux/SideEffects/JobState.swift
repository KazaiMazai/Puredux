//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

extension Job {
    enum State: Codable & Equatable {
        case none
        case inProgress(Attempt)
        case success
        case failure(Failure)
        case cancelled
        
        init() {
            self = .none
        }
        
        init(_ error: Error) {
            self = .failure(Failure(error))
        }
    }
}

extension Job.State {
    var status: Job.Status {
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
    
    var isInProgress: Bool {
        currentAttempt != nil
    }
    
    var isSuccess: Bool {
        self == .success
    }
    
    var isCancelled: Bool {
        self == .cancelled
    }
    
    var isIdle: Bool {
        self == .none
    }
    
    var isFailed: Bool {
        guard case .failure = self else {
            return false
        }
        
        return true
    }
    
    var error: Error? {
        guard case .failure(let jobError) = self else {
            return nil
        }
        
        return jobError.underlyingError
    }
    
    var currentAttempt: Attempt? {
        guard case let .inProgress(attempt) = self else {
            return nil
        }
        
        return attempt
    }
}

extension Job.State {
    struct Failure: Codable, Equatable, Error {
        let descriptionString: String
        private(set) var underlyingError: Error?
        
        private enum CodingKeys: String, CodingKey {
            case descriptionString
        }
        
        var localizedDescription: String {
            descriptionString
        }
        
        init(_ error: Error) {
            self.descriptionString = error.localizedDescription
            self.underlyingError = error
        }
        
        static func == (lhs: Failure, rhs: Failure) -> Bool {
            lhs.descriptionString == rhs.descriptionString
        }
    }
    
    enum Errors: Error {
        case unknownError
    }
}

extension Job.State  {
    mutating func run(maxAttemptCount: Int,
                      delay: TimeInterval) {
        
        guard !isInProgress else {
            return
        }
        
        self = .inProgress(
            Attempt(
                maxAttemptCount: maxAttemptCount,
                delay: delay
            )
        )
    }
    
    mutating func restart(maxAttemptCount: Int,
                          delay: TimeInterval) {
        
        self = .inProgress(
            Attempt(
                maxAttemptCount: maxAttemptCount,
                delay: delay
            )
        )
    }
    
    mutating func retryOrFailWith(_ error: Error?) {
        self = nextAttemptOrFailWith(error ?? Errors.unknownError)
    }
    
    mutating func fail(_ error: Error?) {
       self = .failure(Failure(error ?? Errors.unknownError))
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

extension Job.State {
    
    func nextAttemptOrFailWith(_ error: Error) -> Job.State {
        guard let job = currentAttempt,
              let next = job.nextAttempt()
        else {
            return .failure(Failure(error))
        }
        
        return .inProgress(next)
    }
}

extension Job.State {
    
    struct Attempt: Codable & Equatable {
        private(set) var id: UUID = UUID()
        private(set) var attempt: Int = 0
        private(set) var maxAttemptCount: Int = 1
        private(set) var delay: TimeInterval = .zero
        
        var hasMoreAttempts: Bool {
            attempt < (maxAttemptCount - 1)
        }
        
        func nextAttempt() -> Attempt? {
            guard hasMoreAttempts else {
                return nil
            }
            
            return Attempt(
                id: UUID(),
                attempt: attempt + 1,
                maxAttemptCount: maxAttemptCount,
                delay: pow(2.0, Double(attempt + 1))
            )
        }
    }
}
