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


class ViewEnvRootStoreWithoutDeduplicationPropsTests: ViewWithRootStoreWithoutDeduplicationPropsTests {
    @discardableResult override func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(rootStore: rootStore) {
                Text.withEnvStore(
                    removeStateDuplicates: .neverEqual,
                    props: { (state: TestAppState, _: PublishingStore<TestAppState, Action>) -> String in
                        propsEvaluatedExpectation.fulfill()
                        return state.subStateWithTitle.title
                    },
                    content: {
                        Text($0)
                    }
                )
            }
        )
    }
}


class ViewWithRootStoreWithoutDeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1
    
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
                removeStateDuplicates: .neverEqual,
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


extension ViewWithRootStoreWithoutDeduplicationPropsTests {

    func test_WhenNoActionAfterSetup_ThenPropsNotEvaluated() {
        let expectation = expectation(description: "propsEvaluated")
        expectation.isInverted = true

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyNonMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { idx in
            store.dispatch(NonMutatingStateAction(), after: actionDelay * Double(idx))
        }

        waitForExpectations(timeout: 2 * (actionDelay * Double(actionsCount)))
    }

    func test_WhenManyMutatingActionsAndDeduplicateNeverEqual_ThenPropsEvaluatedForEveryAction() {
        let actionsCount = 10
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }
}

