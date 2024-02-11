//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2021.
//

import XCTest
@testable import Puredux
import SwiftUI


import UIKit

class ViewWithRootStoreWithAlwaysEqualDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var rootStore: RootEnvStore = {
        RootEnvStore(
            rootStore: RootStore<TestAppState, Action>(initialState: state) { state, action in
                state.reduce(action)
            }
        )
    }()

    lazy var store: PublishingStore = {
        rootStore.store()
    }()

    @discardableResult func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store,
                removeStateDuplicates: .alwaysEqual,
                props: { (state, _) -> String in
                    propsEvaluatedExpectation.fulfill()
                    return state.subStateWithTitle.title
                },
                content: {
                    Text($0)
                }
            )
        )
    }
}

extension ViewWithRootStoreWithAlwaysEqualDeduplicationPropsTests {

    func test_WhenManyNonMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActionsAndDeduplicationAlwaysEqual_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}
 
