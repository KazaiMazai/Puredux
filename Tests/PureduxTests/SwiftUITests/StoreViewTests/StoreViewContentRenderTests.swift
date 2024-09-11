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

final class StoreViewContentRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    let store = StateStore<Int, Int>(0) { state, action in state += action }

    @discardableResult func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { state, _ -> String in
                    "\(state)"
                },
                content: {
                    contentRenderedExpectation.fulfill()
                    return Text($0)
                }
            )
        )
    }
}

extension StoreViewContentRenderTests {

    func test_WhenViewInitiallySetup_ThenViewIsRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenOneActionDispatched_ThenViewRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1
        setupWindowForTests(contentRenderedExpectation: contentRendered)

        store.dispatch(0)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce() {
        let actionsCount = 100
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach { _ in
            store.dispatch(0)
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyActionsDispatchedAndPropsChanged_ThenViewRenderedEveryTime() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = actionsCount

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach { idx in
            store.dispatch(idx, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: max(actionDelay * Double(actionsCount) * 4, 10))
    }

    func test_WhenManyActionsDispatchedPropsNotChanged_ThenViewRenderedOnce() {
        let actionsCount = 10
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach { idx in
            store.dispatch(0, after: Double(idx) * actionDelay)
        }

        waitForExpectations(timeout: actionDelay * Double(actionsCount) * 4)
    }
}

final class StoreViewContentInitialRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    func test_WhenViewInitiallySetupWithRootStore_ThenViewIsRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1
        let store = StateStore<Int, Int>(0) { state, action in state += action }

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { state, _ -> String in
                    "\(state)"
                },
                content: {
                    contentRendered.fulfill()
                    return Text($0)
                }
            )
        )

        waitForExpectations(timeout: timeout)
    }

    func test_WhenViewInitiallySetupWithChildStore_ThenViewIsRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1
        let store = StateStore<Int, Int>(0) { state, action in state += action }
            .with("text") {_, _ in }

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { state, _ -> String in
                    "\(state)"
                },
                content: {
                    contentRendered.fulfill()
                    return Text($0)
                }
            )
        )

        waitForExpectations(timeout: timeout)
    }

    func test_WhenViewInitiallySetup_ThenViewIsRenderedOnce() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1
        let store = StateStore<Int, Int>(0) { state, action in state += action }
            .with("text") {_, _ in }
            .map { $0.0 }

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { state, _ -> String in
                    "\(state)"
                },
                content: {
                    contentRendered.fulfill()
                    return Text($0)
                }
            )
        )

        waitForExpectations(timeout: timeout)
    }
}
