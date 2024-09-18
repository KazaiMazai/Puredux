//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation
import XCTest
@testable import Puredux

extension SharedStores {
    @StoreEntry var theStore = StateStore<Int, Int>(1) { _,_ in }
    
}

extension Injected {
    @InjectEntry var anotherIntValue: Int = 1
}
 
final class SharedStoresTests: XCTestCase {
    func test_whenReadAndWriteToSharedStoresValue_NoDeadlockOccurs() {
        let exp = expectation(description: "wait for store state")
        SharedStores[\.theStore] = StateStore(2) {_,_ in }
       
        
        let store =  SharedStores[\.theStore]
        store.subscribe(observer: Observer { state in
            XCTAssertEqual(state, 2)
            exp.fulfill()
            return .active
        })
       
        wait(for: [exp], timeout: 3.0)
    }
    
    func test_whenReadAndWriteToInjectedValue_NoDeadlockOccurs() {
        Injected[\.anotherIntValue] = 1
        
        Injected[\.anotherIntValue] = Injected[\.anotherIntValue] + 1
        XCTAssertEqual(Injected[\.anotherIntValue], 2)
         
    }
}

extension Dependencies {
    @DependencyEntry var intValue: Int = 1
}
 
final class DependenciesTests: XCTestCase {
    func test_whenReadAndWriteToSharedStoresValue_NoDeadlockOccurs() {
        XCTAssertEqual(Dependency[\.intValue], 1)
        
        Dependencies[\.intValue] = Dependencies[\.intValue] + 1
        XCTAssertEqual(Dependencies[\.intValue], 2)
    }
}
 
