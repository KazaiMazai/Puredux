//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24.02.2023.
//

import XCTest
@testable import Puredux

final class StoreNodeChildStoreObserverRefCycleTests: XCTestCase {
    typealias ParentStore = StoreNode<VoidStore<Action>, TestState, TestState, Action>
    
    let timeout: TimeInterval = 3
    let rootStore = RootStoreNode<TestState, Action>.initRootStore(
        initialState: TestState(currentIndex: 0),
        reducer: { state, action  in state.reduce(action: action) }
    )

    func test_WhenStrongRefToStoreAndObserverLive_ThenReferencCycleIsCreated() {
        weak var weakRefObject: ReferenceTypeState?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                qos: .userInitiated,
                reducer: { state, action  in  state.reduce(action) }
            )
            
            weakRefObject = object
             
            let referencedStore = store.stateStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            referencedStore.subscribe(observer: observer)
        }

        XCTAssertNotNil(weakRefObject)
    }

    func test_WhenStrongRefToStoreAndObserverDead_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        
        let asyncExpectation = expectation(description: "Observer state handler")

        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                qos: .userInitiated,
                reducer: { state, action in state.reduce(action) }
            )
            
            weakRefObject = object
            
            let referencedStore = store.stateStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                referencedStore.dispatch(UpdateIndex(index: 1))
                complete(.dead)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    asyncExpectation.fulfill()
                }
            }

            referencedStore.subscribe(observer: observer)
        }

        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNil(weakRefObject)
        }
    }

    func test_WhenWeakStoreAndObserverLive_ThenStoreIsReleased() {
        weak var weakRefObject: ReferenceTypeState?
        
        autoreleasepool {
            let object = ReferenceTypeState()
            let store = rootStore.createChildStore(
                initialState: object,
                stateMapping: { state, childState in childState },
                qos: .userInitiated,
                reducer: { state, action  in  state.reduce(action) }
            )
            
            weakRefObject = object
            
            
            let weakRefStore = store.weakRefStore()

            let observer = Observer<ReferenceTypeState> { _, complete in
                weakRefStore.dispatch(UpdateIndex(index: 1))
                complete(.active)
            }

            store.subscribe(observer: observer)
        }

        XCTAssertNil(weakRefObject)
    }
}
