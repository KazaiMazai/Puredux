//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

public struct Effect {
    typealias Operation = () -> Void
    private let perform: Operation?
}

public extension Effect {
    init(_ operation: @escaping () -> Void) {
        perform = operation
    }

    init(operation: @escaping () async -> Void) {
        perform = {
            Task { await operation() }
        }
    }

    static let skip: Effect = Effect(operation: nil)
}

extension Effect {
    var operation: Operation {
        perform ?? { }
    }

    var canBeExecuted: Bool {
        perform != nil
    }
}

private extension Effect {
    init(operation: Operation?) {
        perform = operation
    }
}

