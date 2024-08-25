//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import PureduxMacrosImplementation

@attached(accessor)
@attached(peer, names: arbitrary)
public macro InjectedStoreEntry() =
  #externalMacro(
    module: "PureduxMacros", type: "InjectedStoreMacro"
  )
