//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import UIKit
import XCTest
@testable import PureduxUIKit
import PureduxStore

final class ViewControllerTests: XCTestCase {
    let timeout: TimeInterval = 10

    func test_WhenVCSubscribedToStore_InitialStateDelivered() {
        let initialTitle = "hello"
        let state = TestVCState(title: initialTitle)

        let rootStore = RootStore<TestVCState, Action>(initialState: state) { state, action in
            state.reduce(action)
        }

        let store = rootStore.store()

        let didSetProps = expectation(description: "didSetProps")
        let didMakeProps = expectation(description: "didMakeProps")

        let vc = StubViewController()
        vc.didSetProps = {
            didSetProps.fulfill()
        }

        vc.with(store: store,
                props: { state, store in
                    didMakeProps.fulfill()
                    return .init(title: state.title)
                })
        vc.viewDidLoad()

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(vc.props?.title, initialTitle)
        }
    }

    func test_WhenVCConnectedToProxyStore_InitialStateDelivered() {
        let initialTitle = "hello"
        let state = TestAppState(vcState: TestVCState(title: initialTitle))

        let rootStore = RootStore<TestAppState, Action>(initialState: state) { state, action in
            state.reduce(action)
        }
        let store = rootStore.store()

        let didSetProps = expectation(description: "didSetProps")
        let didMakeProps = expectation(description: "didMakeProps")

        let vc = StubViewController()
        vc.didSetProps = {
            didSetProps.fulfill()
        }

        vc.with(store: store.proxy { $0.vcState },
                props: { state, store in
                    didMakeProps.fulfill()
                    return .init(title: state.title)
                })

        vc.viewDidLoad()

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertEqual(vc.props?.title, initialTitle)
        }
    }

    func test_WhenVCConnectedToStoreAndActionDispatched_StateChangesDelivered() {
        let initialTitle = "hello"
        let state = TestVCState(title: initialTitle)

        let rootStore = RootStore<TestVCState, Action>(initialState: state) { state, action in
            state.reduce(action)
        }
        let store = rootStore.store()

        let didSetProps = expectation(description: "didSetProps")
        let didMakeProps = expectation(description: "didMakeProps")

        didSetProps.expectedFulfillmentCount = 2
        didMakeProps.expectedFulfillmentCount = 2

        let vc = StubViewController()
        vc.didSetProps = {
            didSetProps.fulfill()
        }

        vc.with(store: store,
                props: { state, store in
                    didMakeProps.fulfill()
                    return .init(title: state.title)
                })
        vc.viewDidLoad()

        let action = TestAction(title: "Hello World")
        store.dispatch(action)

        waitForExpectations(timeout: timeout) {_ in
            XCTAssertEqual(vc.props?.title, action.title)
        }
    }

    func test_WhenVCConnectedToProxyStoreAndActionDispatched_StateChangesDelivered() {
        let initialTitle = "hello"
        let state = TestAppState(vcState: TestVCState(title: initialTitle))

        let rootStore = RootStore<TestAppState, Action>(initialState: state) { state, action in
            state.reduce(action)
        }
        let store = rootStore.store()

        let didSetProps = expectation(description: "didSetProps")
        let didMakeProps = expectation(description: "didMakeProps")
        didSetProps.expectedFulfillmentCount = 2
        didMakeProps.expectedFulfillmentCount = 2

        let vc = StubViewController()
        vc.didSetProps = {
            didSetProps.fulfill()
        }


        vc.with(store: store.proxy { $0.vcState },
                props: { state, store in
                    didMakeProps.fulfill()
                    return .init(title: state.title)
                })

        vc.viewDidLoad()

        let action = TestAction(title: "Hello World")
        store.dispatch(action)

        waitForExpectations(timeout: timeout) {_ in
            XCTAssertEqual(vc.props?.title, action.title)
        }
    }
}
