//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Dispatch

public enum PresentationQueue {
   case sharedPresentationQueue
   case main
   case serialQueue(DispatchQueue)
}

extension PresentationQueue {
    var dispatchQueue: DispatchQueue {
        switch self {
        case .main:
            return DispatchQueue.main
        case .serialQueue(let queue):
            return queue
        case .sharedPresentationQueue:
         return DispatchQueue.sharedPresentationQueue
        }
    }
}

fileprivate extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(label: "com.puredux.uikit.presentation",
                                                       qos: .userInteractive)
}

 
