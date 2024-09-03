//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16.02.2023.
//

import XCTest
@testable import Puredux

final class ActionsOnChildStoreInterceptionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnMainStore() {
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
                handler(ResultAction(index: idx))
            }
            
        }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnChildStore() {
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
                guard let resultAction = (action as? ResultAction) else {
                    return
                }
                
                expectations[resultAction.index].fulfill()
            }
        ).map { rootState, childState in
            StateComposition(state: rootState, childState: childState)
        }

        let actions = (0..<actionsCount).map { idx in
            AsyncResultAction(index: idx) { handler in
                handler(ResultAction(index: idx))
            }
        }
        actions.forEach { childStore.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}

final class ActionsOnMainStoreInterceptionTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenActionDispatchAndIntercepted_ThenResultReducedOnMainStore() {
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
                handler(ResultAction(index: idx))
            }
        }
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }

    func test_WhenActionDispatchAndIntercepted_ThenResultNotReducedOnChildStore() {
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

        let actions = (0..<actionsCount).map { idx in
            AsyncResultAction(index: idx) { handler in
                handler(ResultAction(index: idx))
            }
        }
        
        actions.forEach { store.dispatch($0) }
        
        wait(for: unexpected, timeout: timeout, enforceOrder: true)
    }
}

final class ChildStoreInterceptOnceTests: XCTestCase {
    let timeout: TimeInterval = 10
    
    func test_WhenDispatchedToChildStore_ThenEachActionInterceptedOnce() {
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

    func test_WhenDispatchedToMainStore_ThenEachActionInterceptedOnce() {
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
        actions.forEach { store.dispatch($0) }

        wait(for: expectations, timeout: timeout, enforceOrder: true)
    }
}
