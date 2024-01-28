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

class ScopeStoreViewRenderTests: ViewWithStoreRenderTests {
    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        UIWindow.setupForSwiftUITests(
            rootView: ViewWithStoreFactory(factory) {

                ViewWithStore(
                    props: { (state: SubStateWithTitle,
                              dispatch: Dispatch<Action>) -> String in
                        state.title
                    },
                    content: {
                        contentRenderedExpectation.fulfill()
                        return Text($0)
                    }
                )
                .scopeStore { (state: TestAppState) in state.subStateWithTitle }
            }
        )
    }
}
