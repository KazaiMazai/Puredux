//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

struct Effect {
    typealias Operation = () -> Void

    private let perform: Operation?

    var operation: Operation {
        perform ?? { }
    }

    var canBeExecuted: Bool {
        perform != nil
    }

    init(_ operation: @escaping () -> Void) {
        perform = operation
    }

    private init(operation: Operation?) {
        perform = operation
    }

    init(operation: @escaping () async -> Void) {
        perform = {
            Task { await operation() }
        }
    }

    static let skip: Effect = Effect(operation: nil)
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
}

extension Effect.State {
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

extension Effect.State {

    enum Status: Int {
        case none
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
        self == .none
    }

    var isFailed: Bool {
        self == .failure
    }
}

extension Effect.State {

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
