//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2023.
//

import XCTest
@testable import Puredux
import SwiftUI
import UIKit

@available(iOS 13.0, *)
class DeduplicationPropsTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: EnvStoreFactory = {
        EnvStoreFactory(
            storeFactory: StoreFactory<TestAppState, Action>(
                initialState: state,
                reducer: { state, action in
                    state.reduce(action)
                })
        )
    }()

    lazy var store: PublishingStore = {
        factory.rootStore()
    }()

    @discardableResult func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return state.subStateWithTitle.title
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.equal { $0.subStateWithIndex.index })
            }
        )
    }
}

@available(iOS 13.0, *)
extension DeduplicationPropsTests {
    func test_WhenManyNonMutatingActions_ThenPropsEvaluatedOnce() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = 1

        setupWindowForTests(propsEvaluatedExpectation: expectation, rootStore: store)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation, rootStore: store)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenMutatingAndNonMutatingActions_ThenPropsEvaluatedForEveryDeduplicatedMutation() {
        let actionsCount = 1000
        let expectation = expectation(description: "propsEvaluated")
        expectation.expectedFulfillmentCount = actionsCount

        setupWindowForTests(propsEvaluatedExpectation: expectation, rootStore: store)

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

        setupWindowForTests(propsEvaluatedExpectation: expectation, rootStore: store)

        (0..<actionsCount).forEach {
            store.dispatch(UpdateIndex(index: $0))
        }

        (0..<actionsCount).forEach {
            store.dispatch(UpdateTitle(title: "\($0)"))
        }

        waitForExpectations(timeout: timeout)
    }
}
