//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import Foundation
import XCTest
@testable import Puredux
import Puredux

final class SideEffectRefCycleTests: XCTestCase {
    
    func test_WhenEffectWithCancellables_ThenReferencCycleNotCreated() {
        assertDeallocated {
            var cancellable = AnyCancellableEffect()
            
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                
        
            store.effect(cancellable, toggle: \.boolValue) { state, _ in
                
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
            
            let viewStore = ViewStore { cancellable in
                StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(cancellable, toggle: \.boolValue) { state, dispatch in
                    
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
            
            viewStore = ViewStore { cancellable in
                StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(cancellable, toggle: \.boolValue) { state, dispatch in
                    
                        Effect {
                            dispatch(10)
                        }
                    }
            }
  
            return object as AnyObject
        }
    }
    
    func test_WhenCancellableIsReferenced_ThenReferencIsKept() {
        var referenceCancellable: AnyCancellableEffect?
        
        assertNotDeallocated {
            let object = ReferenceTypeState()
            
            let viewStore = ViewStore { cancellable in
                referenceCancellable = cancellable
                return StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(cancellable, toggle: \.boolValue) { state, dispatch in
                    
                        Effect {
                            dispatch(10)
                        }
                    }
            }
  
            return object as AnyObject
        }
    }
    
    func test_WhenCancellableIsReferencedButCancelld_ThenReferencIsNotKept() {
        var referencedCancellable: AnyCancellableEffect?
        
        assertDeallocated {
            let object = ReferenceTypeState()
            
            let viewStore = ViewStore { cancellable in
                referencedCancellable = cancellable
                
                return StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                    .with(true) { _, _ in }
                    .map { (state: $0.0, boolValue: $0.1)}
                    .effect(cancellable, toggle: \.boolValue) { state, dispatch in
                    
                        Effect {
                            dispatch(10)
                        }
                    }
            }
            
            referencedCancellable?.cancel()
            return object as AnyObject
        }
    }
    
    func test_WhenStoreIsNotReferenced_TheStateIsDeallocated() {
        assertDeallocated {
            let object = ReferenceTypeState()
            
            let store = StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                .with(true) { state, _ in state.toggle() }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(toggle: \.boolValue) { state, dispatch in
                
                    Effect {
                        dispatch(10)
                    }
                }
 
            return object as AnyObject
        }
    }
}
