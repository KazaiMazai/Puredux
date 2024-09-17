//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

import XCTest
@testable import Puredux

#if canImport(PureduxMacros)
extension SharedStores {
    @StoreEntry var intValue: Int = 1
}

extension Injected {
    @InjectEntry var anotherIntValue: Int = 1
}
 
final class InjectionTests: XCTestCase {
    func test_whenReadAndWriteToSharedStoresValue_NoDeadlockOccurs() {
        SharedStores[\.intValue] = 1
        
        SharedStores[\.intValue] = SharedStores[\.intValue] + 1
        XCTAssertEqual(SharedStores[\.intValue], 2)
         
    }
    
    func test_whenReadAndWriteToInjectedValue_NoDeadlockOccurs() {
        Injected[\.anotherIntValue] = 1
        
        Injected[\.anotherIntValue] = Injected[\.anotherIntValue] + 1
        XCTAssertEqual(Injected[\.anotherIntValue], 2)
         
    }
}
#endif
