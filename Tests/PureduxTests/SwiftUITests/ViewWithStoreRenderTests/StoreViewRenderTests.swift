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
import Combine

@available(iOS 13.0, *)
class StoreViewRenderTests: ViewWithStoreRenderTests {
    @discardableResult override func setupWindowForTests(contentRenderedExpectation: XCTestExpectation) -> UIWindow {

        let statePublisher = CurrentValueSubject<TestAppState, Never>(TestAppState())
        let dummyStore = PublishingStore(
            statePublisher: statePublisher.eraseToAnyPublisher(),
            dispatch: { action in print(action) }
        )
        let rootStore = store
        return UIWindow.setupForSwiftUITests(
            rootView: ViewWithStore(
                props: { (state: TestAppState,
                          dispatch: Dispatch<Action>) -> String in

                    state.subStateWithTitle.title
                },
                content: {
                    contentRenderedExpectation.fulfill()
                    return Text($0)
                }
            )
            .store(rootStore)

        )
    }
}

