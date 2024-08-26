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


class ChildStoreViewRenderTests: ViewWithStoreRenderTests {

    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: (appState: TestAppState, childState: SubStateWithTitle),
                              dispatch: Dispatch<Action>) -> String in
                        state.appState.subStateWithTitle.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    }
                )
                .childStore(
                    initialState: SubStateWithTitle(title: "child state"),
                    reducer: { state, action in state.reduce(action) }
                )
            }
        )
    }
}


class ChildStoreWithStateMappingViewRenderTests: ViewWithStoreRenderTests {

    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: (TestAppState),
                              dispatch: Dispatch<Action>) -> String in
                        state.subStateWithTitle.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    }
                )
                .childStore(
                    initialState: SubStateWithTitle(title: "child state"),
                    stateMapping: { (appState: TestAppState,
                                     childState: SubStateWithTitle) in

                        appState
                    },
                    reducer: { state, action in state.reduce(action) }
                )
            }
        )
    }
}
