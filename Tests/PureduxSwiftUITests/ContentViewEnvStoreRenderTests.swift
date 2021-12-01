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
import UIKit

final class ContentViewEnvStoreRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var store: ObservableStore<TestAppState, Action> = {
        ObservableStore(
            store: Store<TestAppState, Action>(initial: state) { state, action in
                state.reduce(action)
            }
        )
    }()

    @discardableResult func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {
        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(store: store) {
                Text.with(
                    props: { (state: TestAppState, store: ObservableStore<TestAppState, Action>) in
                        state.subStateWithTitle.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    })
            }
        )
    }

    func test_WhenNoActionDispatchedAfterSetup_ThenContentIsNotRendered() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.isInverted = true

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenOneActionDispatchedAfterSetup_ThenContentRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")

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

    func test_WhenManyActionsDispatchedWithDelayAndPropsChanged_ThenViewRenderedEveryTime() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = actionsCount

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach {
            let delay = actionDelay * Double($0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak store] in
                store?.dispatch(UpdateTitle(title: "\(delay)"))
            }
        }

        waitForExpectations(timeout: actionDelay * Double(actionsCount) * 4)
    }

    func test_WhenManyActionsDispatchedWithDelayAndPropsNotChanged_ThenViewRenderedOnce() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach {
            let delay = actionDelay * Double($0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak store] in
                store?.dispatch(NonMutatingStateAction())
            }
        }

        waitForExpectations(timeout:  actionDelay * Double(actionsCount) * 4)
    }

    static var allTests = [
        ("test_WhenNoActionDispatchedAfterSetup_ThenContentIsNotRendered",
         test_WhenNoActionDispatchedAfterSetup_ThenContentIsNotRendered),

        ("test_WhenOneActionDispatchedAfterSetup_ThenContentRenderedOnce",
         test_WhenOneActionDispatchedAfterSetup_ThenContentRenderedOnce),

        ("test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce",
         test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce),

        ("test_WhenManyActionsDispatchedWithDelayAndPropsChanged_ThenViewRenderedEveryTime",
         test_WhenManyActionsDispatchedWithDelayAndPropsChanged_ThenViewRenderedEveryTime),

        ("test_WhenManyActionsDispatchedWithDelayAndPropsNotChanged_ThenViewRenderedOnce",
         test_WhenManyActionsDispatchedWithDelayAndPropsNotChanged_ThenViewRenderedOnce)
    ]
}


