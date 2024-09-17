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
extension Stores {
    @InjectEntry var intValue: Int = 1
}
 
final class InjectionTests: XCTestCase {
    func test_whenReadAndWriteToInjectedValue_NoDeadlockOccurs() {
        Stores[\.intValue] = 1
        
        Stores[\.intValue] = Stores[\.intValue] + 1
        XCTAssertEqual(Stores[\.intValue], 2)
         
    }
}
#endif
