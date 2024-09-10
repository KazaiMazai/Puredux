//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

public extension Effect {
    /**
        A struct representing the state of the `Effect`.
        
        This `State` struct conforms to `Codable`, `Equatable`, and `Hashable` protocols,
        allowing it to be encoded, compared, and used as a hashable value. The state
        contains a unique identifier and an internal state representation.
    */
    struct State: Codable, Equatable, Hashable {
        /**A typealias for a universally unique identifier (`UUID`). */
        typealias ID = UUID

        /**The unique identifier for the `State` instance. */
        private(set) var id = ID()

         /**    The internal state of the `Effect`. */
        private var state = InternalState()
    }
}

public extension Effect.State {
    /**
     Creates a new `Effect.State` instance in the running state.
     
     - Parameters:
        - maxAttempts: The maximum number of attempts for the effect to run. Defaults to 1.
        - delay: The delay between each attempt. Defaults to `.zero`.
     
     - Returns: A new `Effect.State` instance configured to run with the specified parameters.
    */
    static func running(maxAttempts: Int = 1,
                        delay: TimeInterval = .zero) -> Effect.State {

        var effect = Effect.State()
        effect.run(maxAttempts: maxAttempts, delay: delay)
        return effect
    }

    /**
     Creates a new `Effect.State` instance in the idle state.
     
     - Returns: A new `Effect.State` instance in an idle state.
    */

    static func idle() -> Effect.State {
        Effect.State()
    }
}

// MARK: - State Extensions

public extension Effect.State {
    /**
     A property indicating whether the effect is currently in progress.
     
     - Returns: `true` if the effect is in progress, `false` otherwise.
    */
    var isInProgress: Bool {
        status.isInProgress
    }

    /**
     A property indicating whether the effect has completed successfully.
     
     - Returns: `true` if the effect is successful, `false` otherwise.
    */
    var isSuccess: Bool {
        status.isSuccess
    }

    /**
     A property indicating whether the effect has been cancelled.
     
     - Returns: `true` if the effect is cancelled, `false` otherwise.
    */
    var isCancelled: Bool {
        status.isCancelled
    }

    /**
     A property indicating whether the effect is idle.
     
     - Returns: `true` if the effect is idle, `false` otherwise.
    */
    var isIdle: Bool {
        status.isIdle
    }

    /**
     A property indicating whether the effect has failed.
     
     - Returns: `true` if the effect has failed, `false` otherwise.
    */
    var isFailed: Bool {
        status.isFailed
    }

    /**
     A property returning the associated error  in case effect has failed.
     
     - Returns: An optional `Error` if an error exists, `nil` otherwise.
    */
    var error: Error? {
        state.error
    }

    /**
     A property returning the current attempt number of the effect if it is in progress.
     
     - Returns: An optional `Int` representing the current attempt, or `nil` if unavailable.
    */
    var currentAttempt: Int? {
        state.currentAttempt?.attempt
    }

    /**
     A property returning the delay for the current attempt of the effect  if it is in progress.
     
     - Returns: An optional `TimeInterval` representing the delay, or `nil` if unavailable.
    */
    var delay: TimeInterval? {
        state.currentAttempt?.delay
    }

    /**
     A property representing the current status of the effect.
     
     - Returns: The current status as a `Status` enum value.
    */
    var status: Status {
        state.status
    }
}

// MARK: - State Mutations

public extension Effect.State {

    /**
     Begins running the effect with a specified number of attempts and delay before the first attempt.
     
     - Parameters:
        - maxAttempts: The maximum number of times to attempt running the effect. Defaults to 1.
        - delay: The time interval to wait before the first attempt. Defaults to `.zero`.
    */
    mutating func run(maxAttempts: Int = 1,
                      delay: TimeInterval = .zero) {
        state.run(maxAttempts: maxAttempts, delay: delay)
    }

    /**
     Restarts the effect with a specified number of attempts and delay before the first attempt.
     
     - Parameters:
        - maxAttempts: The maximum number of times to attempt running the effect. Defaults to 1.
        - delay: The time interval to wait before the first attempt. Defaults to `.zero`.
    */
    mutating func restart(maxAttempts: Int = 1,
                          delay: TimeInterval = .zero) {
        state.restart(maxAttempts: maxAttempts, delay: delay)
    }

    /**
     Attempts to retry the effect if the `maxAttempts` limit has not been reached,
     or fails it with the provided error.
     
     - Parameters:
        - error: An optional `Error` to associate with the failure if the retry fails.
    */
    mutating func retryOrFailWith(_ error: Error?) {
        state.retryOrFailWith(error)
    }

    /**
     Cancels the effect.
    */
    mutating func cancel() {
        state.cancel()
    }

    /**
     Marks the effect as successfully completed.
    */
    mutating func succeed() {
        state.succeed()
    }

    /**
     Resets the effect to its initial state.
    */
    mutating func reset() {
        state.reset()
    }

    /**
     Marks the effect as failed with the provided error.
     
     - Parameters:
        - error: An optional `Error` representing the cause of the failure.
    */
    mutating func fail(_ error: Error?) {
        state.fail(error)
    }
}

// MARK: - Status

public extension Effect.State {
    /**
     An enum representing the current status of the `Effect`.
     
     The possible statuses are:
     - `idle`: The effect is idle and has not yet started.
     - `inProgress`: The effect is currently running.
     - `success`: The effect has completed successfully.
     - `failure`: The effect has failed.
     - `cancelled`: The effect has been cancelled.
    */
    enum Status: Int {
        case idle
        case inProgress
        case success
        case failure
        case cancelled
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

// MARK: - Internals

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
              let next = attempt.nextAttemptWithDelay()
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
            attempt < lastAttempt
        }

        private var lastAttempt: Int {
            maxAttempts - 1
        }

        func nextAttemptWithDelay() -> Attempt? {
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
