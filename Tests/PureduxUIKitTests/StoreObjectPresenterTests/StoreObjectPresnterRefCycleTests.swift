//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.03.2023.
//

import XCTest
@testable import PureduxUIKit
import PureduxStore

final class StoreObjectPresnterRefCycleTests: XCTestCase {
    let timeout: TimeInterval = 4

    let state = TestAppStateWithIndex()

    lazy var factory: StoreFactory = {
        StoreFactory<TestAppStateWithIndex, Action>(
            initialState: state,
            reducer: { state, action in
                state.reduce(action)
            })
    }()

    func test_WhenStrongRefToVC_ThenStrongRefToChildStore() {
        weak var weakChildStore: StoreObject<(TestAppStateWithIndex, SubStateWithTitle), Action>?
        var strongViewController: StubViewController?

        autoreleasepool {
            let strongChildStore = factory.childStore(
                initialState: SubStateWithTitle(),
                reducer: { state, action in state.reduce(action) }
            )

            weakChildStore = strongChildStore

            let viewController = StubViewController()

            viewController.with(store: strongChildStore,
                    props: { state, _ in .init(title: state.1.title) }
            )

            strongViewController = viewController
        }

        XCTAssertNotNil(weakChildStore)
    }

    func test_WhenNoStrongRefToVC_ThenChildStoreIsReleased() {
        weak var weakChildStore: StoreObject<(TestAppStateWithIndex, SubStateWithTitle), Action>?
        var strongViewController: StubViewController?

        autoreleasepool {
            let strongChildStore = factory.childStore(
                initialState: SubStateWithTitle(),
                reducer: { state, action in state.reduce(action) }
            )

            weakChildStore = strongChildStore

            let viewController = StubViewController()

            viewController.with(store: strongChildStore,
                    props: { state, _ in .init(title: state.1.title) }
            )

            strongViewController = viewController
        }

        strongViewController = nil
        XCTAssertNil(weakChildStore)
    }
}
