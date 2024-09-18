//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct StoreInjectionMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let propertiesAttributes = variableDeclaration.propertiesAttributes()
        else {
            return []
        }

        return [
          """
          get { self[_\(raw: propertiesAttributes.keyName).self] }
          """,
          """
          set { self[_\(raw: propertiesAttributes.keyName).self] = newValue }
          """
        ]
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {

        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let propertiesAttributes = variableDeclaration.propertiesAttributes()
        else {
            return []
        }

        return [
        """
        private enum _\(raw: propertiesAttributes.keyName): StoreInjectionKey {
            nonisolated(unsafe) static var currentValue \(propertiesAttributes.initializerClauseSyntax)
        }
        """
        ]
    }
}

public struct DependencyInjectionMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let propertiesAttributes = variableDeclaration.propertiesAttributes()
        else {
            return []
        }

        return [
          """
          get { self[_\(raw: propertiesAttributes.keyName).self] }
          """,
          """
          set { self[_\(raw: propertiesAttributes.keyName).self] = newValue }
          """
        ]
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {

        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
              let propertiesAttributes = variableDeclaration.propertiesAttributes()
        else {
            return []
        }

        return [
        """
        private enum _\(raw: propertiesAttributes.keyName): DependencyKey {
            nonisolated(unsafe) static var currentValue \(propertiesAttributes.initializerClauseSyntax)
        }
        """
        ]
    }
}

struct PropertyAttributes {
    let propertyName: String
    let initializerClauseSyntax: InitializerClauseSyntax

    var keyName: String { "\(propertyName.capitalized)Key" }
}

extension VariableDeclSyntax {
    func propertiesAttributes() -> PropertyAttributes? {
        guard modifiers.first?.name.text != "static" else {
            return nil
        }

        for binding in bindings {
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let initializer = binding.initializer

            else {
                continue
            }

            return PropertyAttributes(
                propertyName: propertyName,
                initializerClauseSyntax: initializer
            )

        }
        return nil
    }
}
