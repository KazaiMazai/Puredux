//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

#if canImport(PureduxMacros)
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import PureduxMacros

final class InjectedStoreMacroTests: XCTestCase {
    func test_WhenStoreEntry_StoreInjectionKeyGenerated() {
        let macros = ["StoreEntry": StoreInjectionMacro.self]
        
        assertMacroExpansion(
              """
              extension SharedStores {
                  @StoreEntry var root = StateStore<Int, Int>(10) {_,_ in }
              }
              """,
              expandedSource:
                """
                extension SharedStores {
                    var root {
                        get {
                            self [_RootKey.self]
                        }
                        set {
                            self [_RootKey.self] = newValue
                        }
                    }

                    private enum _RootKey: DependencyKey {
                        nonisolated (unsafe) static var currentValue = StateStore<Int, Int>(10) { _, _ in
                        }
                    }
                }
                """,
              macros: macros
        )
    }
    
    func test_WhenDependencyEntry_DepenencyInjectionKeyGenerated() {
        let macros = ["DependencyEntry": DependencyInjectionMacro.self]
            
        assertMacroExpansion(
              """
              extension Dependencies {
                  @DependencyEntry var value = 10
              }
              """,
              expandedSource:
                """
                extension SharedStores {
                    var root {
                        get {
                            self [_ValueKey.self]
                        }
                        set {
                            self [_ValueKey.self] = newValue
                        }
                    }

                    private enum _ValueKey: DependencyKey {
                        nonisolated (unsafe) static var currentValue = 10
                        }
                    }
                }
                """,
              macros: macros
        )
    }
}
#endif
