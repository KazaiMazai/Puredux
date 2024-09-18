//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01/09/2024.
//

import XCTest
@testable import Puredux
import SwiftUI
import Dispatch

final class StoreViewDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.2
    
    let store = StateStore<Int, Int>(0) { state, action in state += action }

    @discardableResult func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { (state: Int, _: Dispatch<Int>) -> String in
                    propsEvaluatedExpectation.fulfill()
                    return "\(state)"
                },
                content: {
                    Text($0)
                }
            )
            .removeStateDuplicates(.equal { $0 })
        )
    }
}

extension StoreViewDeduplicationPropsTests {
    func test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: 3 * actionDelay * Double(actionsCount))
    }

    func test_WhenManyMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: Double(idx) * actionDelay)
        }

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: Double(idx) * actionDelay)
        }

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: timeout)
    }
}
