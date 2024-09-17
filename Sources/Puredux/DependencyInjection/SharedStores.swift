//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@available(*, deprecated, message: "use SharedStores instead", renamed: "SharedStores")
public typealias Injected = SharedStores

public struct SharedStores: Sendable, DependencyContainer {
    public init() {
        
    }
}
