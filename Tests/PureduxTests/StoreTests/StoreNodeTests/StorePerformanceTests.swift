//
//  File.swift
//
//
//  Created by Sergey Kazakov on 07/04/2024.
//

import XCTest
@testable import Puredux

final class StorePerformanceTests: XCTestCase {

    func test_StoreDispatchPerfomance() {
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {

            let store = StateStore<[Int], Int>(
                Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )

            let expectation = expectation(description: "finished")

            store.subscribe(observer: Observer { (state, _, _) in
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

            let rootStore = StateStore<[Int], Int>(
                Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )

            let store = rootStore.with(Array(repeating: 0, count: 2000),
                                       reducer: { state, action in state = state.map { $0 + action } }
            )

            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false

            store.subscribe(observer: Observer { (state, _, _) in
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

            let rootStore = StateStore<[Int], Int>(
                Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )

            let childOne = rootStore.with(Array(repeating: 0, count: 2000),
                                          reducer: { state, action in state = state.map { $0 + action } }
            )

            let childTwo = childOne.with(Array(repeating: 0, count: 2000),
                                         reducer: { state, action in state = state.map { $0 + action } }
            )

            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false

            childTwo.subscribe(observer: Observer { (state, _, _) in
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

            let rootStore = StateStore<[Int], Int>(
                Array(repeating: 0, count: 2000),
                reducer: { state, action in state = state.map { $0 + action } }
            )

            let childOne = rootStore.with(Array(repeating: 0, count: 2000),
                                          reducer: { state, action in state = state.map { $0 + action } }
            )

            let childTwo = childOne.with(Array(repeating: 0, count: 2000),
                                         reducer: { state, action in state = state.map { $0 + action } }
            )

            let childThree = childTwo.with(Array(repeating: 0, count: 2000),
                                           reducer: { state, action in state = state.map { $0 + action } }
            )

            let expectation = expectation(description: "finished")
            expectation.assertForOverFulfill = false

            childThree.subscribe(observer: Observer { (state, _, _) in
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
