//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import PureduxStore

final class ChildStoreDispatchActionsTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenDispatchedToMainStore_ThenNotReducedOnChildStore() {
        let actionsCount = 100

        let unexpected = (0..<actionsCount).map {
            let exp = XCTestExpectation(description: "index \($0)")
            exp.isInverted = true
            return exp
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStore = factory.childStore(
            initialState: ChildTestState(currentIndex: 0),
            stateMapping: { rootState, childState in
                StateComposition(state: rootState, childState: childState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                unexpected[action.index].fulfill()
            }
        )

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        let store = factory.rootStore()
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

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStoreA = factory.childStore(
            initialState: ChildTestState(currentIndex: 0),
            stateMapping: { rootState, childState in
                StateComposition(state: rootState, childState: childState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        )

        let childStoreB = factory.childStore(
            initialState: ChildTestState(currentIndex: 0),
            stateMapping: { rootState, childState in
                StateComposition(state: rootState, childState: childState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                unexpected[action.index].fulfill()
            }
        )

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStoreA.dispatch($0) }

        wait(for: [unexpected, expectations].flatMap { $0 }, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToChildStore_ThenReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        )

        let childStore = factory.childStore(
            initialState: ChildTestState(currentIndex: 0),
            stateMapping: { rootState, childState in
                StateComposition(state: rootState, childState: childState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenDispatchedToChildStore_ThenReducenOnChildStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StoreFactory<TestState, Action>(
            initialState: TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStore = factory.childStore(
            initialState: ChildTestState(currentIndex: 0),
            stateMapping: { rootState, childState in
                StateComposition(state: rootState, childState: childState)
            },
            reducer: { state, action  in
                state.reduce(action: action)
                guard let action = (action as? UpdateIndex) else {
                    return
                }

                expectations[action.index].fulfill()
            }
        )

        let actions = (0..<actionsCount).map { UpdateIndex(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}
