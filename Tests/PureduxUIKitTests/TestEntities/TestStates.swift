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
        case let action as UpdateTitle:
            self.title = action.title
        default:
            break
        }
    }
}

struct TestAppState1 {
    private(set) var vcState = TestVCState()

    mutating func reduce(_ action: Action) {
        vcState.reduce(action)
    }
}


struct SubStateWithTitle {
    var title: String = ""

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateTitle:
            self.title = action.title
        default:
            break
        }

    }
}

struct SubStateWithIndex {
    var index: Int = 0

    mutating func reduce(_ action: Action) {
        switch action {
        case let action as UpdateIndex:
            self.index = action.index
        default:
            break
        }
    }
}

struct TestAppState {
    private(set) var subStateWithTitle = SubStateWithTitle()
    private(set) var subStateWithIndex = SubStateWithIndex()

    mutating func reduce(_ action: Action) {
        subStateWithTitle.reduce(action)
        subStateWithIndex.reduce(action)
    }
}
