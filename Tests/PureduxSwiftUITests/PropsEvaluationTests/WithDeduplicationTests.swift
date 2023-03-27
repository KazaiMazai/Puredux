//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2023.
//

import XCTest
@testable import PureduxSwiftUI
import SwiftUI
import PureduxStore
import PureduxCommon
import UIKit

class RootStoreDeduplicationPropsTests: DeduplicationPropsTests {

}

class ScopeStoreDeduplicationPropsTests: DeduplicationPropsTests {
    @discardableResult override func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                         rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: SubStateWithIndex,
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return String(state.index)
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.equal { $0.index })
                .scopeStore { (state: TestAppState) in state.subStateWithIndex }
            }
        )
    }
}

class StoreDeduplicationPropsTests: DeduplicationPropsTests {
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
                .removeStateDuplicates(.equal { $0.subStateWithIndex.index })
                .store(rootStore)
            }
        )
    }
}

class ChildStoreDeduplicationPropsTests: DeduplicationPropsTests {

    @discardableResult override func setupWindowForTests(propsEvaluatedExpectation: XCTestExpectation,
                                                         rootStore: PublishingStore<TestAppState, Action>) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: (TestAppState, SubStateWithTitle),
                              dispatch: Dispatch<Action>) -> String in

                        propsEvaluatedExpectation.fulfill()
                        return state.0.subStateWithTitle.title
                    },
                    content: {
                        Text($0)
                    }
                )
                .removeStateDuplicates(.equal { $0.0.subStateWithIndex.index })
                .childStore(
                    initialState: SubStateWithTitle(title: "child state"),
                    reducer: { state, action in state.reduce(action) }
                )
            }
        )
    }
}
