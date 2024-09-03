//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26/08/2024.
//

import Foundation

import XCTest
@testable import Puredux

final class ActionsOnChildStoreAsyncActionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenAsyncActionDispatchOnChildStore_ThenResultReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                expectations[resultAction.index].fulfill()
            }
        )

        let childStore = factory.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { AsyncIndexAction(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenAsyncActionDispatchOnChild_ThenResultReducedOnChildStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let factory = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        )

        let childStore = factory.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }
                
                expectations[resultAction.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { AsyncIndexAction(index: $0) }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}

final class ActionsOnMainStoreAsyncActionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenAsyncActionDispatchOnStateStore_ThenResultReducedOnMainStore() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
             TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }

                expectations[resultAction.index].fulfill()
            }
        )

        let childStore = store.with(
             ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { AsyncIndexAction(index: $0) }
        
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenAsyncActionDispatchOnStateStore_ThenResultNotReducedOnChildStore() {
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
                guard let resultAction = (action as? ResultAction) else {
                    return
                }
                
                unexpected[resultAction.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { AsyncIndexAction(index: $0) }
       
        actions.forEach { store.dispatch($0) }

        wait(for: unexpected, timeout: timeout, enforceOrder: true)
    }
}

final class ChildStoreAsyncActionOnceTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenAsyncActionDispatchedToChildStore_ThenEachActionResultDispatchedOnce() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
            TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }
                
                expectations[resultAction.index].fulfill()
            }
        )

        let childStore = store.with(
             ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { idx in
            AsyncResultAction(index: idx) { handler in
                expectations[idx].fulfill()
                handler(ResultAction(index: idx))
            }
        }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenAsyncActionDispatchedToMainStore_ThenEachActionResultDispatchedOnce() {
        let actionsCount = 100
        let expectations = (0..<actionsCount).map {
            XCTestExpectation(description: "index \($0)")
        }

        let store = StateStore<TestState, Action>(
            TestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
                guard let resultAction = (action as? ResultAction) else {
                    return
                }
                
                expectations[resultAction.index].fulfill()
            }
        )

        let childStore = store.with(
            ChildTestState(currentIndex: 0),
            reducer: { state, action  in
                state.reduce(action: action)
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { AsyncIndexAction(index: $0) }
     
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}
