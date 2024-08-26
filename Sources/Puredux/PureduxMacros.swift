//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import PureduxMacros

@attached(accessor)
@attached(peer, names: arbitrary)
public macro InjectEntry() =
  #externalMacro(
    module: "PureduxMacrosPlugin", type: "InjectedStoreMacro"
  )
