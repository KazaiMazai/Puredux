//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/04/2024.
//

import Foundation

public struct Effect {
    typealias Operation = () -> Void
    private let perform: Operation?
}

public extension Effect {
    /**
     Initializes an `Effect` with a closure to be executed.
     
     - Parameter operation: A closure representing the operation to be performed.
    */
    init(_ operation: @escaping () -> Void) {
        perform = operation
    }

    /**
     Initializes an `Effect` with an asynchronous operation.
  
     The operation will be wrapped in a `Task` when the effect will be executed.
  
     - Parameter operation: An asynchronous closure representing the operation to be performed.
    */
    init(operation: @escaping () async -> Void) {
        perform = {
            Task { await operation() }
        }
    }

     /**
      A static instance of `Effect` that postpones any operation.
      
      `Effect.postpone` represents a procrastination mechanism. 
      
      It is used when an effect should be executed based on its state and component logic, but an additional condition necessitates postponing the execution. 
      The effect is not canceled; it is simply delayed until a more appropriate time.
      
      For example, if the effect represents a network request but the access token is expired or being refreshed, you may not want to fire the request and receive an error. 
      
      Instead, you can use `Effect.postpone` to postpone the execution until the conditions are met.
       
      Usage example:
      
      ```swift
      store.effect(toggle: \.shouldFireTheNetworkRequest) { appState, dispatch in
          guard appState.hasFreshAccessToken else {
              return .postpone
          }
           
          Effect {
              // ... perform network request
          }
      }
     ```
    */
    static let postpone: Effect = Effect(operation: nil)
}

extension Effect {
    var operation: Operation {
        perform ?? { }
    }

    var canBeExecuted: Bool {
        perform != nil
    }
}

private extension Effect {
    init(operation: Operation?) {
        perform = operation
    }
}

