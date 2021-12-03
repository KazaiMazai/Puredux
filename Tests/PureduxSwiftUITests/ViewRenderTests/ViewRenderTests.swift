import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import UIKit

final class ViewEnvStoreRenderTests: ViewWithStoreRenderTests {

    @discardableResult override func setupWindowForTests(
        contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: StoreProvidingView(store: store) {
                Text.with(
                    props: { (state: TestAppState, store: AnyPublishingStore<TestAppState, Action>) in
                        state.subStateWithTitle.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    })
            }
        )
    }
}

class ViewWithStoreRenderTests: XCTestCase {
    let timeout: TimeInterval = 4
    let actionDelay: TimeInterval = 0.1

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

    @discardableResult func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {
        UIWindow.setupForSwiftUITests(
            rootView: Text.with(
                store: store.eraseToAnyStore(),
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
}

extension ViewWithStoreRenderTests {

    func test_WhenNoActionDispatchedAfterSetup_ThenViewIsNotRendered() {
        let contentRendered = expectation(description: "contentRendered")
        contentRendered.isInverted = true

        setupWindowForTests(contentRenderedExpectation: contentRendered)

        waitForExpectations(timeout: timeout)
    }

    func test_WhenOneActionDispatchedAfterSetup_ThenViewRenderedOnce() {
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

}

extension ViewWithStoreRenderTests {

    static var allTests = [
        ("test_WhenNoActionDispatchedAfterSetup_ThenViewIsNotRendered",
         test_WhenNoActionDispatchedAfterSetup_ThenViewIsNotRendered),

        ("test_WhenOneActionDispatchedAfterSetup_ThenViewRenderedOnce",
         test_WhenOneActionDispatchedAfterSetup_ThenViewRenderedOnce),

        ("test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce",
         test_WhenManyActionsAndPropsNotChanged_ThenViewRenderedOnce),

        ("test_WhenManyActionsDispatchedWithDelayAndPropsChanged_ThenViewRenderedEveryTime",
         test_WhenManyActionsDispatchedWithDelayAndPropsChanged_ThenViewRenderedEveryTime),

        ("test_WhenManyActionsDispatchedWithDelayAndPropsNotChanged_ThenViewRenderedOnce",
         test_WhenManyActionsDispatchedWithDelayAndPropsNotChanged_ThenViewRenderedOnce)
    ]
}


