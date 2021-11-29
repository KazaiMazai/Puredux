//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Foundation
import Dispatch

public struct PresentationOptions {
    public static var `default` = PresentationOptions(queue: .main)

    public var queue: PresentationQueue
}

public extension PresentationOptions {
     enum PresentationQueue {
        case store
        case main
        case queue(DispatchQueue)

        var dispatchQueue: DispatchQueue? {
            switch self {
            case .main:
                return DispatchQueue.main
            case .queue(let queue):
                return queue
            case .store:
                return nil
            }
        }
    }
}
