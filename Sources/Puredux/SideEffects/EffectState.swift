//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

public extension Effect {
    struct State: Codable, Equatable, Hashable {
        typealias ID = UUID
        
        private(set) var id = ID()
        private var state = InternalState()
    }
}

public extension Effect.State {
    static func running(maxAttempts: Int = 1,
                        delay: TimeInterval = .zero) -> Effect.State {

        var effect = Effect.State()
        effect.run(maxAttempts: maxAttempts, delay: delay)
        return effect
    }

    static func idle() -> Effect.State {
        Effect.State()
    }
}

public extension Effect.State {
    enum Status: Int {
        case idle
        case inProgress
        case success
        case failure
        case cancelled
    }
    
    var status: Status {
        state.status
    }
}

public extension Effect.State {
    var isInProgress: Bool {
        status.isInProgress
    }
    
    var isSuccess: Bool {
        status.isSuccess
    }
    
    var isCancelled: Bool {
        status.isCancelled
    }
    
    var isIdle: Bool {
        status.isIdle
    }
    
    var isFailed: Bool {
        status.isFailed
    }
    
    var error: Error? {
        state.error
    }
    
    var currentAttempt: Int? {
        state.currentAttempt?.attempt
    }
    
    var delay: TimeInterval? {
        state.currentAttempt?.delay
    }
    
}

public extension Effect.State {

    mutating func run(maxAttempts: Int = 1,
                      delay: TimeInterval = .zero) {

        state.run(maxAttempts: maxAttempts, delay: delay)
    }

    mutating func restart(maxAttempts: Int = 1,
                          delay: TimeInterval = .zero) {

        state.restart(maxAttempts: maxAttempts, delay: delay)
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

    mutating func fail(_ error: Error?) {
        state.fail(error)
    }
}

extension Effect.State.Status {
    var isInProgress: Bool {
        self == .inProgress
    }

    var isSuccess: Bool {
        self == .success
    }

    var isCancelled: Bool {
        self == .cancelled
    }

    var isIdle: Bool {
        self == .idle
    }

    var isFailed: Bool {
        self == .failure
    }
}


extension Effect.State {
    enum InternalState: Codable, Equatable, Hashable {
        case idle
        case inProgress(Attempt)
        case success
        case failure(Failure)
        case cancelled

        init() {
            self = .idle
        }
    }
}

extension Effect.State.InternalState {
    var status: Effect.State.Status {
        switch self {
        case .idle:
            return .idle
        case .inProgress:
            return .inProgress
        case .success:
            return .success
        case .failure:
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

extension Effect.State.InternalState {
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
        self = .idle
    }
}

extension Effect.State.InternalState {

    func nextAttemptOrFailWith(_ error: Error) -> Effect.State.InternalState {
        guard let attempt = currentAttempt,
              let next = attempt.nextAttempt()
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
