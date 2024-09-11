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

final class StoreViewAlwaysEqualDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    let store = StateStore<Int, Int>(0) { state, action in state += action }

    func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation)  {

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
                .removeStateDuplicates(.alwaysEqual)
        )
    }
}

extension StoreViewAlwaysEqualDeduplicationPropsTests {

    func test_WhenManyNonMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: timeout)
    }
}
