//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 07.03.2023.
//

import Foundation

public enum PresentationQueue {
    static let sharedQueue = DispatchQueue(
        label: "com.puredux.swiftui.presentation",
        qos: .userInteractive
    )

   case sharedPresentationQueue
   case main
   case serialQueue(DispatchQueue)

   var dispatchQueue: DispatchQueue {
       switch self {
       case .main:
           return DispatchQueue.main
       case .serialQueue(let queue):
           return queue
       case .sharedPresentationQueue:
           return Self.sharedQueue
       }
   }
}
