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
        
        assertNotDeallocated {
            let object = ReferenceTypeState()
            
            let store = self.factory.childStore(
                initialState: object,
                reducer: { state, action in state.reduce(action) }
            )
           
            let viewController = StubViewController()
            
            viewController.with(store: store,
                                props: { _, _ in .init(title: "") }
            )
            viewController.viewDidLoad()
            strongViewController = viewController
            return object as AnyObject
        }
    }
    
    func test_WhenNoStrongRefToVC_ThenChildStoreStateIsReleased() {
        weak var weakViewController: StubViewController?
        
        assertDeallocated {
            let object = ReferenceTypeState()
            
            let store = self.factory.childStore(
                initialState: object,
                reducer: { state, action in state.reduce(action) }
            )
            
            let viewController = StubViewController()
            
            viewController.with(store: store,
                                props: { _, _ in .init(title: "") }
            )
            viewController.viewDidLoad()
            weakViewController = viewController
            return object as AnyObject
        }
    }
}
