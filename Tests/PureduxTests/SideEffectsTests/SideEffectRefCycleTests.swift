//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import Foundation
import XCTest
@testable import Puredux

final class SideEffectRefCycleTests: XCTestCase {
    
    func test_WhenEffectWithCancellables_ThenReferencCycleNotCreated() {
        assertDeallocated {
            var cancellables = Set<CancellableEffect>()
            
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                
        
            store.effect(&cancellables, toggle: \.boolValue) { state, _ in
                
                Effect {
                    store.dispatch(10)
                }
            }
           
            return object as AnyObject
        }
    }
    
    func test_WhenViewStoreIsNotReferenced_ThenReferencCycleNotCreated() {
        assertDeallocated {
            let object = ReferenceTypeState()
            
            let viewStore = ViewStore { cancellables in
                StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(&cancellables, toggle: \.boolValue) { state, dispatch in
                    
                        Effect {
                            dispatch(10)
                        }
                    }
            }
  
            return object as AnyObject
        }
    }
    
    func test_WhenViewStoreIsReferenced_ThenReferencIsKept() {
        var viewStore: ViewStore<Store<(state: ReferenceTypeState, boolValue: Bool), Int>>?
       
        assertNotDeallocated {
            let object = ReferenceTypeState()
            
            viewStore = ViewStore { cancellables in
                StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(&cancellables, toggle: \.boolValue) { state, dispatch in
                    
                        Effect {
                            dispatch(10)
                        }
                    }
            }
  
            return object as AnyObject
        }
    }
}
