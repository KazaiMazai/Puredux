//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 25/08/2024.
//

import Foundation
import Dispatch

public protocol AsyncAction {
    associatedtype ResultAction
    var dispatchQueue: DispatchQueue { get }
    func execute(completeHandler: @escaping (ResultAction) -> Void)
}

public extension AsyncAction {
    var dispatchQueue: DispatchQueue { .main }
}
