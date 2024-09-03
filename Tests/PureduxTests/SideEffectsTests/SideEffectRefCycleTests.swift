//
//  File.swift
//
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import Foundation
import XCTest
@testable import Puredux

final class SideEffectRefCycleWithCancellableTests: XCTestCase {

    func test_WhenCancellableIsNotReferenced_ThenStateIsDeallocated() {
        assertDeallocated {
            var cancellable = AnyCancellableEffect()

            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}

            store.effect(cancellable, toggle: \.boolValue) { _, _ in

                Effect {
                    store.dispatch(10)
                }
            }

            return object as AnyObject
        }
    }

    func test_WhenStoreIsNotReferenced_ThenStateIsDeallocated() {
        assertDeallocated {
            let object = ReferenceTypeState()
            let cancellable = AnyCancellableEffect()
            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(cancellable, toggle: \.boolValue) { _, dispatch in

                    Effect {
                        dispatch(10)
                    }
                }

            return object as AnyObject
        }
    }

    func test_WhenCancellableIsReferenced_ThenReferenceIsKept() {
        let cancellable = AnyCancellableEffect()
        assertNotDeallocated {
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(cancellable, toggle: \.boolValue) { _, dispatch in

                    Effect {
                        dispatch(10)
                    }
                }

            return object as AnyObject
        }
    }

    func test_WhenCancellableIsReferencedButCancelled_ThenStateIsDeallocated() {
        let cancellable = AnyCancellableEffect()

        assertDeallocated {
            let object = ReferenceTypeState()
            let store =  StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(cancellable, toggle: \.boolValue) { _, dispatch in

                    Effect {
                        dispatch(10)
                    }
                }

            cancellable.cancel()
            return object as AnyObject
        }
    }
}

final class SideEffectRefCycleTests: XCTestCase {

    func test_WhenAccidentalRefToStoreEffect_ThenStateIsNotDeallocated() {
        assertNotDeallocated {
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}

            store.effect(toggle: \.boolValue) { _, _ in

                Effect {
                    store.dispatch(10) // reference to the store in effect
                }
            }

            return object as AnyObject
        }
    }

    func test_WhenStoreIsReferenced_ThenStateInNotDeallocated() {
        var refToStore: StateStore<(state: ReferenceTypeState, boolValue: Bool), Int>?
        assertNotDeallocated {
            let object = ReferenceTypeState()
            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { _, _ in }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(toggle: \.boolValue) { _, dispatch in

                    Effect {
                        dispatch(10)
                    }
                }

            refToStore = store
            return object as AnyObject
        }
    }

    func test_WhenStoreIsNotReferenced_TheStateIsDeallocated() {
        assertDeallocated {
            let object = ReferenceTypeState()

            let store = StateStore<ReferenceTypeState, Int>(object) {_, _ in }
                .with(true) { state, _ in state.toggle() }
                .map { (state: $0.0, boolValue: $0.1)}
                .effect(toggle: \.boolValue) { _, dispatch in

                    Effect {
                        dispatch(10)
                    }
                }

            return object as AnyObject
        }
    }
}
