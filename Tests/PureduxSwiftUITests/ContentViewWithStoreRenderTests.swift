import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import UIKit
import SnapshotTesting

final class ContentViewWithStoreRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

    let state = TestAppState(
        subStateWithTitle: SubStateWithTitle(title: ""),
        subStateWithIndex: SubStateWithIndex(index: 0)
    )

    lazy var store: ObservableStore = {
        ObservableStore(
            store: Store<TestAppState, Action>(initial: state) { state, action in
                state.reduce(action)
            }
        )
    }()

    @discardableResult func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {
        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store,
                props: { (state, store) in
                    state.subStateWithTitle.title
                },
                content: {
                    contentRenderedExpectation.fulfill()
                    return Text($0)
                }
            )
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

    func test_WhenManyActionsAndStateNotMutated_ThenViewRenderedOnce() {
        let actionsCount = 100
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.expectedFulfillmentCount = 1

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        (0..<actionsCount).forEach { _ in
            store.dispatch(NonMutatingStateAction())
        }

        waitForExpectations(timeout: timeout)
    }

    func test_WhenManyActionsDispatchedWithDelayAndStateMutated_ThenViewRenderedEveryTime() {
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

    func test_WhenManyActionsDispatchedWithDelayAndStateNotMutated_ThenViewRenderedOnce() {
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

        ("test_WhenManyActionsAndStateNotMutated_ThenViewRenderedOnce",
         test_WhenManyActionsAndStateNotMutated_ThenViewRenderedOnce),

        ("test_WhenManyActionsDispatchedWithDelayAndStateMutated_ThenViewRenderedEveryTime",
         test_WhenManyActionsDispatchedWithDelayAndStateMutated_ThenViewRenderedEveryTime),

        ("test_WhenManyActionsDispatchedWithDelayAndStateNotMutated_ThenViewRenderedOnce",
         test_WhenManyActionsDispatchedWithDelayAndStateNotMutated_ThenViewRenderedOnce)
    ]

}


