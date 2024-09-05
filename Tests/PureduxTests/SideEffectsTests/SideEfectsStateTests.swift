//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/04/2024.
//

import Foundation
import XCTest
@testable import Puredux

final class CancellableSideEfectsStateTests: XCTestCase {
    let timeout: TimeInterval = 3.0
    let observer = AnyCancellableEffect()

    func test_WhenStateIsRun_EffectExecuted() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")

        store.effect(observer, on: .main) { _, _  in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(true)
        store.dispatch(false, after: 0.2)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsRunMultipleTimes_EffectExecutedOnce() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })
        let asyncExpectation = expectation(description: "Effect executed")

        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenRestartedMultiple_EffectExecutedForEveryRestart() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.restart() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        store.dispatch(true, after: 0.1)
        store.dispatch(false, after: 0.15)
        store.dispatch(true, after: 0.2)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenEffectIsSkipped_ThenEffectCreationIsCalledAgain() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.restart() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(observer, on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsInitial_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(observer, on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsIdle_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.reset() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(observer, on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsSuccess_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.succeed() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(observer, on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsFailed_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.fail(nil) })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateRetryOrFailAndHasAttempts_ThenEffectIsReExecuted() {
        let store = StateStore<Effect.State, Bool>(
            Effect.State(),
            reducer: { state, action in
                action ?
                    state.run(maxAttempts: 2)
                    : state.retryOrFailWith(nil)
            })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 2

        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateRetryOrFailAndHasNoAttempts_ThenEffectIsExecutedOnce() {
        let store = StateStore<Effect.State, Bool>(
            Effect.State(),
            reducer: { state, action in
                action ?
                    state.run(maxAttempts: 1)
                    : state.retryOrFailWith(nil)
            })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 1

        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        store.dispatch(false, after: 0.1)
        store.dispatch(false, after: 0.15)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsNotRunning_ThenEffectIsNotExecuted() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true

        store.effect(observer, on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }
}


final class SideEfectsStateTests: XCTestCase {
    let timeout: TimeInterval = 3.0
    
    func test_WhenStateIsRun_EffectExecuted() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")

        store.effect(on: .main) { _, _  in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(true)
        store.dispatch(false, after: 0.2)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsRunMultipleTimes_EffectExecutedOnce() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })
        let asyncExpectation = expectation(description: "Effect executed")

        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenRestartedMultiple_EffectExecutedForEveryRestart() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.restart() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        store.dispatch(true, after: 0.1)
        store.dispatch(false, after: 0.15)
        store.dispatch(true, after: 0.2)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenEffectIsSkipped_ThenEffectCreationIsCalledAgain() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.restart() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 3
        store.effect(on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(true)
        store.dispatch(true)
        store.dispatch(true)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsInitial_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsIdle_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.reset() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsSuccess_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.succeed() })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(on: .main) { _, _ in
            asyncExpectation.fulfill()
            return .postpone
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsFailed_ThenEffectIsNotCreated() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.fail(nil) })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.isInverted = true

        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateRetryOrFailAndHasAttempts_ThenEffectIsReExecuted() {
        let store = StateStore<Effect.State, Bool>(
            Effect.State(),
            reducer: { state, action in
                action ?
                    state.run(maxAttempts: 2)
                    : state.retryOrFailWith(nil)
            })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 2

        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateRetryOrFailAndHasNoAttempts_ThenEffectIsExecutedOnce() {
        let store = StateStore<Effect.State, Bool>(
            Effect.State(),
            reducer: { state, action in
                action ?
                    state.run(maxAttempts: 1)
                    : state.retryOrFailWith(nil)
            })

        let asyncExpectation = expectation(description: "Effect creation executed")
        asyncExpectation.expectedFulfillmentCount = 1

        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(true)
        store.dispatch(false, after: 0.05)
        store.dispatch(false, after: 0.1)
        store.dispatch(false, after: 0.15)

        waitForExpectations(timeout: timeout) { _ in

        }
    }

    func test_WhenStateIsNotRunning_ThenEffectIsNotExecuted() {
        let store = StateStore<Effect.State, Bool>(Effect.State(),
                                                   reducer: { state, action in action ? state.run() : state.cancel() })

        let asyncExpectation = expectation(description: "Effect executed")
        asyncExpectation.isInverted = true

        store.effect(on: .main) { _, _ in
            Effect {
                asyncExpectation.fulfill()
            }
        }

        store.dispatch(false)
        store.dispatch(false)
        store.dispatch(false)

        waitForExpectations(timeout: timeout) { _ in

        }
    }
}
