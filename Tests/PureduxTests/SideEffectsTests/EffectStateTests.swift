//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/04/2024.
//

import Foundation

import XCTest
@testable import Puredux

final class EfectsStateTests: XCTestCase {
    struct DummyError: Equatable, LocalizedError {
        let message: String

        var errorDescription: String? {
            message
        }
    }

    func test_WhenMutated_ThenStateChanges() {
        var effect = Effect.State()
        XCTAssertTrue(effect.isIdle)

        effect.run()
        XCTAssertTrue(effect.isInProgress)

        effect.cancel()
        XCTAssertTrue(effect.isCancelled)

        effect.restart(maxAttempts: 2)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertTrue(effect.isInProgress)

        effect.fail(nil)
        XCTAssertTrue(effect.isFailed)

        effect.run()
        XCTAssertTrue(effect.isInProgress)

        effect.succeed()
        XCTAssertTrue(effect.isSuccess)

        effect.reset()
        XCTAssertTrue(effect.isIdle)
    }

    func test_WhenRunTwice_ThenNotMutated() {
        var effect = Effect.State()
        effect.run()

        let effectCopy = effect
        effect.run()

        XCTAssertEqual(effect, effectCopy)
    }

    func test_WhenRestared_ThenMutated() {
        var effect = Effect.State()
        effect.run()
        let effectCopy = effect
        effect.restart()

        XCTAssertNotEqual(effect, effectCopy)
    }

    func test_WhenFailed_ThenErrorLocalizedDescription() {
        var effect = Effect.State()
        let error = DummyError(message: "something happened")
        effect.fail(error)

        XCTAssertEqual(effect.error?.localizedDescription, "something happened")
    }

    func test_WhenFailedWithUnknownError_ThenErrorLocalizedDescription() {
        var effect = Effect.State()
        effect.fail(nil)

        XCTAssertEqual(effect.error?.localizedDescription, "Unknown effect execution error")
    }

    func test_WhenHasNewAttempts_ThenRestartThenFail() {
        var effect = Effect.State()
        effect.run(maxAttempts: 5)

        XCTAssertEqual(effect.currentAttempt, 0)
        XCTAssertEqual(effect.delay, .zero)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertNil(effect.error)
        XCTAssertEqual(effect.currentAttempt, 1)
        XCTAssertEqual(effect.delay, 2)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertNil(effect.error)
        XCTAssertEqual(effect.currentAttempt, 2)
        XCTAssertEqual(effect.delay, 4)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertNil(effect.error)
        XCTAssertEqual(effect.currentAttempt, 3)
        XCTAssertEqual(effect.delay, 8)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertNil(effect.error)
        XCTAssertEqual(effect.currentAttempt, 4)
        XCTAssertEqual(effect.delay, 16)
        XCTAssertTrue(effect.isInProgress)

        effect.retryOrFailWith(nil)
        XCTAssertNotNil(effect.error)
        XCTAssertEqual(effect.currentAttempt, nil)
        XCTAssertTrue(effect.isFailed)

    }
}
