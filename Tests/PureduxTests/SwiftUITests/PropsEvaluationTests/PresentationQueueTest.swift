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
class PresentationQueueTest: XCTestCase {
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

    func test_WhenUseMainPresentationQueue_ThenPropsEvaluatedOnMainThread() {
        let expectation = expectation(description: "view rendered")

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in
                        XCTAssertTrue(Thread.isMainThread)
                        return state.subStateWithTitle.title
                    },
                    content: {
                        expectation.fulfill()
                        return Text($0)
                    }
                )
                .usePresentationQueue(.main)
            }
        )

        store.dispatch(UpdateIndex(index: 1))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenUseSharedPresentationQueue_ThenPropsEvaluatedNotOnMainThread() {
        let expectation = expectation(description: "view rendered")

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in
                        XCTAssertFalse(Thread.isMainThread)
                        return state.subStateWithTitle.title
                    },
                    content: {
                        expectation.fulfill()
                        return Text($0)
                    }
                )
                .usePresentationQueue(.sharedPresentationQueue)
            }
        )

        store.dispatch(UpdateIndex(index: 1))

        waitForExpectations(timeout: timeout)
    }

    func test_WhenUseProvidedQueue_ThenPropsEvaluatedNotOnMainThread() {
        let expectation = expectation(description: "view rendered")
        let queue = DispatchQueue(label: "global serial queue")

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in
                        XCTAssertFalse(Thread.isMainThread)
                        return state.subStateWithTitle.title
                    },
                    content: {
                        expectation.fulfill()
                        return Text($0)
                    }
                )
                .usePresentationQueue(.serialQueue(queue))
            }
        )

        store.dispatch(UpdateIndex(index: 1))

        waitForExpectations(timeout: timeout)
    }
}
