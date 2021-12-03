//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2021.
//

import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import PureduxCommon
import UIKit

class ViewEnvStoreDeduplicationTests: ViewWithStoreDeduplicationTests {
    @discardableResult override func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(store: store) {
                Text.with(
                    removeStateDuplicates: .equal { $0.subStateWithIndex.index },
                    props: { (state: TestAppState, store: AnyPublishingStore<TestAppState, Action>) -> String in
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

class ViewWithStoreDeduplicationTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var store: RootEnvStore = {
        RootEnvStore(
            store: Store<TestAppState, Action>(initial: state) { state, action in
                state.reduce(action)
            }
        )
    }()

    @discardableResult func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store.eraseToAnyStore(),
                removeStateDuplicates: .equal { $0.subStateWithIndex.index },
                props: { (state, store) -> String in
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

extension ViewWithStoreDeduplicationTests {
    
    func test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach {
            store.dispatch(UpdateTitle(title: "\($0)"))
        }

        waitForExpectations(timeout: timeout)
    }
}

extension ViewWithStoreDeduplicationTests {
    
    static var allTests = [
        ("test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce",
         test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce),

        ("test_WhenManyMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation",
         test_WhenManyMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation),

        ("test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation",
         test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation),

        ("test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation",
         test_WhenSpecificSubStateMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation),
    ]
}
