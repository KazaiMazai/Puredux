//
//  File.swift
//
//
//  Created by Sergey Kazakov on 07/04/2024.
//

import XCTest
@testable import Puredux

@available(iOS 13.0, *)
final class StorePerformanceTests: XCTestCase {
    
    func test_StoreDispatchPerfomance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            
            let store = StateStore<Array<Int>, Int>(
                initialState: Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let expectation = expectation(description: "finished")
            
            store.subscribe(observer: Observer { (state, prevState, complete) in
                guard state.first == 10000 else { return }
                expectation.fulfill()
            })
            
            Array(repeating: 1, count: 10000).forEach {
                store.dispatch($0)
            }
            
            wait(for: [expectation], timeout: 30)
        }
    }
    
    func test_ChildStoreDispatchPerfomance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            
            let rootStore = StateStore<Array<Int>, Int>(
                initialState: Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let store = rootStore.appending(Array(repeating: 0, count: 2000),
                                            reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false
            
            store.subscribe(observer: Observer { (state, prevState, complete) in
                guard state.1.first == 10000,
                      state.0.first == 10000
                else {
                    return
                }
                expectation.fulfill()
            })
            
            Array(repeating: 1, count: 10000).forEach {
                store.dispatch($0)
            }
            
            wait(for: [expectation], timeout: 30)
        }
    }
    
    func test_ChainOf3StoresDispatchPerfomance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            
            let rootStore = StateStore<Array<Int>, Int>(
                initialState: Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let childOne = rootStore.appending(Array(repeating: 0, count: 2000),
                                               reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let childTwo = childOne.appending(Array(repeating: 0, count: 2000),
                                              reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false
            
            childTwo.subscribe(observer: Observer { (state, prevState, complete) in
                guard state.0.0.first == 10000,
                      state.0.1.first == 10000,
                      state.1.first == 10000
                else {
                    return
                }
                expectation.fulfill()
            })
            
            Array(repeating: 1, count: 10000).forEach {
                childTwo.dispatch($0)
            }
            
            wait(for: [expectation], timeout: 30)
        }
    }
    
    func test_ChainOf4StoresDispatchPerfomance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            
            let rootStore = StateStore<Array<Int>, Int>(
                initialState: Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let childOne = rootStore.appending(Array(repeating: 0, count: 2000),
                                               reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let childTwo = childOne.appending(Array(repeating: 0, count: 2000),
                                              reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let childThree = childTwo.appending(Array(repeating: 0, count: 2000),
                                                reducer: { state, action in state = state.map { $0 + action } }
            )
            
            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false
            
            childThree.subscribe(observer: Observer { (state, prevState, complete) in
                guard state.0.0.0.first == 10000,
                      state.0.0.1.first == 10000,
                      state.0.1.first == 10000,
                      state.1.first == 10000
                else {
                    return
                }
                
                expectation.fulfill()
            })
            
            Array(repeating: 1, count: 10000).forEach {
                childThree.dispatch($0)
            }
            
            wait(for: [expectation], timeout: 30)
        }
    }
}

