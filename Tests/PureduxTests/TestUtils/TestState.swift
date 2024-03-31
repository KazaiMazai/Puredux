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

struct TestAppState {
    private(set) var subStateWithTitle = SubStateWithTitle()
    private(set) var subStateWithIndex = SubStateWithIndex()

    mutating func reduce(_ action: Action) {
        subStateWithTitle.reduce(action)
        subStateWithIndex.reduce(action)
    }
}

struct TestAppStateWithIndex {
    private(set) var subStateWithIndex = SubStateWithIndex()

    mutating func reduce(_ action: Action) {
        subStateWithIndex.reduce(action)
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

class ReferenceTypeState {
    
    func reduce(_ action: Action) {
         
    }
    
    deinit {
        
    }
}
