//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//
@testable import Puredux
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class InjectedStoreMacroTests: XCTestCase {
    private let macros = ["InjectedStore": InjectedStoreMacro.self]
    
    func testEnvironmentValue() {
        assertMacroExpansion(
      """
      extension InjectedStores {
          @InjectedStoreEntry var rootStore = StateStore<Int, Int>(10) {_,_ in }
      }
      """,
      expandedSource: """
        extension InjectedStores {
            @InjectedStoreEntry var rootStore = StateStore<Int, Int>(10) {_,_ in }
            {
                get {
                    Self [RootstoreKey.self]
                }
                set {
                    Self [RootstoreKey.self] = newValue
                }
            }
        
            enum RootstoreKey: InjectionKey {
                static var currentValue = StateStore<Int?, Int>(10) { _, _ in
                }
            }
        }
        """,
      macros: macros
        )
    }
}
