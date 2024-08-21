//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 20/08/2024.
//

import Foundation
import SwiftUI

extension StateStore {
   func registered() -> Self {
       Stores.getInstance().register(self, key: State.self)
       return self
   }
   
   func registered<Key>(_ key: Key) -> Self {
       Stores.getInstance().register(self, key: key)
       return self
   }
   
   static func resolved() -> Self {
       Stores.getInstance().resolve(with: State.self)
   }
   
   static func resolved<Key>(with key: Key) -> Self {
       Stores.getInstance().resolve(with: key)
   }
   
   func unregister() {
       Stores.getInstance().unregister(self, key: State.self)
   }
   
   func unregister<Key>(_ key: Key) {
       Stores.getInstance().unregister(self, key: key)
   }
}

final class Stores {
    private static let shared = Stores()
    
    static func getInstance() -> Stores {
        shared
    }
    
    private var dependencies: [String: Any] = [:]

    func unregister<T, Key>(_ dependency: T, key: Key? = nil) {
        let key = compoundKey(for: T.self, key: key)
        dependencies[key] = nil
    }
    
    func register<T, Key>(_ dependency: T, key: Key? = nil) {
        let key = compoundKey(for: T.self, key: key)
        dependencies[key] = dependency
    }

    func resolve<T, Key>(with key: Key?) -> T {
        let dependency: T? = resolveOptional(with: key)
        precondition(dependency != nil,
                     """
                     Store of type: \(T.self) not found \(key.map { "for \($0)." } ?? ".")
                     Must register a store before resolving.
                     """
        )
        return dependency!
    }
    
    private func resolveOptional<T, Key>(with key: Key?) -> T? {
        let key = compoundKey(for: T.self, key: key)
        let dependency = dependencies[key] as? T
        return dependency
    }

    private func compoundKey<T, Key>(for type: T.Type, key: Key?) -> String {
        [
            String(reflecting: T.self),
            key.map { "\($0)" }
        ]
        .compactMap { $0 }
        .joined(separator: "-")
    }
}
 
