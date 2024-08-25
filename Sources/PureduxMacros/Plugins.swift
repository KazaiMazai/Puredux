//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import PureduxMacrosImplementation

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectedStoreMacro.self
    ]
}
