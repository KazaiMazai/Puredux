//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation

@attached(accessor)
@attached(peer, names: arbitrary)
public macro InjectEntry() =
  #externalMacro(
    module: "PureduxMacros", type: "InjectedStoreMacro"
  )

@attached(accessor)
@attached(peer, names: arbitrary)
public macro DependencyEntry() =
  #externalMacro(
    module: "PureduxMacros", type: "InjectedStoreMacro"
  )
