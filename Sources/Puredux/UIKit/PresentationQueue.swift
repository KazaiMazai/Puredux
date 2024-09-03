//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29.11.2021.
//

import Dispatch

public extension DispatchQueue {
    static let sharedPresentationQueue = DispatchQueue(label: "com.puredux.presentation",
                                                       qos: .userInteractive)
}
