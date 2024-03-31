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
    
    func test_WhenStrongRefToVC_ThenStrongRefToChildStoreState() {
        var strongViewController: StubViewController?
        weak var weakRefObject: ReferenceTypeState?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            
            let store = factory.childStore(
                initialState: object,
                reducer: { state, action in state.reduce(action) }
            )
            
            weakRefObject = object
            
            let viewController = StubViewController()
            
            viewController.with(store: store,
                                props: { _, _ in .init(title: "") }
            )
            viewController.viewDidLoad()
            strongViewController = viewController
        }
        
        XCTAssertNotNil(weakRefObject)
    }
    
    func test_WhenNoStrongRefToVC_ThenChildStoreStateIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        var strongViewController: StubViewController?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            
            let store = factory.childStore(
                initialState: object,
                reducer: { state, action in state.reduce(action) }
            )
            
            weakRefObject = object
            
            let viewController = StubViewController()
            
            viewController.with(store: store,
                                props: { _, _ in .init(title: "") }
            )
            viewController.viewDidLoad()
            strongViewController = viewController
        }
        
        XCTAssertNotNil(weakRefObject)
        strongViewController = nil
        XCTAssertNil(weakRefObject)
    }
}
