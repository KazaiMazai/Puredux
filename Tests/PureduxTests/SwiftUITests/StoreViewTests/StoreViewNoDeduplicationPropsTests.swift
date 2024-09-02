//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01/09/2024.
//

import XCTest
@testable import Puredux
import SwiftUI
import UIKit
import Dispatch

final class StoreViewNoDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.2
    @StoreOf(\.rootStore) var store
      
    @discardableResult func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { (state: Int, dispatch: Dispatch<Int>) -> String in
                    propsEvaluatedExpectation.fulfill()
                    return "\(state)"
                },
                content: {
                    Text($0)
                }
            )
            .removeStateDuplicates(.neverEqual)
        )
    }
}

extension StoreViewNoDeduplicationPropsTests {

    func test_WhenNoActionAfterSetup_ThenPropsEvaluatedOnce() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: (Double(idx) * actionDelay))
        }

        waitForExpectations(timeout: 2 * (Double(actionsCount) * actionDelay))
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenEvaluatedForEveryAction() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount
        
        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: (Double(idx) * actionDelay))
        }

        waitForExpectations(timeout: 2 * (Double(actionsCount) * actionDelay))
    }
}
