//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

import XCTest
@testable import Puredux

extension Injected {
    @InjectEntry var intValue: Int = 1
}
 
final class InjectionTests: XCTestCase {
    func test_whenReadAndWriteToInjectedValue_NoDeadlockOccurs() {
        Injected[\.intValue] = 1
        
        Injected[\.intValue] = Injected[\.intValue] + 1
        XCTAssertEqual(Injected[\.intValue], 2)
         
    }
}
