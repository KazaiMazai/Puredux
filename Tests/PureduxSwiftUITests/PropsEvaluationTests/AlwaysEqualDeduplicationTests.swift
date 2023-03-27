//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09.03.2023.
//

import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import PureduxCommon
import UIKit


class RootStoreAlwaysEqualDeduplicationPropsTests: AlwaysEqualDeduplicationPropsTests {

}

class ScopeStoreAlwaysEqualDeduplicationPropsTests: AlwaysEqualDeduplicationPropsTests {
    @discardableResult override func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                         rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: SubStateWithTitle,
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return state.title
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.alwaysEqual)
                .scopeStore { (state: TestAppState) in state.subStateWithTitle }
            }
        )
    }
}

class StoreAlwaysEqualDeduplicationPropsTests: AlwaysEqualDeduplicationPropsTests {
    @discardableResult override func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                         rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: TestAppState,
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return state.subStateWithTitle.title
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.alwaysEqual)
                .store(rootStore)
            }
        )
    }
}

class ChildStoreAlwaysEqualDeduplicationPropsTests: AlwaysEqualDeduplicationPropsTests {

    @discardableResult override func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                         rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: (TestAppState, SubStateWithTitle),
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return state.1.title
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.alwaysEqual)
                .childStore(
                    initialState: SubStateWithTitle(title: ""),
                    reducer: { state, action in state.reduce(action) }
                )
            }
        )
    }
}
