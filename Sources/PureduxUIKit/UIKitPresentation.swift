//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Dispatch

public struct UIKitPresentation {
    public static var `default` = UIKitPresentation(queue: .main)

    public var queue: PresentationQueue

    public init(queue: UIKitPresentation.PresentationQueue) {
        self.queue = queue
    }
}

public extension UIKitPresentation {
     enum PresentationQueue {
        case notSpecified
        case main
        case queue(DispatchQueue)

        var dispatchQueue: DispatchQueue {
            switch self {
            case .main:
                return DispatchQueue.main
            case .queue(let queue):
                return queue
            case .notSpecified:
                return DispatchQueue(
                    label: "com.puredux.presenter",
                    qos: .userInteractive)
            }
        }
    }
}
