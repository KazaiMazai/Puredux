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
    
    private let macros = ["InjectEntry": InjectedStoreMacro.self]

    func testEnvironmentValue() {
        assertMacroExpansion(
              """
              extension Injected {
                  @InjectEntry var root = StateStore<Int, Int>(10) {_,_ in }
              }
              """,
              expandedSource:
                """
                extension Injected {
                    var root {
                        get {
                            self [_RootKey.self]
                        }
                        set {
                            self [_RootKey.self] = newValue
                        }
                    }

                    private enum _RootKey: InjectionKey {
                        nonisolated (unsafe) static var currentValue = StateStore<Int, Int>(10) { _, _ in
                        }
                    }
                }
                """,
              macros: macros
        )
    }
}
#endif
