//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

public typealias Injected = Stores

public struct Stores: Sendable, DependencyContainer {
    public init() {
        
    }
}

extension Stores {
    @StoreEntry var store = StateStore<Int, Int>(0) {_,_ in }
}
