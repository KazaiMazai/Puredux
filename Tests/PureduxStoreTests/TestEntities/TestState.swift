//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

struct TestState {
    private(set) var currentIndex: Int

    mutating func reduce(action: Action) {
        switch action {
        case let action as UpdateIndex:
            currentIndex = action.index
        default:
            break
        }
    }
}
