//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2023.
//

import XCTest
@testable import Puredux
import SwiftUI
import UIKit


@available(iOS 13.0, *)
class RootStoreViewFromStateDispatchRenderTests: ViewWithStoreRenderTests {
    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore { (state: TestAppState,
                                dispatch: Dispatch<Action>) -> Text in
                    contentRenderedExpectation.fulfill()
                    return Text(state.subStateWithTitle.title)
                }
            }
        )
    }
}


@available(iOS 13.0, *)
class RootStoreViewFromStateStoreRenderTests: ViewWithStoreRenderTests {
    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore { (state: TestAppState,
                                store: PublishingStore<TestAppState, Action>) -> Text in
                    contentRenderedExpectation.fulfill()
                    return Text(state.subStateWithTitle.title)
                }
            }
        )
    }
}
