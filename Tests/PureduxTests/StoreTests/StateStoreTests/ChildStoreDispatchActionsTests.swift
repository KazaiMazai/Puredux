//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import Puredux

final class ChildStoreDispatchActionsTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenDispatchedToMainStore_ThenNotReducedOnChildStore() {
        let actionsCount = 100

        let unexpected = (0..<actionsCount).map {
            let exp = XCTestExpectation(description: "index \($0)")
            exp.isInverted = true
            return exp
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStore = store.with(
             ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                unexpected[action.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }

        actions.forEach { store.dispatch($0) }

        wait(for: unexpected, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToChildStoreA_ThenNotReducedOnChildStoreB() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }
        let unexpected = (0..<actionsCount).map {
            let exp = XCTestExpectation(description: "index \($0)")
            exp.isInverted = true
            return exp
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStoreA = store.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let childStoreB = store.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                unexpected[action.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStoreA.dispatch($0) }

        wait(for: [unexpected, expectations].flatMap { $0 }, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToChildStore_ThenReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let stateStore = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        )

        let childStore = stateStore.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToChildStore_ThenReducenOnChildStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStore = store.with(
             ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}
