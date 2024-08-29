//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Dispatch

@available(*, deprecated, message: "Will be removed in the next major release. Changes were made to allowing to use DispatchQueue directly")
typealias ObservationQueue = PresentationQueue

@available(*, deprecated, message: "Will be removed in the next major release. Changes were made to allowing to use DispatchQueue directly")
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

public extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(label: "com.puredux.presentation",
                                                       qos: .userInteractive)
}
