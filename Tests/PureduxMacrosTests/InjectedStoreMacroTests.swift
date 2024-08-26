//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import PureduxMacros

final class InjectedStoreMacroTests: XCTestCase {
    private let macros = ["InjectEntry": InjectedStoreMacro.self]
    
    func testEnvironmentValue() {
        assertMacroExpansion(
              """
              extension InjectedStores {
                  @InjectEntry var root = StateStore<Int, Int>(10) {_,_ in }
              }
              """,
              expandedSource:
                """
                extension InjectedStores {
                    var root = StateStore<Int, Int>(10) {_,_ in } {
                        get {
                            Self [RootKey.self]
                        }
                        set {
                            Self [RootKey.self] = newValue
                        }
                    }
                
                    enum RootKey: InjectionKey {
                        static var currentValue = StateStore<Int, Int>(10) { _, _ in
                        }
                    }
                }
                """,
              macros: macros
        )
    }
}
