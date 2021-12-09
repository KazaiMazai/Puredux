//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Foundation

struct TestVCState {
    var title: String = ""

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as TestAction:
            self.title = action.title
        default:
            break
        }

    }
}

struct TestAppState {
    private(set) var vcState = TestVCState()

    mutating func reduce(_ action: Action) {
        vcState.reduce(action)
    }
}
