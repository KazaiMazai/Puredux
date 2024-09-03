//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros
import PureduxMacros
import SwiftSyntax

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectedStoreMacro.self
    ]
}

public struct InjectedStoreMacro: AccessorMacro, PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.AccessorDeclSyntax] {

        try PureduxMacros.InjectedStoreMacro.expansion(
            of: node,
            providingAccessorsOf: declaration,
            in: context
        )
    }

    public static func expansion(of node: SwiftSyntax.AttributeSyntax,
                                 providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
                                 in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {

        try PureduxMacros.InjectedStoreMacro.expansion(
            of: node,
            providingPeersOf: declaration,
            in: context
        )
    }
}
