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
    
    
    func test_WhenEffectRefToStore_ThenReferencCycleIsCreated() {
        assertDeallocated {
            let observer = NSObject()
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_,_ in }
                .with(true) { _, _ in }
//                .map { (state: $0.0, boolValue: $0.1)}
                
        
            store.effect(\.1) { state, dispatch in
                
                Effect {
                    dispatch(10)
                }
            }
            
            return object as AnyObject
        }
    }
}
