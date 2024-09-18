//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01/09/2024.
//

import XCTest
@testable import Puredux
import SwiftUI
import Dispatch

final class StoreViewPresentationQueueTest: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.2
    
    let store = StateStore<Int, Int>(0) { state, action in state += action }

    func test_WhenUseMainPresentationQueue_ThenPropsEvaluatedOnMainThread() {
        let expectation = expectation(description: "view rendered")

        UIWindow.setupForSwiftUITests(
            rootView:
                StoreView(
                    store,
                    props: { (state: Int, _: Dispatch<Int>) -> String in
                        XCTAssertTrue(Thread.isMainThread)
                        return "\(state)"
                    },
                    content: {
                        expectation.fulfill()
                        return Text($0)
                    }
                )
                .usePresentationQueue(.main)
        )

        store.dispatch(1)
        waitForExpectations(timeout: timeout)
    }

    func test_WhenUseSharedPresentationQueue_ThenPropsEvaluatedNotOnMainThread() {
        let expectation = expectation(description: "view rendered")

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { (state: Int, _: Dispatch<Int>) -> String in
                    XCTAssertFalse(Thread.isMainThread)
                    return "\(state)"
                },
                content: {
                    expectation.fulfill()
                    return Text($0)
                }
            )
            .usePresentationQueue(.sharedPresentationQueue)
        )

        store.dispatch(1)
        waitForExpectations(timeout: timeout)
    }

    func test_WhenUseProvidedQueue_ThenPropsEvaluatedNotOnMainThread() {
        let expectation = expectation(description: "view rendered")
        let queue = DispatchQueue(label: "global serial queue")

        UIWindow.setupForSwiftUITests(
            rootView: StoreView(
                store,
                props: { (state: Int, _: Dispatch<Int>) -> String in
                    XCTAssertFalse(Thread.isMainThread)
                    return "\(state)"
                },
                content: {
                    expectation.fulfill()
                    return Text($0)
                }
            )
            .usePresentationQueue(queue)
        )

        store.dispatch(1)
        waitForExpectations(timeout: timeout)
    }
}
