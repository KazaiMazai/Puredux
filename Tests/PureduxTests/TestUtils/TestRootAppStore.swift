//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01/09/2024.
//
#if canImport(PureduxMacros)
import XCTest
@testable import Puredux
import SwiftUI
import PureduxMacros

extension SharedStores {
    @InjectEntry var rootStore = StateStore<Int, Int>(0) { state, action in state += action }
}
#endif
