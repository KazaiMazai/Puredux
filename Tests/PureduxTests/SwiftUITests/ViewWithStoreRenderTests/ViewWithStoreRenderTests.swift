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


class ViewWithStoreRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var factory: EnvStoreFactory = {
        EnvStoreFactory(
            storeFactory: StoreFactory<TestAppState, Action>(
                initialState: state,
                reducer: { state, action in state.reduce(action) }
            )
        )
    }()

    lazy var store: PublishingStore = {
        factory.rootStore()
    }()

    @discardableResult func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in

                        state.subStateWithTitle.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    }
                )
            }
        )
    }
}


extension ViewWithStoreRenderTests {

    func test_WhenNoActionDispatched_ThenViewIsNotRendered() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.isInverted = true

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenOneActionDispatched_ThenViewRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1
        setupWindowForTests(contentRenderedExpectation: contentRendered)

        store.dispatch(NonMutatingStateAction())

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce() {
        let actionsCount = 100
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyActionsDispatchedAndPropsChanged_ThenViewRenderedEveryTime() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = actionsCount

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach {
            let delay = actionDelay * Double($0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.store.dispatch(UpdateTitle(title: "\(delay)"))
            }
        }

        waitForExpectations(timeout: max(actionDelay * Double(actionsCount) * 4, 10))
    }

    func test_WhenManyActionsDispatchedPropsNotChanged_ThenViewRenderedOnce() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach {
            let delay = actionDelay * Double($0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.store.dispatch(NonMutatingStateAction())
            }
        }

        waitForExpectations(timeout: actionDelay * Double(actionsCount) * 4)
    }
}

