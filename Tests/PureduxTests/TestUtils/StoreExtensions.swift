//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/08/2024.
//

import Foundation
import Dispatch
@testable import Puredux

extension AnyStore {
    func dispatch(_ action: Action, after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dispatch(action)
        }
    }
}

extension StateStore {
    func dispatch(_ action: Action, after delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dispatch(action)
        }
    }
}
