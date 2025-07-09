//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation
import Crocodil

public typealias Dependencies = Crocodil.Dependencies

public typealias Dependency = Crocodil.Dependency

@available(*, deprecated, message: "use SharedStores instead", renamed: "SharedStores")
public typealias Injected = SharedStores
 
public struct SharedStores: Container, Sendable {
    public init() { }
}
