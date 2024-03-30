//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.03.2023.
//

import XCTest
@testable import Puredux


final class ChildStorePresenterRefCycleTests: XCTestCase {
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
        var strongViewController: StubViewController?
        weak var weakRefObject: SomeClass?
        
        autoreleasepool {
            let strongRefObject = SomeClass()
            
            let strongChildStore = factory.childStore(
                initialState: strongRefObject,
                reducer: { state, action in state.reduce(action) }
            )

            weakRefObject = strongRefObject

            let viewController = StubViewController()

            viewController.with(store: strongChildStore,
                    props: { state, _ in .init(title: "") }
            )

            strongViewController = viewController
        }
        
        XCTAssertNotNil(weakRefObject)
    }

    func test_WhenNoStrongRefToVC_ThenChildStoreIsReleased() {
        weak var weakRefObject: SomeClass?
        var strongViewController: StubViewController?

        autoreleasepool {
            let strongRefObject = SomeClass()
            
            let strongChildStore = factory.childStore(
                initialState: strongRefObject,
                reducer: { state, action in state.reduce(action) }
            )

            weakRefObject = strongRefObject

            let viewController = StubViewController()

            viewController.with(store: strongChildStore,
                    props: { state, _ in .init(title: "") }
            )

            strongViewController = viewController
        }
         
        strongViewController = nil
        XCTAssertNil(weakRefObject)
    }
}
