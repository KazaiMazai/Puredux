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

class ViewEnvRootStoreDeduplicationTests: ViewWithRootStoreDeduplicationTests {
    @discardableResult override func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(rootStore: rootStore) {
                Text.withEnvStore(
                    removeStateDuplicates: .equal { $0.subStateWithIndex.index },
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

class ViewWithRootStoreDeduplicationTests: XCTestCase {
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

    @discardableResult func setupWindowForTests(
        propsEvaluatedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store,
                removeStateDuplicates: .equal { $0.subStateWithIndex.index },
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

extension ViewWithRootStoreDeduplicationTests {

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
 
