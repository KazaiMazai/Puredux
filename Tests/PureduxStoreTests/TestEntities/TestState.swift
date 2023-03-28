//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

struct TestState: Equatable {
    private(set) var currentIndex: Int
    private(set) var asyncActionReceivedCount: Int = 0
    private(set) var createdActionReceivedCount: Int = 0

    mutating func reduce(action: Action) {
        switch action {
        case let action as UpdateIndex:
            currentIndex = action.index
        case _ as AsyncAction:
            asyncActionReceivedCount += 1
        case _ as ResultAction:
            createdActionReceivedCount += 1
        default:
            break
        }
    }
}

struct ChildTestState: Equatable {
    private(set) var currentIndex: Int
    private(set) var asyncActionReceivedCount: Int = 0
    private(set) var createdActionReceivedCount: Int = 0

    mutating func reduce(action: Action) {
        switch action {
        case let action as UpdateIndex:
            currentIndex = action.index
        case _ as AsyncAction:
            asyncActionReceivedCount += 1
        case _ as ResultAction:
            createdActionReceivedCount += 1
        default:
            break
        }
    }
}

struct StateComposition: Equatable {
    let state: TestState
    let childState: ChildTestState
}
