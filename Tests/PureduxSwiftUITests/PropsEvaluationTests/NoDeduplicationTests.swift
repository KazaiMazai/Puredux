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

class RootStoreNoDeduplicationPropsTests: NoDeduplicationPropsTests {

}

class ScopeStoreNoDeduplicationPropsTests: NoDeduplicationPropsTests {
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
                .removeStateDuplicates(.neverEqual)
                .scopeStore { (state: TestAppState) in state.subStateWithTitle }
            }
        )
    }
}

class StoreNoDeduplicationPropsTests: NoDeduplicationPropsTests {
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
                .removeStateDuplicates(.neverEqual)
                .store(rootStore)
            }
        )
    }
}

